# Unbound

This role install and configure an Unbound resolver.
It also install a prometheus exporter compiled from [letsencrypt/unbound_exporter](https://github.com/letsencrypt/unbound_exporter)

## Targets

- Debian

## Role variables

- ``unbound_interfaces``: list of interfaces Unbound has to listen on. If not specified, Unbound will listen on 0.0.0.0.
- ``unbound_authorized_cidrs``: list of authorized CIDRS to query the resolver. As Unbound rejects everything by default, if none is set, the resolver won't answer to anyone.
- ``unbound_threads``: number of threads Unbound runs on. (default: 1)
- ``unbound_cache_size``: size of Unbound cache, in Mb. (default: 100)
- ``unbound_zones``: dictionnary about zones that need to be forwarded to another DNS server. It contains info for every managed zone :
	``name``: name of the zone
	``forward_ip``: list of the servers to forward queries to
	``private``: boolean, has to be specified for dummies zones (ex: .priv). It disables DNSSEC validation for thoses zones.

Zones that are not explicitely specified in forwards will be forwarded to root servers.

## Prometheus exporter

* For the exporter to work properly you need to run the following command on each resolver :
```
unbound-control-setup
```
* You also need to ensure that the "extended-statistics: yes" directive is in the conf (it is here).
* The exporter configuration can be change by modifying the systemd service template.

## Unbound logging

In order to enable query log, you need to do the following :
* Add the following directives to the config :
```
    logfile: "/var/log/unbound/unbound.log"
    log-time-ascii: yes
    log-queries: yes
    log-replies: yes # will log informations about the reply, slows response time.
```
* Add the following line in /etc/apparmor.d/usr.sbin.unbound (with the comma) :
```
  /var/log/unbound/unbound.log rw,
```
* Run the following commands to create both directory and file for logging :
```
mkdir /var/log/unbound
touch /var/log/unbound/unbound.log
chown -R unbound:unbound /var/log/unbound
apparmor_parser -r /etc/apparmor.d/usr.sbin.unbound
```
* Restart unbound.

## Example

In this example, we specify to forward queries for domain aaa.com to xxx.xxx.xxx.xxx, bbb.com to yyy.yyy.yyy.yyy or xxx.xxx.xxx.xxx as a failover, and requests for a private zone to zzz.zzz.zzz.zzz :
```yml
unbound_interfaces:
  - "aaa.aaa.aaa.aaa"

unbound_authorized_cidrs:
  - "aaa.aaa.aaa.0/24"
  - "bbb.bbb.bbb.bbb/32"

unbound_threads: 2
unbound_cache_size: 1536

unbound_zones:
  - name: "aaa.com"
    forward_ip:
      - xxx.xxx.xxx.xxx
  - name: "bbb.com"
    forward_ip:
      - yyy.yyy.yyy.yyy
      - xxx.xxx.xxx.xxx
  - name: "mysuperprivatezone.priv"
    forward_ip:
      - zzz.zzz.zzz.zzz
    private: true
```

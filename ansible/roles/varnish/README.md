# Installation et configuration de varnish

## Variables
* varnish_listen_host: Adresse IP sur laquelle varnish écoute. (Default: 0.0.0.0)
* varnish_listen_port: Port sur lequel varnish écoute. (Default : 80)
* varnish_maxmemory: Mémoire maximum occupée par varnish. (Default : 3G)
* varnish_acl_purge_hosts: Adresse IP autorisée à effectuer des requêtes PURGE. (Default 127.0.0.1)
* varnish_health_check: URL de healthcheck des applications qui ne seront pas cachées. (Default : /healthcheck$)
* varnish_backend_servers: Liste des serveurs de backends.
```
varnish_backend_servers:
    docker-hpv008-stg:
       host: "10.13.100.8"
        port: "80"
    docker-hpv009-stg:
        host: "10.13.100.9"
        port: "80"
```
## Fonctionnalités

* Désactive les services systemd fournit de base pour Varnish et Varnishncsa.
* Dépose et active des services custom pour Varnish et Varnishncsa qui permettent la personnalisation des paramètres de lancement.
* Gère la configuration VCL.
* Dépose les configurations logrotate et rsyslog.

## Modification de configuration
```
vim roles/varnish/templates/default.vcl.j2
ansible-playbook -i hosts-stg -l varnish_stg -t config playbooks/varnish.yml
```

### Varnish replies with 503 status for no apparent reason

- Cause : Header receive from the backend are too big for the http_resp_hdr_len parameter.
- Resolve : Increase http_resp_hdr_len parameter live to confirm and in systemd service to make it permanent

```bash
ExecStart=/usr/sbin/varnishd \
          -j unix,user=vcache \
          -F \
          -a 0.0.0.0:6081 \
          -T localhost:6082 \
          -f /etc/varnish/default.vcl \
          -S /etc/varnish/secret \
          -s malloc,3G \
          -p http_resp_hdr_len=16384
```

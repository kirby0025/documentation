### Get Backend list and their status

```bash
varnishadm backend.list
```

### Get value of a config parameter

```bash
varnishadm param.show http_resp_hdr_len
```

### Set value of a config parameter

```bash
varnishadm param.set http_resp_hdr_len 16384
```

### Ban URL

```bash
varnishadm ban req.http.host == example.com '&&' req.url '~' '/test/'
```

### Get request detail filtered by ReqURL

```bash
varnishlog -q 'ReqURL eq "/test/"' -g request
```

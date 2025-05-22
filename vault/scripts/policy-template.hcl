# In KV2 engine, we need to add /data/ to the path.
path "app/data/APPNAME/ENV/*" {
    capabilities = ["read"]
}

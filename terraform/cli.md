## Terraform CLI

### Getting value of a sensitive object

```
terraform console
nonsensitive(nonsensitive(module.applications["myApp"].api_secret_key))
```

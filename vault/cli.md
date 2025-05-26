### Getting a token from existing role

```bash
vault write auth/approle/login role_id= secret_id=
```

### Getting role-id and secret-id from existing approle

```bash
vault read auth/approle/role/<monRole>/role-id
vault write -f auth/approle/role/<monRole>/secret-id
```

### Add bound_service_account_names to kubernetes role

```bash
> vim @api.json
{
    "alias_name_source": "serviceaccount_uid",
    "bound_service_account_names": [
      "my-api",
      "my-api-pending-check-daemon",
      "my-api-consumer2",
      "my-api-consumer"
    ],
    "bound_service_account_namespaces": [
      "namespace1"
    ],
    "token_bound_cidrs": [],
    "token_explicit_max_ttl": 0,
    "token_max_ttl": 0,
    "token_no_default_policy": true,
    "token_num_uses": 0,
    "token_period": 0,
    "token_policies": [
      "my-api-prd"
    ],
    "token_ttl": 0,
    "token_type": "default"
}
> vault write auth/staging/kubernetes/role/my-api @api.json
```

### Add policy to LDAP user

```bash
vault write auth/ldap/users/myUser groups=lead-dev policies=new-policy
```

### See blocked users
```bash
vault read /sys/locked-users
```

### Unblock user
```bash
vault write -f /sys/locked-users/auth_ldap_92748d56/unlock/testsla
```

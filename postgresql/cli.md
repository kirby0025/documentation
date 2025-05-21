### Get list of users and numbers of active connections

```sql
SELECT
    datname AS database_name,
    usename AS user_name,
    count(*) AS active_connections
FROM pg_stat_activity
GROUP BY datname, usename order by active_connections DESC;
```

### Limit number of connections for user

```sql
alter user keycloak connection limit 80;ALTER ROLE
```

### Remove limit number of connections for user

```sql
alter user keycloak connection limit -1;ALTER ROLE
```

### Get replication status

```sql
select * from pg_stat_replication;
```

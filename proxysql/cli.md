### Print query rules for user seb

```bash
select rule_id,active,username,match_digest,destination_hostgroup from runtime_mysql_query_rules where username='seb';
```

### List servers currently in active config

```bash
select * from runtime_mysql_servers;
```

### Print hits per user split by rules

```bash
select stats_mysql_query_rules.rule_id,stats_mysql_query_rules.hits,runtime_mysql_query_rules.match_digest,runtime_mysql_query_rules.username,runtime_mysql_query_rules.destination_hostgroup from stats_mysql_query_rules left join main.runtime_mysql_query_rules on stats_mysql_query_rules.rule_id=runtime_mysql_query_rules.rule_id where username='seb';
```

### Print laster queries for a user

```bash
select distinct * from stats_mysql_query_digest where username like "seb" order by last_seen asc;
```

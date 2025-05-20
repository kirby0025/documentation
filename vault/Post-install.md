## Default Token Duration

- Issue : when you snapshot the raft storage, tokens are integrated in the snapshot, and snapshots size grows (a lot) over time.
- Cause : By default, auth methods uses the default token TTL (30d) for all tokens created.
- Resolve : Adjust the default TTL for tokens for each auth method according to the use. Ex : 1h if using oneshot tokens.

## DIY Vault georeplication with 1 day delay

- Issue : Only paid vault offers realtime georeplication between clusters.
- Resolve : Build a cluster for the main infrastructure, then create another single VM or 3-members cluster and run a script that will download and import the snapshot every day.

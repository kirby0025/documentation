### Drain and cordon node prior to upgrade

```bash
kubectl drain --delete-emptydir-data --ignore-daemonsets <node_name>
```

### Restart deployment

```bash
kubectl rollout restart -n <namespace> deployment <deploymentName>
```

### List pods with app version and status

```bash
kubectl get pods -n <NAMESPACE> -o=custom-columns=NAME:".metadata.name",VERSION:".metadata.labels.app\.kubernetes\.io/version",STATE:".status.phase"
```

### Trigger a helm repository refresh manually

```bash
kubectl annotate -n infrastructure --field-manager=flux-client-side-apply --overwrite helmrepository/bitnami-oci reconcile.fluxcd.io/requestedAt="$(date +%s)"
```

### Generate helm deployment

```bash
kubectl kustomize ./ |less
```

### Execute command in container

```bash
kubectl exec -it -n system clickhouse-server-shard0-0 -- /bin/bash
```

### Get all pods with a specific label

```bash
kubectl get pods --all-namespaces -l helm.sh/chart=company-2.7.1
```

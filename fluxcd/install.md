### Installation or update of Fluxcd

- The Gitlab PAT Token is the one from Fluxcd.
```bash
# Binary configuration
export FLUX_VERSION=X.X.X
curl -s https://fluxcd.io/install.sh | bash
. <(flux completion zsh)

# Define right kubeconfig
<ALIAS_COMMAND>

# FluxCD installation with extras components
flux bootstrap gitlab --components-extra=image-reflector-controller,image-automation-controller \
--hostname=gitlab.example.com \
--token-auth \
--owner=infrastructure/k8s \
--repository=fluxcd \
--branch=main \
--path=clusters/<NAME>
```

### Delete Fluxcd from cluster

```bash
# Define right kubeconfig
<ALIAS_COMMAND>

# Delete flux in a cluster safely
flux uninstall --keep-namespace=true
```

### Token to pull images from Gitlab registry

- Create a token with read_api and read_repository permission for the sa_kubernetes user.
- Create/update it in the corresponding secret in the kubernetes namespaces.

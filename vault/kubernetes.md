## Configuration Vault Agent Injector

### (Rancher RKE-based cluster) Configure an Authorized Cluster Endpoint

- Create a unified domain that will direct queries to managing nodes of the cluster :
1. In Rancher, go to Cluster Management > ClusterName > Edit Config > Authorized Endpoint
2. Set domain name and add the certificate.

### Create Vault resources in kubernetes cluster

- Create a serviceAccount with corresponding Secret, ClusterRoleBinding, Role and RoleBinding.
```bash
cat <<EOF | kubectl -n vault apply -f - 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: vault
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-auth
  annotations:
    kubernetes.io/service-account.name: vault-auth
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-role-tokenreview-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: vault-auth
    namespace: vault
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: vault-role
  namespace: vault
rules:
- apiGroups: [""]
  resources: ["serviceaccounts/token"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: vault-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: vault-role
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: vault
EOF
```

### Create Vault kubernetes auth method

```bash
# Setting variables for next commands
export TOKEN_REVIEW_JWT="$(kubectl get secret vault-auth -n vault -o go-template='{{ .data.token }}' | base64 --decode)"
export HOST_KUBE="https://apik8s.tst.example.com/"

# Create auth methods corresponding to the cluster testing
vault auth enable -path="kubernetes" kubernetes
vault write auth/testing/kubernetes/config \
        token_reviewer_jwt=$TOKEN_REVIEW_JWT \
        kubernetes_ca_cert=@apik8s_tst_certificate.cer \
        kubernetes_host="$HOST_KUBE" \
        disable_iss_validation=true \
        disable_local_ca_jwt=true \

# On créé un secret et on ajoute une policy associée
cat <<EOF |  vault kv put tests/myPod/envVars -
{
  "COMPLEX_VAR": "http://mysuperwebsite.website.com/super/complex",
  "OTHER_VAR": "yes",
  "SPECIAL_VAR": "super
}
EOF

cat <<EOF | vault policy write test-k8s -
path "tests/myPod/*" {
    capabilities = ["read"]
}
EOF

# Create a vault role for our app
# Authorize all service account in the namespace "tests"
vault write auth/kubernetes/role/tests \
         bound_service_account_names='*' \
         bound_service_account_namespaces=tests \
         policies=test-k8s \
         ttl=24h
```

### Install Vault Agent Sidecar Injector

```bash
cat <<EOF > vault-values.yaml
global:
  externalVaultAddr: https://vault.example.com
csi:
  enabled: false
injector:
  authPath: auth/testing/kubernetes
  replicas: 3
server:
  serviceAccount:
    create: false
    name: vault-auth
priorityClassName: "system-cluster-critical"
EOF
helm repo add hashicorp https://helm.releases.hashicorp.com
helm upgrade --install vault hashicorp/vault --version v0.28.1 -f vault-values.yaml
```

### Upgrade Vault Agent Sidecar Injector

- Get the last version number : [Github Vault Helm](https://github.com/hashicorp/vault-helm)
- Create a vault-values.yaml file and upgrade helm release in the cluster
```bash
cat <<EOF > vault-values.yaml
global:
  externalVaultAddr: https://vault.example.com
csi:
  enabled: false
injector:
  authPath: auth/testing/kubernetes
  replicas: 3
server:
  serviceAccount:
    create: false
    name: vault-auth
priorityClassName: "system-cluster-critical"
EOF
helm upgrade -n vault --install vault hashicorp/vault --version v<versionNumber> -f vault-values.yaml
```

### Testing the setup

```bash
# Testing directly the vault kubernetes auth methods :
# Payload : {"role": "tests", "jwt": $TOKEN_REVIEW_JWT}
curl -X POST https://vault.example.com/v1/auth/kubernetes/login -d @payload.json --header "Content-Type: application/json"

# Testing via kubernetes API :
# Ex : https://apik8s.tst.example.com/api/v1/namespaces/vault/serviceaccounts/default/token
# Then : https://apik8s.tst.example.com/apis/authentication.k8s.io/v1/tokenreviews
curl -X POST https://apik8s.tst.example.com/api/v1/namespaces/vault/serviceaccounts/default/token \
     -H "Authorization: Bearer $TOKEN_REVIEW_JWT" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{}'

# payload : {
#    "apiVersion": "authentication.k8s.io/v1",
#    "kind": "TokenReview",
#    "spec": {
#        "token":"<Token returned by the first call>"
#    }
#}
curl -X POST https://apik8s.tst.example.com/apis/authentication.k8s.io/v1/tokenreviews \
     -H "Authorization: Bearer $TOKEN_REVIEW_JWT" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d @payload.json

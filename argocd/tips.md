## ArgoCD config

### Create a Kube secrets storing git token
- This token will be used for every repo in the /kirby path
```
---
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: https://git.hyrule.ovh/kirby
  password: myToken
  username: kirby
```


### Create an app of Apps stored in a repo
```
argocd app create apps --dest-namespace argocd --dest-server https://kubernetes.default.svc --repo https://git.hyrule.ovh/kirby/argocd-conf.git --path apps
argocd app sync apps
```

### Service health stuck Progressing
* TLDR : if service type is LoadBalancer, IngressController does not provide status.LoadBalancer.ip field. Fix : change healtcheck behavior
```
kubectl edit configmap argocd-cm -n argocd
data: |
resource.customizations: |
Service:
  health.lua: |
    hs = {}
    hs.status = "Healthy"
    return hs
```

#!/bin/bash
set -eu
read -p "Are you in the right cluster 'KUBECONFIG=$KUBECONFIG' ? (y/N) : " START

if [[ $START != 'y' ]]; then
  echo "Bye bye."
  exit 1;
fi

NAMESPACE="infrastructure"
NAME="vault-k8s-external-secrets"

kubectl -n $NAMESPACE create secret generic $NAME \
  --from-env-file <(vault kv get -format=json kubernetes-secrets/$NAME | jq '.data.data' | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")

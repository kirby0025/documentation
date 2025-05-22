#!/bin/bash

# This script create role and policy for app using the approle auth method.

APP=$1

cp ./policy-template.hcl ./policy.hcl
sed -i "s|APPNAME|${APP}|g" ./policy.hcl

# Creating stg policy
echo "###################################"
echo "Creation policy et  app role de stg"
echo "###################################"
sed -i "s|ENV|stg|g" ./policy.hcl
/usr/bin/vault policy write "${APP}"-stg ./policy.hcl
/usr/bin/vault write auth/approle/role/${APP}-stg token_policies="${APP}-stg"
/usr/bin/vault read auth/approle/role/${APP}-stg/role-id
/usr/bin/vault write -f auth/approle/role/${APP}-stg/secret-id

# Creating prd policy
echo "###################################"
echo "Creation policy et  app role de prd"
echo "###################################"
sed -i "s|stg|prd|g" ./policy.hcl
/usr/bin/vault policy write "${APP}"-prd ./policy.hcl
/usr/bin/vault write auth/approle/role/${APP}-prd token_policies="${APP}-prd"
/usr/bin/vault read auth/approle/role/${APP}-prd/role-id
/usr/bin/vault write -f auth/approle/role/${APP}-prd/secret-id

rm -f ./policy.hcl

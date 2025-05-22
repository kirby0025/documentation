#!/bin/bash

# This script will create a role in each kubernetes auth method.
# It will also create a policy based on a template for each environment.

set -eu

# Getting app name and namespace from argument
APP=$1
NAMESPACE=$2


cp ./policy-template.hcl ./policy.hcl
sed -i "s|APPNAME|${APP}|g" ./policy.hcl

# Creating tst policy
echo "###################################"
echo "Creation policy et  app role de tst"
echo "###################################"
CURRENT_ENV="tst"
sed -i "s|ENV|tst|g" ./policy.hcl
/usr/bin/vault policy write "${APP}"-"${CURRENT_ENV}" ./policy.hcl
/usr/bin/vault write auth/testing/kubernetes/role/"${APP}" \
	bound_service_account_names="${APP}" \
	bound_service_account_namespaces="${NAMESPACE}" \
	alias_name_source="serviceaccount_uid" \
	token_no_default_policy=true \
	token_policies="${APP}""-""${CURRENT_ENV}"

# Creating stg policy
echo "###################################"
echo "Creation policy et  app role de stg"
echo "###################################"
CURRENT_ENV="stg"
sed -i "s|tst|stg|g" ./policy.hcl
/usr/bin/vault policy write "${APP}"-"${CURRENT_ENV}" ./policy.hcl
/usr/bin/vault write auth/staging/kubernetes/role/"${APP}" \
	bound_service_account_names="${APP}" \
	bound_service_account_namespaces="${NAMESPACE}" \
	alias_name_source="serviceaccount_uid" \
	token_no_default_policy=true \
	token_policies="${APP}""-""${CURRENT_ENV}"

# Creating prd policy
echo "###################################"
echo "Creation policy et  app role de prd"
echo "###################################"
CURRENT_ENV="prd"
sed -i "s|stg|prd|g" ./policy.hcl
/usr/bin/vault policy write "${APP}"-"${CURRENT_ENV}" ./policy.hcl
/usr/bin/vault write auth/production/kubernetes/role/"${APP}" \
	bound_service_account_names="${APP}" \
	bound_service_account_namespaces="${NAMESPACE}" \
	alias_name_source="serviceaccount_uid" \
	token_no_default_policy=true \
	token_policies="${APP}""-""${CURRENT_ENV}"

rm -f ./policy.hcl

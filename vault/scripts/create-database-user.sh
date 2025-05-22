#!/bin/bash

# Usage : ./create-database-user.sh my-api

USERNAME=$1
TYPE="mongodb"
PASSWORD=$(apg -a 1 -n 1 -m 24 -x 24 -M LN -E "\''azqwml1i0o")

ENV="stg"
echo "Putting databases-users/${TYPE}/${ENV}/${USERNAME} with password: ${PASSWORD}"
/usr/bin/vault kv put databases-users/"${TYPE}"/"${ENV}"/"${USERNAME}" password="${PASSWORD}" username="${USERNAME}"

PASSWORD=$(apg -a 1 -n 1 -m 24 -x 24 -M LN -E "\''azqwml1i0o")
ENV="prd"
echo "Putting databases-users/${TYPE}/${ENV}/${USERNAME} with password: ${PASSWORD}"
/usr/bin/vault kv put databases-users/"${TYPE}"/"${ENV}"/"${USERNAME}" password="${PASSWORD}" username="${USERNAME}"

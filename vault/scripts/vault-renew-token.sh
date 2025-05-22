#!/bin/bash

# Script to refresh vault token used in CLI by a tool (rundeck here)

RUNDECK_TOKEN_PATH="/var/lib/rundeck/.vault-token"
STATUS="0"
STATUSFILE=/var/tmp/batch.vault-renew-token.sh
export DBUS_SESSION_BUS_ADDRESS=/dev/null
export VAULT_ADDR="https://vault.example.com"
source /var/lib/rundeck/vault-renew-token.conf

set -eu

function set_error_status() {
    echo "[$(date '+%Y%m%d %H%M%S')] : Something went wrong in the script, exiting." | tee -a "${LOGFILE}"
    echo "2 vault-snapshot-restore - KO" > ${STATUSFILE}
}

trap set_error_status ERR

TOKEN=$(/usr/bin/vault write -field="token" auth/approle/login token_ttl="32d" role_id="${ROLEID}" secret_id="${SECRETID}")
echo "${TOKEN}" > "${RUNDECK_TOKEN_PATH}"

echo "0 vault-renew-token - OK" > ${STATUSFILE}
exit "${STATUS}"

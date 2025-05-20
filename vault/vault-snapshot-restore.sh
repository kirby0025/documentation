#!/bin/bash

DATE=$(date +"%F:%R")
DATE_SNAPSHOT=$(date +"%Y%m%d")
LOGFILE="/data/log/scripts/vault-snapshot-restore.log"
TMP_DIR="/tmp/"
S3_ENDPOINT=""
S3_BUCKET=""
FILENAME="vault-${DATE_SNAPSHOT}.snap"
STATUS="0"
STATUSFILE="/var/tmp/batch.vault-snapshot-restore.sh"
HOST_KUBE=""
VAULT_ADDR=""
VAULT_TOKEN=""

# Set ROLE_ID and SECRET_ID
source /root/.config/vault-snapshot.conf
set -eu

function set_error_status() {
    echo "[$(date '+%Y%m%d %H%M%S')] : Something went wrong in the script, exiting." | tee -a "${LOGFILE}"
    echo "2 vault-snapshot-restore - KO" > ${STATUSFILE}
}

trap set_error_status ERR

#Disable TLS checking
export VAULT_SKIP_VERIFY="TRUE"
export VAULT_CLIENT_TIMEOUT=300
export VAULT_ADDR="https://127.0.0.1:8200"

# Downloading vault-snapshot from S3 bucket. Needs awscli setup properly for the user.
echo "[$(date '+%Y%m%d %H%M%S')] : Downloading vault archive ${FILENAME} from ${DATE} ###" | tee -a "${LOGFILE}"
/usr/local/bin/aws --no-progress --endpoint-url "${S3_ENDPOINT}" s3 cp s3://"${S3_BUCKET}"/"$FILENAME" /tmp/${FILENAME} | tee -a "${LOGFILE}"

# Getting a token with grants to force restore snapshot
echo "[$(date '+%Y%m%d %H%M%S')] : Vault login ###" | tee -a "${LOGFILE}"
TOKEN=$(/usr/bin/vault write -field="token" auth/approle/login role_id="${ROLEID}" secret_id="${SECRETID}")
export VAULT_TOKEN="${TOKEN}"

echo "[$(date '+%Y%m%d %H%M%S')] : Snapshot restoration ###" | tee -a "${LOGFILE}"
vault operator raft snapshot restore -force /tmp/${FILENAME}

# Wait an estimated sufficient time for the snapshot to be fully restored.
sleep 600

echo "[$(date '+%Y%m%d %H%M%S')] : On oublie l'ancien token ###" | tee -a "${LOGFILE}"
TOKEN=""

# Getting a new token since we successfully restored snapshot.
echo "[$(date '+%Y%m%d %H%M%S')] : Vault login ###" | tee -a "${LOGFILE}"
TOKEN=$(/usr/bin/vault write -field="token" auth/approle/login role_id="${ROLEID}" secret_id="${SECRETID}")
export VAULT_TOKEN="${TOKEN}"

# Get kube token to update auth method for this site's cluster.
echo "[$(date '+%Y%m%d %H%M%S')] : Recuperation token Kube ###" | tee -a "${LOGFILE}"
TOKEN_REVIEW_JWT="$(kubectl get secret vault-auth -n vault -o go-template='{{ .data.token }}' | base64 --decode)"

# Rewriting Kube API URL in auth method to match this sites cluster.
echo "[$(date '+%Y%m%d %H%M%S')] : Setting kube api url" | tee -a "${LOGFILE}"
vault write auth/production/kubernetes/config token_reviewer_jwt=$TOKEN_REVIEW_JWT kubernetes_ca_cert=@/root/.kube/infolegale.net.crt kubernetes_host="$HOST_KUBE" disable_iss_validation=true disable_local_ca_jwt=true

echo "[$(date '+%Y%m%d %H%M%S')] : Cleaning downloaded snapshot ###" | tee -a "${LOGFILE}"
rm -f /tmp/${FILENAME}
echo "0 vault-snapshot-restore - OK" > ${STATUSFILE}
echo "[$(date '+%Y%m%d %H%M%S')] : ###### FIN ######" | tee -a "${LOGFILE}"
exit ${STATUS}

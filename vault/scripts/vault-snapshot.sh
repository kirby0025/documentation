#!/bin/bash

BACKUPDIR="/data/backups/vault"
CLASS="STANDARD"
BUCKET=""
ENDPOINT=""
LOGFILE="/data/log/scripts/vault-snapshot.sh"
DATE=$(date +"%Y%m%d")
STATUS="0"
STATUSFILE="/var/tmp/batch.vault-snapshot.sh"
STANDBY="true"

export VAULT_SKIP_VERIFY="TRUE"

source /root/.config/vault-snapshot.conf
set -eu

# Function to handle error during the script.
function set_error_status() {
    echo "[$(date '+%Y%m%d %H%M%S')] : Something went wrong in the script, exiting." | tee -a "${LOGFILE}"
    echo "2 vault-snapshot-restore - KO" > ${STATUSFILE}
}

trap set_error_status ERR

cd "${BACKUPDIR}" || exit

echo "${DATE} : Récupération du token" | tee -a "${LOGFILE}"
TOKEN=$(/usr/bin/vault write -field="token" auth/approle/login role_id="${ROLEID}" secret_id="${SECRETID}")
export VAULT_TOKEN="${TOKEN}"

# Check if the node is the active one, if not we stop.
STANDBY=$(/usr/bin/vault read sys/health -format=json | jq '.data.standby')
if [ ! "${STANDBY}" == "false" ]; then
    echo "${DATE} : Noeud en standby, on arrête le snapshot" | tee -a "${LOGFILE}"
    echo "${DATE} : ###### FIN ######" | tee -a "${LOGFILE}"
    echo "0 vault-snapshot - Standby node" > ${STATUSFILE}
    exit 0
fi

echo "${DATE} : Lancement du snapshot" | tee -a "${LOGFILE}"
/usr/bin/vault operator raft snapshot save "${BACKUPDIR}"/vault-"${DATE}".snap |tee -a "${LOGFILE}"

echo "${DATE} : Upload du snapshot sur S3" | tee -a "${LOGFILE}"
/usr/local/bin/aws --endpoint-url "${ENDPOINT}" s3 cp "${BACKUPDIR}"/vault-"${DATE}".snap s3://"${BUCKET}"/ --storage-class "${CLASS}" --only-show-errors |tee -a "${LOGFILE}"

echo "${DATE} : Nettoyage des snapshots de +10 jours" | tee -a "${LOGFILE}"
/usr/bin/find ${BACKUPDIR} -name "*.snap" -mtime 10 -delete

echo "0 vault-snapshot - OK" > ${STATUSFILE}
echo "${DATE} : ###### FIN ######" | tee -a "${LOGFILE}"
exit ${STATUS}

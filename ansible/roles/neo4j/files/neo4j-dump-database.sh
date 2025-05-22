#!/bin/sh

# {{ ansible_managed }}

set -eu

NOW=$(date +%Y%m%d-%H%M%S)
HOSTNAME=$(hostname -s)
STATUS=0
EXITSTATUS=0
OUTPUT=""
LOGFILE="/data/log/scripts/neo4j-dump-databases.log"
COMPRESS=false

touch ${LOGFILE}

#
# Functions
#

checkNas()
{
    if [ ! -e "${BACKUPDIR}/.mount" ]; then
        echo "${BACKUPDIR} not mounted. Backup aborted." | tee -a ${LOGFILE}
        exit 1
    fi
}

usage()
{
  echo "$0 -r <retention> -d <repertoire> -c (compression)"
  echo "Exemple : /data/scripts/neo4j-dump-databases -r 20 -d /nas -c"
}

#
# Main
#

while getopts "hcr:d:" option
do
  case "${option}"
  in
    r)
      RETENTION=${OPTARG};;
    d)
      BACKUPDIR=${OPTARG};;
    c)
      COMPRESS=true;;
    h | *)
      usage
      exit 1;;
  esac
done

echo "[$(date '+%Y%m%d %H%M%S')] Lancement du dump neo4j de ${HOSTNAME} - Retention : ${RETENTION} - Repertoire de destination : ${BACKUPDIR}" | tee -a ${LOGFILE}

mkdir -p "$BACKUPDIR"/neo4jdump/
find "$BACKUPDIR"/neo4jdump/ -mindepth 1 -maxdepth 1 -type f -daystart -mtime +"$RETENTION" -delete

echo "[$(date '+%Y%m%d %H%M%S')][INFO] Arret de Neo4j" | tee -a ${LOGFILE}
systemctl stop neo4j.service

for db in neo4j system ; do
  echo "[$(date '+%Y%m%d %H%M%S')][INFO] dump de $db" | tee -a ${LOGFILE}
  if [ "$COMPRESS" = true ]; then
    neo4j-admin database dump --to-stdout $db | gzip -1 > "$BACKUPDIR"/neo4jdump/"${NOW}"_"${HOSTNAME}"_"${db}".dump.gz | tee -a ${LOGFILE}
  else
    neo4j-admin database dump --to-stdout $db > "$BACKUPDIR"/neo4jdump/"${NOW}"_"${HOSTNAME}"_"${db}".dump | tee -a ${LOGFILE}
  fi
  STATUS=$?
  if [ ! ${STATUS} -eq 0 ]; then
    echo "[$(date '+%Y%m%d %H%M%S')][CRIT] neo4jdump failed" | tee -a ${LOGFILE}
    OUTPUT="${OUTPUT} neo4j"
    EXITSTATUS=1
    break
  fi
done

echo "[$(date '+%Y%m%d %H%M%S')][INFO] Demarrage de Neo4j" | tee -a ${LOGFILE}
systemctl start neo4j.service

if [ ${EXITSTATUS} -eq 0 ]; then
  echo "$(date '+%s')|${EXITSTATUS}|Everything has been successfully backuped !" | tee /var/tmp/batch.`basename $0`
else
  echo "$(date '+%s')|${EXITSTATUS}|Problem with mysqldump backup (${OUTPUT}) !" | tee /var/tmp/batch.`basename $0`
fi

echo "[$(date '+%Y%m%d %H%M%S')] Fin du dump neo4j de ${HOSTNAME} - Retention : ${RETENTION} - Repertoire de destination : ${BACKUPDIR}" | tee -a ${LOGFILE}
exit ${EXITSTATUS}

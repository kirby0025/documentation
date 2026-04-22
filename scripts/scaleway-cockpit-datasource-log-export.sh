#!/bin/bash

set -euo pipefail
set_error_status() {
    echo "[$(date '+%Y%m%d %H:%M:%S %z')] : Error in line $LINENO : $BASH_COMMAND"
}
# Set the function called when the ERR signal is caught.
trap set_error_status ERR

export DATASOURCES_LIST=""
export LABELS="project_id,region,resource_type,resource_id,service_name"
export RSYSLOG_DIR="/var/log/rsyslog"
export INPUT_DIR="${RSYSLOG_DIR}/input"
export TIME_DIR="${RSYSLOG_DIR}/timestamps"
export LOG_DIR="${RSYSLOG_DIR}/logs"
export CRASH_DEDUP_WINDOW=2000

# Getting number of CPU core(s) to adapt the number of parallel jobs.
get_cpu_count() {
    if [[ -f /proc/cpuinfo ]]; then
        grep -c ^processor /proc/cpuinfo
    elif command -v sysctl &>/dev/null; then
        sysctl -n hw.ncpu
    else
        echo 1
    fi
}

log_msg() {
    local LVL="${1^^}"
    local MSG="${2}"
    local ID="${3}"
    if [[ -z "$LVL" || -z "$MSG" || -z "$ID" ]]; then
        printf 'log_msg: missing required arguments (level, message or project/datasource id).\n' >&2
        return 1
    fi
    local TS="$(date -u "+%Y%m%d %H:%M:%S %z")"
    local LINE="[${TS}] ${LVL} : ${MSG}"
    printf '%s\n' "$LINE" >> ${LOG_DIR}/${ID}.log
    return 0
}
export -f log_msg

crash_handler() {
    local datasource=$1
    local logfile="${LOG_DIR}/${datasource}.log"
    local tmp_new="${INPUT_DIR}/${datasource}.retry"
    # Get timestamp from last line written in log file.
    local last_ts=$(tail -n 1 ${INPUT_DIR}/${DATASOURCE}.log | jq -r '.timestamp')
    log_msg "INFO" "Crash handler last timestamp detected : ${last_ts}." "${datasource}"
    # Substract 1 second to timestamp to eliminate the lack of order in the logs from loki.
    local from_ts=$(date -u -d "$last_ts - 1 second" --iso-8601=seconds)
    log_msg "INFO" "Crash handler new timestamp configured : ${from_ts}." "${datasource}"
    export FROM="$from_ts"
    export NOW=$(date --iso-8601=seconds)
    export LOKI_ADDR="https://${datasource}.logs.cockpit.fr-par.scw.cloud"

    # Same query than in normal process.
    logcli query '{service_name=~".+"} |= "" | keep '"${LABELS}"' | label_format datasource_id='"\"${datasource}\""' | line_format "{{ __line__ }}"' \
        -o jsonl --include-common-labels \
        --from="${FROM}" --to="${NOW}" \
        --batch=3000 --parallel-max-workers=4 \
        >> "$tmp_new"
    # Check if the process still crashes and exit if so.
    local RC=$?
    if [[ $RC != 0 ]]; then
        log_msg "ERROR" "Logcli still failed (exit $rc). Leaving $tmp_new for manual analysis." "${datasource}"
        return $RC
    fi

    # Load last CRASH_DEDUP_WINDOW line into an array.
    declare -A _log_seen=()
    local line count=0
    while IFS= read -r line && (( count < CRASH_DEDUP_WINDOW )); do
        _log_seen["$line"]=1
        (( count++ ))
    done < <(tail -n "$CRASH_DEDUP_WINDOW" "$logfile" 2>/dev/null || true)

    # Read lines retrieve with logcli. If it's not in the array, write to file, else discard.
    while IFS= read -r line; do
        if [[ -z "${_log_seen[$line]+_}" ]]; then
            printf '%s\n' "$line" >> "$logfile"
            _log_seen["$line"]=1
        fi
    done < "$tmp_new"
    rm -f "$tmp_new"
    # Update timestamp for the next run.
    echo "${NOW}" > "${TIME_DIR}/${datasource}.from"
    log_msg "INFO" "Crash-recovery for $datasource finished." "${datasource}"
}
export -f crash_handler

# Function that handle the log download.
logcli_run () {
    DATASOURCE=$1
    # Check if datasource timestamp file exists.
    if [ ! -e ${TIME_DIR}/${DATASOURCE}.from ]; then
        log_msg "INFO" "Missing timestamp for ${DATASOURCE}. Creating it." "${DATASOURCE}"
        export NOW=$(date --iso-8601=seconds)
        echo "${NOW}" > ${TIME_DIR}/${DATASOURCE}.from
    fi
    # Check if last run crashed.
    if [ -e "${LOG_DIR}/${DATASOURCE}.fail" ]; then
        log_msg "INFO" "Calling crash handler for ${DATASOURCE}." "${DATASOURCE}"
        crash_handler ${DATASOURCE}
        local RC=$?
        if [ $RC != 0 ]; then
            log_msg "ERROR" "Crash handler failed. Exiting" "${DATASOURCE}"
            exit $RC
        fi
    fi
    export LOKI_ADDR="https://${DATASOURCE}.logs.cockpit.fr-par.scw.cloud"
    export FROM=$(cat ${TIME_DIR}/${DATASOURCE}.from)
    log_msg "INFO" "Download logs for ${DATASOURCE} starting at ${FROM}." "${DATASOURCE}"
    export NOW=$(date --iso-8601=seconds)
    logcli query '{service_name=~".+"} |= "" | keep '${LABELS}' | label_format datasource_id='\"${DATASOURCE}\"' | line_format "{{ __line__ }}"' \
    -o jsonl --include-common-labels \
    --from="${FROM}" --to="${NOW}" \
    --batch=3000 --parallel-max-workers=4 \
    >> ${INPUT_DIR}/${DATASOURCE}.log

    STATUS=$?
    if [ ${STATUS} -ne 0 ]; then
        # If logcli returns an error, write fail state file and exit.
        touch ${LOG_DIR}/${DATASOURCE}.fail
        log_msg "ERROR" "Error with collect, writing fail file." "${DATASOURCE}"
        exit ${STATUS}
    else
        echo "${NOW}" > ${TIME_DIR}/${DATASOURCE}.from
        [[ -e ${LOG_DIR}/${DATASOURCE}.fail ]] && rm -f ${LOG_DIR}/${DATASOURCE}.fail
        log_msg "INFO" "Download finished for ${DATASOURCE} at ${NOW}." "${DATASOURCE}"
    fi
}
export -f logcli_run

log_msg "INFO" "Process starting for project $1." "$1"
if  [ ! -z "$1" ]; then
    if [ -e ~/.scw-$1 ]; then
        source ~/.scw-$1
        log_msg "INFO" "SCW config file loaded for project $1" "$1"
    else
        log_msg "ERROR" "SCW config file missing for project $1" "$1"
        exit 1
    fi
    if [ -e ~/.logcli-$1 ]; then
        source ~/.logcli-$1
        log_msg "INFO" "LogCLI config file loaded for project $1" "$1"
    else
        log_msg "ERROR" "LogCLI config file missing for project $1" "$1"
        exit 1
    fi
else
    echo "[$(date '+%Y%m%d %H:%M:%S %z')] Error : Missing project ID argument"
    exit 1
fi

MAX_JOBS=$(get_cpu_count)
# Retrieve datasource list for the project
DATASOURCES_LIST=$(/usr/local/bin/scw cockpit data-source list types.0=logs -o wide=ID | sed '1d')
# Print every entry in the datasources list and pass it to the parallel call of logcli_run function.
printf "%s\n" "${DATASOURCES_LIST}" | parallel -j ${MAX_JOBS} logcli_run {}
log_msg "INFO" "Process finish for project $1." "$1"

### Explication commande logcli :
# {service_name}=~".+" | =""    -> Tous les logs dont le champs service n'est pas nul.
# keep '${LABELS}'              -> On indique les labels communs qu'on souhaite garder.
# label_format datasource_id='' -> On configure le(s) label(s) qu'on veut insérer dans les logs.
# line_format "{{ __line__ }}"  -> On indique qu'on veut garder la ligne de log pure.
# -o jsonl                      -> Format de sortie du log.
# --include-common-labels       -> Sans cet argument logcli ne garde pas dans les logs les labels communs aux lignes.
# --from                        -> Date d'arrêt de la dernière collecte.
# --to                          -> Date limite de la collecte de logs.
# --batch                       -> Augmente le nombre de logs à chaque itération de logcli.
#
# On définit $NOW avant de lancer la collecte afin de ne pas perdre les logs
# qui pourraient être envoyés dans Loki entre le lancement de logcli
# et l'écriture du timestamp dans le fichier.
#
# Probleme a l'utilisation :
# - si le script crash, on peut avoir des logs en doublons parce que loki ne garantit pas l'ordre.

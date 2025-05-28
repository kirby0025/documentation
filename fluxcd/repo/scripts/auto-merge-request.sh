#!/usr/bin/env bash
set -eu
HOST="${CI_API_V4_URL}/projects/"
TARGET_BRANCH='main'
TOKEN=$(echo ${API_TOKEN_FOR_MR} | base64 -d)

LABELS=""
[[ ${CI_COMMIT_REF_NAME} =~ ^deploy\/.*-prd$ ]] && LABELS="Production"
[[ ${CI_COMMIT_REF_NAME} =~ ^deploy\/.*-stg$ ]] && LABELS="Staging"

BODY="{
    \"id\": ${CI_PROJECT_ID},
    \"source_branch\": \"${CI_COMMIT_REF_NAME}\",
    \"target_branch\": \"${TARGET_BRANCH}\",
    \"remove_source_branch\": true,
    \"title\": \"${CI_COMMIT_REF_NAME}\",
    \"labels\":\"${LABELS}\",
    \"squash\": true  
}";


LISTMR=`curl --silent "${HOST}${CI_PROJECT_ID}/merge_requests?state=opened" --header "PRIVATE-TOKEN:${TOKEN}"`;
COUNTBRANCHES=`echo ${LISTMR} | grep -o "\"source_branch\":\"${CI_COMMIT_REF_NAME}\"" | wc -l`;
if [ ${COUNTBRANCHES} -eq "0" ]; then
    curl -X POST "${HOST}${CI_PROJECT_ID}/merge_requests" \
        --header "PRIVATE-TOKEN:${TOKEN}" \
        --header "Content-Type: application/json" \
        --data "${BODY}";

    echo "Opened a new merge request.";
    exit;
fi

echo "No new merge request opened.";

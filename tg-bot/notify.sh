#!/usr/bin/env bash
set -euo pipefail

STATUS="${1:-unknown}"
JOB="${2:-job}"
PIPELINE_URL="${3:-#}"
BRANCH="${4:-unknown}"
COMMIT="${5:-unknown}"

case "$STATUS" in
  success) STATUS_TEXT="SUCCESS" ;;
  failed)  STATUS_TEXT="FAILED" ;;
  canceled) STATUS_TEXT="CANCELED" ;;
  *)       STATUS_TEXT="UNKNOWN" ;;
esac

MESSAGE="CI/CD Pipeline Update
Job: ${JOB}
Status: ${STATUS_TEXT}
Branch: ${BRANCH}
Commit: ${COMMIT}
Link: ${PIPELINE_URL}"

echo "🔍 Debug: TG_BOT_TOKEN length: ${#TG_BOT_TOKEN}"
echo "🔍 Debug: TG_CHAT_ID: ${TG_CHAT_ID}"
echo "🔍 Debug: MESSAGE preview:"
echo "${MESSAGE}" | head -c 200

curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
  -d "chat_id=${TG_CHAT_ID}" \
  --data-urlencode "text=${MESSAGE}" \
  -d "parse_mode=none" \
  -d "disable_web_page_preview=true"
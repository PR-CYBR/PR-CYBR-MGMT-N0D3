#!/usr/bin/env bash

# slack-notify.sh - Send notifications to Slack
# Usage: ./slack-notify.sh <message> [title] [color]

set -euo pipefail

# Check for SLACK_WEBHOOK_URL environment variable
if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
    echo "[WARN] SLACK_WEBHOOK_URL not set, skipping notification"
    exit 0
fi

# Get message and optional parameters
MESSAGE="${1:-No message provided}"
TITLE="${2:-PR-CYBR Management Node}"
COLOR="${3:-good}"

# Build JSON payload
PAYLOAD=$(cat <<EOF
{
  "attachments": [
    {
      "color": "$COLOR",
      "title": "$TITLE",
      "text": "$MESSAGE",
      "footer": "PR-CYBR-MGMT-N0D3",
      "ts": $(date +%s)
    }
  ]
}
EOF
)

# Send to Slack
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD" \
  --silent \
  --show-error

echo "[INFO] Notification sent to Slack"

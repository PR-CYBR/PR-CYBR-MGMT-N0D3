#!/bin/bash
# Slack Notification Script
# Sends notifications to Slack via webhook

set -e

# Load environment variables
if [ -f "../../.env" ]; then
    # shellcheck disable=SC1091
    source ../../.env
fi

# Check for webhook URL
if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "Error: SLACK_WEBHOOK_URL not set"
    exit 1
fi

# Get message and severity
MESSAGE=${1:-"No message provided"}
SEVERITY=${2:-"info"}

# Set color based on severity
case $SEVERITY in
    success)
        COLOR="#36a64f"
        ;;
    warning)
        COLOR="#ff9900"
        ;;
    error)
        COLOR="#ff0000"
        ;;
    *)
        COLOR="#0000ff"
        ;;
esac

# Get timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get source (script name or workflow)
SOURCE="${GITHUB_WORKFLOW:-$(basename "$0")}"

# Build JSON payload
PAYLOAD=$(cat <<EOF
{
    "attachments": [
        {
            "color": "$COLOR",
            "title": "PR-CYBR Management Node",
            "text": "$MESSAGE",
            "fields": [
                {
                    "title": "Severity",
                    "value": "$SEVERITY",
                    "short": true
                },
                {
                    "title": "Source",
                    "value": "$SOURCE",
                    "short": true
                },
                {
                    "title": "Timestamp",
                    "value": "$TIMESTAMP",
                    "short": false
                }
            ],
            "footer": "PR-CYBR-MGMT-N0D3"
        }
    ]
}
EOF
)

# Send to Slack
curl -X POST -H 'Content-type: application/json' --data "$PAYLOAD" "$SLACK_WEBHOOK_URL"

echo "Notification sent to Slack"

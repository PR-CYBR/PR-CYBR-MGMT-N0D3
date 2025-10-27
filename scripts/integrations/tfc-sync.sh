#!/usr/bin/env bash

# tfc-sync.sh - Sync with Terraform Cloud
# Usage: ./tfc-sync.sh <action> [workspace]
# action: plan, apply, status

set -euo pipefail

# Check for TFC_API_TOKEN environment variable
if [ -z "${TFC_API_TOKEN:-}" ]; then
    echo "[ERROR] TFC_API_TOKEN not set"
    exit 1
fi

# Configuration
TFC_ORGANIZATION="${TFC_ORGANIZATION:-PR-CYBR}"
TFC_WORKSPACE="${2:-${TFC_WORKSPACE:-pr-cybr-mgmt-node}}"
ACTION="${1:-status}"

# API base URL
API_URL="https://app.terraform.io/api/v2"

# Function to get workspace ID
get_workspace_id() {
    local workspace_name="$1"
    curl -s \
        -H "Authorization: Bearer $TFC_API_TOKEN" \
        -H "Content-Type: application/vnd.api+json" \
        "$API_URL/organizations/$TFC_ORGANIZATION/workspaces/$workspace_name" | \
        jq -r '.data.id'
}

# Main logic
case "$ACTION" in
    status)
        echo "[INFO] Getting workspace status..."
        WORKSPACE_ID=$(get_workspace_id "$TFC_WORKSPACE")
        if [ "$WORKSPACE_ID" != "null" ]; then
            echo "[INFO] Workspace ID: $WORKSPACE_ID"
            echo "[INFO] Workspace: $TFC_WORKSPACE"
        else
            echo "[ERROR] Workspace not found: $TFC_WORKSPACE"
            exit 1
        fi
        ;;
    plan)
        echo "[INFO] Triggering Terraform plan..."
        echo "[WARN] TFC plan trigger not yet fully implemented"
        ;;
    apply)
        echo "[INFO] Triggering Terraform apply..."
        echo "[WARN] TFC apply trigger not yet fully implemented"
        ;;
    *)
        echo "[ERROR] Unknown action: $ACTION"
        echo "[ERROR] Valid actions: status, plan, apply"
        exit 1
        ;;
esac

echo "[INFO] TFC sync complete"

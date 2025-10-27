#!/bin/bash
# Configure Secrets Script
# Interactive setup for environment variables and secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== PR-CYBR-MGMT-N0D3 Secrets Configuration ===${NC}\n"

# Check if .env exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}Existing .env file found${NC}"
    echo -n "Overwrite existing configuration? (yes/no): "
    read -r OVERWRITE
    if [ "$OVERWRITE" != "yes" ]; then
        echo "Configuration cancelled. Edit .env manually if needed."
        exit 0
    fi
fi

# Copy from example
if [ ! -f "config/.env.example" ]; then
    echo -e "${RED}Error: config/.env.example not found${NC}"
    exit 1
fi

cp config/.env.example .env
echo -e "${GREEN}.env file created${NC}\n"

# Function to update env variable
update_env() {
    local KEY=$1
    local VALUE=$2
    local FILE=${3:-.env}
    
    if grep -q "^${KEY}=" "$FILE"; then
        sed -i.bak "s|^${KEY}=.*|${KEY}=${VALUE}|" "$FILE"
        rm "${FILE}.bak" 2>/dev/null || true
    fi
}

# Function to prompt for value
prompt_value() {
    local KEY=$1
    local DESCRIPTION=$2
    local REQUIRED=${3:-false}
    local SECRET=${4:-false}
    
    while true; do
        echo -e "${BLUE}$DESCRIPTION${NC}"
        if [ "$SECRET" = "true" ]; then
            read -r -s -p "${KEY}: " VALUE
            echo ""
        else
            read -r -p "${KEY}: " VALUE
        fi
        
        if [ -z "$VALUE" ] && [ "$REQUIRED" = "true" ]; then
            echo -e "${RED}This value is required${NC}"
            continue
        fi
        
        break
    done
    
    if [ -n "$VALUE" ]; then
        update_env "$KEY" "$VALUE"
    fi
}

echo -e "${GREEN}Docker Swarm Configuration${NC}"
echo "Leave empty to skip optional fields"
echo ""

prompt_value "SWARM_MANAGER_IP" "Manager node IP address" false false

echo ""
echo -e "${GREEN}Terraform Cloud Configuration${NC}"
echo ""

prompt_value "TFC_API_TOKEN" "Terraform Cloud API token" false true
prompt_value "TFC_ORGANIZATION" "Terraform Cloud organization name" false false
prompt_value "TFC_WORKSPACE" "Terraform Cloud workspace name" false false

echo ""
echo -e "${GREEN}Notion Integration${NC}"
echo ""

prompt_value "NOTION_API_KEY" "Notion API key (integration token)" false true
prompt_value "NOTION_DATABASE_ID" "Notion database ID" false false

echo ""
echo -e "${GREEN}Slack Integration${NC}"
echo ""

prompt_value "SLACK_WEBHOOK_URL" "Slack webhook URL" false true
prompt_value "SLACK_CHANNEL" "Slack channel (e.g., #pr-cybr-alerts)" false false

echo ""
echo -e "${GREEN}GitHub Configuration${NC}"
echo ""

prompt_value "GITHUB_TOKEN" "GitHub personal access token" false true

echo ""
echo -e "${GREEN}Environment Settings${NC}"
echo ""

echo "Select environment (dev/staging/prod):"
read -r ENVIRONMENT
if [ -n "$ENVIRONMENT" ]; then
    update_env "ENVIRONMENT" "$ENVIRONMENT"
fi

echo ""
echo -e "${GREEN}=== Configuration Complete ===${NC}\n"

echo "Configuration saved to .env"
echo ""
echo -e "${YELLOW}Important:${NC}"
echo "1. Never commit .env to version control"
echo "2. Keep your secrets secure"
echo "3. Review .env file to ensure all values are correct"
echo "4. Add secrets to GitHub Secrets for CI/CD workflows"
echo ""
echo "Next steps:"
echo "1. Review .env: cat .env"
echo "2. Add GitHub Secrets via repository settings"
echo "3. Initialize environment: ./scripts/setup/init-env.sh"

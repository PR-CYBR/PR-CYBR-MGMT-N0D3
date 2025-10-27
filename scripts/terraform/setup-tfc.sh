#!/bin/bash
# Terraform Cloud Setup Script
# Configures Terraform Cloud integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f "../../.env" ]; then
    # shellcheck disable=SC1091
    source ../../.env
fi

echo -e "${GREEN}=== Terraform Cloud Setup ===${NC}\n"

# Check for required variables
if [ -z "$TFC_API_TOKEN" ]; then
    echo -e "${RED}Error: TFC_API_TOKEN not set in .env${NC}"
    exit 1
fi

if [ -z "$TFC_ORGANIZATION" ]; then
    echo -e "${RED}Error: TFC_ORGANIZATION not set in .env${NC}"
    exit 1
fi

if [ -z "$TFC_WORKSPACE" ]; then
    echo -e "${RED}Error: TFC_WORKSPACE not set in .env${NC}"
    exit 1
fi

echo "Organization: $TFC_ORGANIZATION"
echo "Workspace: $TFC_WORKSPACE"
echo ""

# Test API connection
echo "Testing Terraform Cloud API connection..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    --header "Authorization: Bearer $TFC_API_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/organizations/$TFC_ORGANIZATION")

if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ API connection successful${NC}"
else
    echo -e "${RED}✗ API connection failed (HTTP $RESPONSE)${NC}"
    exit 1
fi

# Check if workspace exists
echo ""
echo "Checking workspace..."
WORKSPACE_CHECK=$(curl -s \
    --header "Authorization: Bearer $TFC_API_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/organizations/$TFC_ORGANIZATION/workspaces/$TFC_WORKSPACE")

if echo "$WORKSPACE_CHECK" | grep -q '"id"'; then
    echo -e "${GREEN}✓ Workspace exists${NC}"
else
    echo -e "${YELLOW}Workspace does not exist${NC}"
    echo "Create workspace manually in Terraform Cloud or use Terraform to create it"
fi

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "Next steps:"
echo "1. Initialize Terraform: cd config/terraform && terraform init"
echo "2. Validate configuration: terraform validate"
echo "3. Plan changes: terraform plan"
echo "4. Apply changes: terraform apply"

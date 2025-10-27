#!/bin/bash
# Notion Documentation Sync Script
# Syncs markdown documentation to Notion workspace

set -e

# Load environment variables
if [ -f "../../.env" ]; then
    # shellcheck disable=SC1091
    source ../../.env
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Notion Documentation Sync ===${NC}\n"

# Check for required variables
if [ -z "$NOTION_API_KEY" ]; then
    echo -e "${RED}Error: NOTION_API_KEY not set in .env${NC}"
    exit 1
fi

if [ -z "$NOTION_DATABASE_ID" ]; then
    echo -e "${RED}Error: NOTION_DATABASE_ID not set in .env${NC}"
    exit 1
fi

echo "Database ID: $NOTION_DATABASE_ID"
echo ""

# Test API connection
echo "Testing Notion API connection..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X GET "https://api.notion.com/v1/databases/$NOTION_DATABASE_ID" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Notion-Version: 2022-06-28")

if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ API connection successful${NC}"
else
    echo -e "${RED}✗ API connection failed (HTTP $RESPONSE)${NC}"
    exit 1
fi

echo ""
echo "Syncing documentation to Notion..."

# This is a placeholder for the actual sync logic
# Full implementation would require a proper Notion API client
# For now, just list files that would be synced

echo ""
echo "Files to sync:"
find docs -name "*.md" -type f
find .specify -name "*.md" -type f
echo "README.md"

echo ""
echo -e "${YELLOW}Note: Full sync functionality requires Notion API client${NC}"
echo "Install notion-sdk-js or use a Python client for full implementation"

echo ""
echo -e "${GREEN}Sync check complete${NC}"

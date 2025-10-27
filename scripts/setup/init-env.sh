#!/bin/bash
# Environment Initialization Script
# Sets up the environment for PR-CYBR-MGMT-N0D3

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== PR-CYBR-MGMT-N0D3 Environment Initialization ===${NC}\n"

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}No .env file found. Creating from template...${NC}"
    if [ -f "config/.env.example" ]; then
        cp config/.env.example .env
        echo -e "${GREEN}.env file created from template${NC}"
    else
        echo -e "${RED}Error: config/.env.example not found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}.env file found${NC}"
fi

# Check for required tools
echo -e "\n${GREEN}Checking required tools...${NC}"

check_tool() {
    if command -v "$1" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "  ${RED}✗${NC} $1 (not found)"
        return 1
    fi
}

MISSING_TOOLS=0

check_tool "docker" || MISSING_TOOLS=$((MISSING_TOOLS + 1))
check_tool "curl" || MISSING_TOOLS=$((MISSING_TOOLS + 1))
check_tool "git" || MISSING_TOOLS=$((MISSING_TOOLS + 1))

# Optional tools
echo -e "\n${GREEN}Checking optional tools...${NC}"
check_tool "terraform" || echo -e "  ${YELLOW}Note: Terraform not found (optional)${NC}"

if [ $MISSING_TOOLS -gt 0 ]; then
    echo -e "\n${RED}Error: $MISSING_TOOLS required tool(s) missing${NC}"
    echo "Please install missing tools and try again"
    exit 1
fi

# Create directories if they don't exist
echo -e "\n${GREEN}Ensuring directory structure...${NC}"
mkdir -p docs/{SOPs,architecture}
mkdir -p scripts/{docker-swarm,terraform,integrations,setup}
mkdir -p config/{docker/stack-templates,terraform}
mkdir -p .specify/tasks

echo -e "${GREEN}✓ All directories created${NC}"

# Check Docker daemon
echo -e "\n${GREEN}Checking Docker daemon...${NC}"
if docker info &> /dev/null; then
    echo -e "${GREEN}✓ Docker daemon is running${NC}"
else
    echo -e "${YELLOW}⚠ Docker daemon not running or not accessible${NC}"
    echo "  Start Docker or ensure you have proper permissions"
fi

echo -e "\n${GREEN}=== Initialization complete! ===${NC}"
echo -e "\nNext steps:"
echo "1. Edit .env file with your configuration"
echo "2. Run ./scripts/setup/configure-secrets.sh to set up secrets"
echo "3. Review SOPs in docs/SOPs/"
echo "4. Follow the implementation plan in .specify/plan.md"

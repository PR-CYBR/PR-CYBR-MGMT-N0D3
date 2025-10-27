#!/bin/bash
# Update Services in Docker Swarm Script
# Updates or redeploys services in the swarm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Update Docker Swarm Services ===${NC}"

# Get stack name
if [ -z "$1" ]; then
    echo "Usage: $0 <stack-name> [compose-file]"
    echo ""
    echo "Available stacks:"
    docker stack ls
    exit 1
fi

STACK_NAME=$1
COMPOSE_FILE=${2:-}

# If compose file provided, redeploy the stack
if [ -n "$COMPOSE_FILE" ]; then
    if [ ! -f "$COMPOSE_FILE" ]; then
        echo -e "${RED}Error: Compose file '$COMPOSE_FILE' not found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Redeploying stack '$STACK_NAME' from $COMPOSE_FILE...${NC}"
    docker stack deploy -c "$COMPOSE_FILE" "$STACK_NAME"
else
    # Update all services in the stack
    echo -e "${YELLOW}Updating services in stack '$STACK_NAME'...${NC}"
    
    # Get all services in the stack
    SERVICES=$(docker stack services "$STACK_NAME" --format "{{.Name}}")
    
    if [ -z "$SERVICES" ]; then
        echo -e "${RED}Error: No services found in stack '$STACK_NAME'${NC}"
        exit 1
    fi
    
    # Update each service
    for SERVICE in $SERVICES; do
        echo "Updating service: $SERVICE"
        docker service update --force "$SERVICE"
    done
fi

echo -e "\n${GREEN}Update initiated${NC}"
echo ""
echo "Monitor update progress:"
echo "  docker stack ps $STACK_NAME"
echo ""
echo "Check service status:"
echo "  docker stack services $STACK_NAME"

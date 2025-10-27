#!/bin/bash
# Add Node to Docker Swarm Script
# Adds a worker or manager node to the swarm

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

echo -e "${GREEN}=== Add Node to Docker Swarm ===${NC}"

# Get node type
if [ -z "$1" ]; then
    echo "Usage: $0 <worker|manager> [node-ip]"
    echo "  worker  - Add a worker node"
    echo "  manager - Add a manager node"
    exit 1
fi

NODE_TYPE=$1
NODE_IP=${2:-}

# Validate node type
if [ "$NODE_TYPE" != "worker" ] && [ "$NODE_TYPE" != "manager" ]; then
    echo -e "${RED}Error: Node type must be 'worker' or 'manager'${NC}"
    exit 1
fi

# Get join token
if [ "$NODE_TYPE" = "worker" ]; then
    if [ -z "$SWARM_JOIN_TOKEN_WORKER" ]; then
        echo -e "${YELLOW}Getting worker join token...${NC}"
        JOIN_TOKEN=$(docker swarm join-token worker -q)
    else
        JOIN_TOKEN=$SWARM_JOIN_TOKEN_WORKER
    fi
else
    if [ -z "$SWARM_JOIN_TOKEN_MANAGER" ]; then
        echo -e "${YELLOW}Getting manager join token...${NC}"
        JOIN_TOKEN=$(docker swarm join-token manager -q)
    else
        JOIN_TOKEN=$SWARM_JOIN_TOKEN_MANAGER
    fi
fi

# Get manager IP
if [ -z "$SWARM_MANAGER_IP" ]; then
    MANAGER_IP=$(docker info --format '{{.Swarm.NodeAddr}}')
else
    MANAGER_IP=$SWARM_MANAGER_IP
fi

# Display join command
echo -e "\n${GREEN}Join command for $NODE_TYPE node:${NC}"
echo "docker swarm join --token $JOIN_TOKEN $MANAGER_IP:2377"

if [ -n "$NODE_IP" ]; then
    echo -e "\n${YELLOW}Note: Run this command on the node at $NODE_IP${NC}"
fi

echo -e "\n${GREEN}After the node joins, verify with:${NC}"
echo "docker node ls"

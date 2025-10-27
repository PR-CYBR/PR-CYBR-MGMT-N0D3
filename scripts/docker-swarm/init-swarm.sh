#!/bin/bash
# Docker Swarm Initialization Script
# Initializes a Docker Swarm cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Docker Swarm Initialization ===${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ] && ! groups | grep -q docker; then
    echo -e "${YELLOW}Warning: You may need to run this with sudo${NC}"
fi

# Get advertise address
if [ -z "$1" ]; then
    echo "Enter the IP address to advertise (leave empty for auto-detect):"
    read -r ADVERTISE_ADDR
else
    ADVERTISE_ADDR=$1
fi

# Initialize swarm
echo -e "${GREEN}Initializing Docker Swarm...${NC}"
if [ -z "$ADVERTISE_ADDR" ]; then
    docker swarm init
else
    docker swarm init --advertise-addr "$ADVERTISE_ADDR"
fi

# Get join tokens
echo -e "\n${GREEN}=== Join Tokens ===${NC}"
echo -e "${YELLOW}Worker Token:${NC}"
WORKER_TOKEN=$(docker swarm join-token worker -q)
echo "$WORKER_TOKEN"

echo -e "\n${YELLOW}Manager Token:${NC}"
MANAGER_TOKEN=$(docker swarm join-token manager -q)
echo "$MANAGER_TOKEN"

# Get manager IP
MANAGER_IP=$(docker info --format '{{.Swarm.NodeAddr}}')
echo -e "\n${YELLOW}Manager IP:${NC} $MANAGER_IP"

# Save to .env if exists
if [ -f "../../.env" ]; then
    echo -e "\n${GREEN}Updating .env file...${NC}"
    sed -i.bak "s|^SWARM_MANAGER_IP=.*|SWARM_MANAGER_IP=$MANAGER_IP|" ../../.env
    sed -i.bak "s|^SWARM_JOIN_TOKEN_WORKER=.*|SWARM_JOIN_TOKEN_WORKER=$WORKER_TOKEN|" ../../.env
    sed -i.bak "s|^SWARM_JOIN_TOKEN_MANAGER=.*|SWARM_JOIN_TOKEN_MANAGER=$MANAGER_TOKEN|" ../../.env
    rm ../../.env.bak 2>/dev/null || true
    echo -e "${GREEN}Environment file updated${NC}"
fi

echo -e "\n${GREEN}=== Swarm initialized successfully! ===${NC}"
echo -e "To add a worker node, run on the worker:"
echo -e "  docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377"
echo -e "\nTo add a manager node, run on the manager:"
echo -e "  docker swarm join --token $MANAGER_TOKEN $MANAGER_IP:2377"

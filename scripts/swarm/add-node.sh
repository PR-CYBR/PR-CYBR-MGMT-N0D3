#!/usr/bin/env bash

# add-node.sh - Add a new node to the Docker Swarm
# Usage: ./add-node.sh <node-ip> <role>
# role: worker or manager

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ "$#" -lt 2 ]; then
    log_error "Usage: $0 <node-ip> <role>"
    log_error "  role: worker or manager"
    exit 1
fi

NODE_IP="$1"
ROLE="$2"

# Validate role
if [[ ! "$ROLE" =~ ^(worker|manager)$ ]]; then
    log_error "Invalid role: $ROLE. Must be 'worker' or 'manager'"
    exit 1
fi

# Check if this node is a swarm manager
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    log_error "This node is not part of an active swarm"
    exit 1
fi

if ! docker node ls &>/dev/null; then
    log_error "This node is not a swarm manager"
    exit 1
fi

# Get join token
log_info "Getting join token for $ROLE..."
JOIN_TOKEN=$(docker swarm join-token "$ROLE" -q)
MANAGER_ADDR=$(docker info 2>/dev/null | grep -A1 "Swarm:" | grep "NodeAddr" | awk '{print $2}')

if [ -z "$MANAGER_ADDR" ]; then
    MANAGER_ADDR=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
fi

# Display join command
log_info "To add this node to the swarm, run the following command on $NODE_IP:"
echo ""
echo "  docker swarm join --token $JOIN_TOKEN $MANAGER_ADDR:2377"
echo ""

log_warn "After running the join command, verify with: docker node ls"

log_info "Node addition instructions complete!"

#!/usr/bin/env bash

# remove-node.sh - Remove a node from the Docker Swarm
# Usage: ./remove-node.sh <node-id-or-name>

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
if [ "$#" -lt 1 ]; then
    log_error "Usage: $0 <node-id-or-name>"
    exit 1
fi

NODE="$1"

# Check if this node is a swarm manager
if ! docker node ls &>/dev/null; then
    log_error "This node is not a swarm manager"
    exit 1
fi

# Check if node exists
if ! docker node inspect "$NODE" &>/dev/null; then
    log_error "Node not found: $NODE"
    exit 1
fi

# Get node info
NODE_ID=$(docker node inspect "$NODE" -f '{{.ID}}')
NODE_HOSTNAME=$(docker node inspect "$NODE" -f '{{.Description.Hostname}}')
NODE_ROLE=$(docker node inspect "$NODE" -f '{{.Spec.Role}}')
NODE_STATUS=$(docker node inspect "$NODE" -f '{{.Status.State}}')

log_info "Node details:"
echo "  ID: $NODE_ID"
echo "  Hostname: $NODE_HOSTNAME"
echo "  Role: $NODE_ROLE"
echo "  Status: $NODE_STATUS"
echo ""

# Drain the node first
log_info "Draining node $NODE_HOSTNAME..."
docker node update --availability drain "$NODE" || log_warn "Failed to drain node"

# Wait for services to be rescheduled
log_info "Waiting for services to be rescheduled..."
sleep 10

# Remove the node
log_info "Removing node from swarm..."
docker node rm "$NODE" || {
    log_error "Failed to remove node. It may still be running."
    log_error "On the node, run: docker swarm leave"
    exit 1
}

log_info "Node $NODE_HOSTNAME removed successfully!"
log_info "Current swarm nodes:"
docker node ls

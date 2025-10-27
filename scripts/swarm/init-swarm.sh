#!/usr/bin/env bash

# init-swarm.sh - Initialize Docker Swarm on this node
# Usage: ./init-swarm.sh [advertise-addr]

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get advertise address from argument or auto-detect
ADVERTISE_ADDR="${1:-}"

if [ -z "$ADVERTISE_ADDR" ]; then
    log_info "Auto-detecting advertise address..."
    ADVERTISE_ADDR=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
    log_info "Detected address: $ADVERTISE_ADDR"
fi

# Check if already part of a swarm
if docker info 2>/dev/null | grep -q "Swarm: active"; then
    log_warn "This node is already part of a swarm"
    docker node ls
    exit 0
fi

# Initialize swarm
log_info "Initializing Docker Swarm..."
docker swarm init --advertise-addr "$ADVERTISE_ADDR"

# Display join tokens
log_info "Swarm initialized successfully!"
echo ""
log_info "Worker join token:"
docker swarm join-token worker -q

echo ""
log_info "Manager join token:"
docker swarm join-token manager -q

# Create overlay networks
log_info "Creating overlay networks..."
docker network create --driver overlay --attachable management || log_warn "Network 'management' may already exist"
docker network create --driver overlay --attachable services || log_warn "Network 'services' may already exist"
docker network create --driver overlay --attachable monitoring || log_warn "Network 'monitoring' may already exist"

# List nodes
log_info "Current swarm nodes:"
docker node ls

log_info "Swarm initialization complete!"

#!/usr/bin/env bash

# deploy-service.sh - Deploy a service to the Docker Swarm
# Usage: ./deploy-service.sh <service-name> <image> [replicas]

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
    log_error "Usage: $0 <service-name> <image> [replicas]"
    exit 1
fi

SERVICE_NAME="$1"
IMAGE="$2"
REPLICAS="${3:-1}"

# Check if this node is a swarm manager
if ! docker node ls &>/dev/null; then
    log_error "This node is not a swarm manager"
    exit 1
fi

# Check if service already exists
if docker service inspect "$SERVICE_NAME" &>/dev/null; then
    log_warn "Service $SERVICE_NAME already exists"
    read -p "Do you want to update it? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deployment cancelled"
        exit 0
    fi
    
    log_info "Updating service $SERVICE_NAME..."
    docker service update --image "$IMAGE" "$SERVICE_NAME"
else
    log_info "Deploying service $SERVICE_NAME..."
    docker service create \
        --name "$SERVICE_NAME" \
        --replicas "$REPLICAS" \
        --network services \
        "$IMAGE"
fi

# Wait for service to converge
log_info "Waiting for service to converge..."
timeout=60
elapsed=0
while [ $elapsed -lt $timeout ]; do
    replicas=$(docker service ls --filter "name=$SERVICE_NAME" --format "{{.Replicas}}")
    if [[ "$replicas" == "$REPLICAS/$REPLICAS" ]]; then
        log_info "Service deployed successfully!"
        break
    fi
    sleep 2
    elapsed=$((elapsed + 2))
done

# Display service status
log_info "Service status:"
docker service ps "$SERVICE_NAME"

# Send Slack notification if configured
if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    scripts/integrations/slack-notify.sh \
        "Service $SERVICE_NAME deployed with $REPLICAS replicas" \
        "Service Deployment" \
        "good" 2>/dev/null || true
fi

log_info "Deployment complete!"

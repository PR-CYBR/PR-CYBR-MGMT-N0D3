#!/usr/bin/env bash

# scale-service.sh - Scale a service in the Docker Swarm
# Usage: ./scale-service.sh <service-name> <replicas>

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
if [ "$#" -ne 2 ]; then
    log_error "Usage: $0 <service-name> <replicas>"
    exit 1
fi

SERVICE_NAME="$1"
REPLICAS="$2"

# Validate replicas is a number
if ! [[ "$REPLICAS" =~ ^[0-9]+$ ]]; then
    log_error "Replicas must be a positive integer"
    exit 1
fi

# Check if this node is a swarm manager
if ! docker node ls &>/dev/null; then
    log_error "This node is not a swarm manager"
    exit 1
fi

# Check if service exists
if ! docker service inspect "$SERVICE_NAME" &>/dev/null; then
    log_error "Service not found: $SERVICE_NAME"
    exit 1
fi

# Get current replica count
CURRENT_REPLICAS=$(docker service inspect "$SERVICE_NAME" -f '{{.Spec.Mode.Replicated.Replicas}}')

log_info "Current replicas: $CURRENT_REPLICAS"
log_info "Target replicas: $REPLICAS"

if [ "$CURRENT_REPLICAS" -eq "$REPLICAS" ]; then
    log_warn "Service already has $REPLICAS replicas"
    exit 0
fi

# Scale the service
log_info "Scaling service $SERVICE_NAME to $REPLICAS replicas..."
docker service scale "$SERVICE_NAME=$REPLICAS"

# Wait for scaling to complete
log_info "Waiting for scaling to complete..."
timeout=60
elapsed=0
while [ $elapsed -lt $timeout ]; do
    current=$(docker service ls --filter "name=$SERVICE_NAME" --format "{{.Replicas}}" | cut -d'/' -f1)
    if [ "$current" == "$REPLICAS" ]; then
        log_info "Scaling complete!"
        break
    fi
    sleep 2
    elapsed=$((elapsed + 2))
done

# Display service status
log_info "Service status:"
docker service ps "$SERVICE_NAME" --filter "desired-state=running"

# Send Slack notification if configured
if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    scripts/integrations/slack-notify.sh \
        "Service $SERVICE_NAME scaled from $CURRENT_REPLICAS to $REPLICAS replicas" \
        "Service Scaling" \
        "good" 2>/dev/null || true
fi

log_info "Scale operation complete!"

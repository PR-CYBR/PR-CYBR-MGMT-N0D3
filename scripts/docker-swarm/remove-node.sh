#!/bin/bash
# Remove Node from Docker Swarm Script
# Gracefully removes a node from the swarm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Remove Node from Docker Swarm ===${NC}"

# Get node name
if [ -z "$1" ]; then
    echo "Usage: $0 <node-name-or-id>"
    echo ""
    echo "Available nodes:"
    docker node ls
    exit 1
fi

NODE=$1

# Check if node exists
if ! docker node inspect "$NODE" &>/dev/null; then
    echo -e "${RED}Error: Node '$NODE' not found${NC}"
    echo ""
    echo "Available nodes:"
    docker node ls
    exit 1
fi

# Get node status
NODE_STATUS=$(docker node inspect "$NODE" --format '{{.Status.State}}')
NODE_AVAILABILITY=$(docker node inspect "$NODE" --format '{{.Spec.Availability}}')
NODE_ROLE=$(docker node inspect "$NODE" --format '{{.Spec.Role}}')

echo "Node: $NODE"
echo "Status: $NODE_STATUS"
echo "Availability: $NODE_AVAILABILITY"
echo "Role: $NODE_ROLE"

# Warn if trying to remove a manager
if [ "$NODE_ROLE" = "manager" ]; then
    echo -e "${YELLOW}Warning: This is a manager node!${NC}"
    echo "Removing manager nodes can affect cluster quorum."
    echo -n "Are you sure? (yes/no): "
    read -r CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Aborted."
        exit 0
    fi
fi

# Drain the node
echo -e "\n${YELLOW}Draining node...${NC}"
docker node update --availability drain "$NODE"

echo "Waiting for tasks to migrate..."
sleep 5

# Show remaining tasks
TASK_COUNT=$(docker node ps "$NODE" -q | wc -l)
if [ "$TASK_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}Warning: Node still has $TASK_COUNT task(s)${NC}"
    docker node ps "$NODE"
    echo ""
    echo "Wait for tasks to complete, then run this script again."
    exit 0
fi

echo -e "${GREEN}Node drained successfully${NC}"

# Confirm removal
echo ""
echo -n "Remove node from swarm? (yes/no): "
read -r CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Node has been drained but not removed."
    echo "To re-enable the node: docker node update --availability active $NODE"
    exit 0
fi

# Remove the node
echo -e "\n${YELLOW}Removing node from swarm...${NC}"

# If node is down, force remove
if [ "$NODE_STATUS" != "ready" ]; then
    echo "Node is not ready, forcing removal..."
    docker node rm --force "$NODE"
else
    # Try to leave from the node first (if accessible)
    echo "Attempting to leave swarm from node..."
    # This would need SSH access to the node
    # For now, just remove from manager
    docker node rm "$NODE"
fi

echo -e "${GREEN}Node removed successfully${NC}"
echo ""
echo "Remaining nodes:"
docker node ls

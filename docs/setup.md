# Setup Guide

This guide walks you through setting up the PR-CYBR Management Node from scratch.

## Prerequisites

Before beginning, ensure you have:

- A Linux server (Ubuntu 20.04+ or similar recommended)
- Docker Engine 20.10 or higher installed
- Bash 4.0 or higher
- Git 2.20 or higher
- Root or sudo access
- Open network ports: 2377, 7946, 4789
- (Optional) API tokens for integrations: TFC, Notion, Slack

## Step 1: Install Docker

If Docker is not already installed:

```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Verify installation
sudo docker --version
```

## Step 2: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3.git
cd PR-CYBR-MGMT-N0D3
```

## Step 3: Configure Environment Variables

```bash
# Copy the environment template
cp config/templates/.env.template .env

# Edit the .env file
nano .env
```

Configure the following critical variables:

```bash
# Docker Swarm
SWARM_MANAGER_IP=<your-server-ip>

# Terraform Cloud (if using)
TFC_API_TOKEN=<your-tfc-token>
TFC_ORGANIZATION=PR-CYBR
TFC_WORKSPACE=pr-cybr-mgmt-node

# Notion (if using)
NOTION_API_TOKEN=<your-notion-token>
NOTION_DATABASE_ID=<your-database-id>

# Slack (if using)
SLACK_WEBHOOK_URL=<your-webhook-url>
```

## Step 4: Configure Firewall

Open required ports for Docker Swarm:

```bash
# For Ubuntu with ufw
sudo ufw allow 2377/tcp  # Swarm management
sudo ufw allow 7946/tcp  # Container network discovery
sudo ufw allow 7946/udp  # Container network discovery
sudo ufw allow 4789/udp  # Overlay network traffic

# For firewalld (RHEL/CentOS)
sudo firewall-cmd --permanent --add-port=2377/tcp
sudo firewall-cmd --permanent --add-port=7946/tcp
sudo firewall-cmd --permanent --add-port=7946/udp
sudo firewall-cmd --permanent --add-port=4789/udp
sudo firewall-cmd --reload
```

## Step 5: Initialize Docker Swarm

```bash
# Run the initialization script
sudo ./scripts/swarm/init-swarm.sh
```

This script will:
- Initialize the Docker Swarm on this node
- Create overlay networks (management, services, monitoring)
- Display join tokens for worker and manager nodes
- List current swarm nodes

Save the join tokens displayed - you'll need them to add nodes later.

## Step 6: Verify Installation

```bash
# Check swarm status
sudo docker node ls

# Check networks
sudo docker network ls | grep -E "management|services|monitoring"

# Test a simple service deployment
sudo ./scripts/swarm/deploy-service.sh test-service nginx:alpine 1

# Check service status
sudo docker service ls

# Clean up test service
sudo docker service rm test-service
```

## Step 7: (Optional) Add Worker Nodes

On each worker node you want to add:

1. Install Docker (same as Step 1)
2. Get the worker join token from the manager:
   ```bash
   sudo docker swarm join-token worker
   ```
3. Run the join command on the worker node

From the management node, verify:
```bash
sudo docker node ls
```

## Step 8: (Optional) Configure Integrations

### Terraform Cloud Integration

1. Create a workspace in Terraform Cloud
2. Configure VCS integration or API-driven workflow
3. Set environment variables in TFC workspace
4. Test the integration:
   ```bash
   ./scripts/integrations/tfc-sync.sh status
   ```

### Notion Integration

1. Create a Notion integration at https://www.notion.so/my-integrations
2. Get the API token and database ID
3. Test the integration:
   ```bash
   ./scripts/integrations/notion-sync.sh README.md
   ```

### Slack Integration

1. Create an incoming webhook in your Slack workspace
2. Add the webhook URL to .env
3. Test the integration:
   ```bash
   ./scripts/integrations/slack-notify.sh "Test message" "Setup Test"
   ```

## Step 9: Deploy Services

You can now deploy your services using Docker Compose or the deployment script:

```bash
# Using docker-compose
sudo docker stack deploy -c config/docker/docker-compose.yml pr-cybr

# Or using the deployment script
sudo ./scripts/swarm/deploy-service.sh my-service my-image:tag 3
```

## Step 10: Set Up Monitoring (Future)

Monitoring and logging setup will be added in a future phase. Check `.specify/plan.md` for the roadmap.

## Troubleshooting

### Swarm Won't Initialize

- Check Docker is running: `sudo systemctl status docker`
- Verify network connectivity
- Check firewall rules are correct
- Try specifying advertise address explicitly: `./scripts/swarm/init-swarm.sh <your-ip>`

### Can't Add Nodes

- Ensure worker nodes can reach manager on port 2377
- Check firewall rules on both manager and worker
- Verify join token is correct
- Check Docker is running on worker node

### Services Won't Deploy

- Check swarm is active: `docker info | grep Swarm`
- Verify overlay networks exist: `docker network ls`
- Check for image pull errors: `docker service ps <service-name>`
- Review service logs: `docker service logs <service-name>`

### Integration Scripts Fail

- Verify environment variables are set: `echo $SLACK_WEBHOOK_URL`
- Check API tokens are valid
- Test network connectivity to external services
- Review script output for specific error messages

## Next Steps

- Review the [Deployment Guide](deployment.md) for deploying services
- Check [BRANCHING.md](../BRANCHING.md) for development workflow
- Read `.specify/spec.md` for technical specifications
- See `.specify/plan.md` for implementation roadmap

## Getting Help

- Open an issue on GitHub
- Check existing issues for similar problems
- Review documentation in `.specify/` directory
- Check logs: `docker service logs <service-name>`

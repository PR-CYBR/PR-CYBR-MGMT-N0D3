# Deployment Guide

This guide covers deploying services to the PR-CYBR Docker Swarm cluster.

## Deployment Methods

There are several ways to deploy services:

1. **Docker Stack Deploy** - Using docker-compose.yml files
2. **Deployment Script** - Using the provided shell script
3. **Manual Docker Service** - Direct docker service commands
4. **CI/CD Pipeline** - Automated deployment via GitHub Actions

## Method 1: Docker Stack Deploy

### Basic Stack Deployment

```bash
# Deploy a stack
sudo docker stack deploy -c config/docker/docker-compose.yml pr-cybr

# List stacks
sudo docker stack ls

# List services in a stack
sudo docker stack services pr-cybr

# Remove a stack
sudo docker stack rm pr-cybr
```

### Example docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - services
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == worker

networks:
  services:
    external: true
```

## Method 2: Deployment Script

### Deploy a Service

```bash
# Basic deployment
sudo ./scripts/swarm/deploy-service.sh my-service my-image:tag

# Deploy with specific replica count
sudo ./scripts/swarm/deploy-service.sh my-service my-image:tag 5

# The script will:
# - Check if service exists
# - Deploy or update the service
# - Wait for convergence
# - Send Slack notification (if configured)
```

### Scale a Service

```bash
# Scale to specific replica count
sudo ./scripts/swarm/scale-service.sh my-service 10

# Scale down
sudo ./scripts/swarm/scale-service.sh my-service 1
```

## Method 3: Manual Docker Service Commands

### Create Service

```bash
sudo docker service create \
  --name my-service \
  --replicas 3 \
  --network services \
  --env MY_VAR=value \
  --publish 8080:80 \
  my-image:tag
```

### Update Service

```bash
# Update image
sudo docker service update --image my-image:new-tag my-service

# Update environment variable
sudo docker service update --env-add NEW_VAR=value my-service

# Update replica count
sudo docker service update --replicas 5 my-service
```

### Rolling Updates

```bash
# Configure update behavior
sudo docker service update \
  --update-parallelism 2 \
  --update-delay 10s \
  --update-failure-action rollback \
  --image my-image:new-tag \
  my-service
```

### Rollback

```bash
# Rollback to previous version
sudo docker service update --rollback my-service
```

## Method 4: CI/CD Deployment

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [ prod ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Swarm
        run: |
          # Add deployment commands
          # This would typically involve SSH or Docker context
          echo "Deploy to production swarm"
```

## Service Configuration

### Environment Variables

Pass environment variables to services:

```bash
# Via command line
sudo docker service create \
  --env MY_VAR=value \
  --env-file .env \
  my-service my-image:tag

# Via compose file
services:
  my-service:
    environment:
      - MY_VAR=value
    env_file:
      - .env
```

### Secrets

Use Docker secrets for sensitive data:

```bash
# Create a secret
echo "my-secret-value" | sudo docker secret create my-secret -

# Use secret in service
sudo docker service create \
  --name my-service \
  --secret my-secret \
  my-image:tag

# In compose file
services:
  my-service:
    secrets:
      - my-secret

secrets:
  my-secret:
    external: true
```

### Configs

Use Docker configs for non-sensitive configuration:

```bash
# Create a config
sudo docker config create nginx-config nginx.conf

# Use config in service
sudo docker service create \
  --name web \
  --config source=nginx-config,target=/etc/nginx/nginx.conf \
  nginx:alpine
```

### Volumes

Persist data with volumes:

```bash
# Create a volume
sudo docker volume create my-data

# Use in service
sudo docker service create \
  --name my-service \
  --mount type=volume,source=my-data,target=/data \
  my-image:tag
```

## Networking

### Overlay Networks

Services communicate via overlay networks:

```bash
# Create network
sudo docker network create --driver overlay my-network

# Attach service to network
sudo docker service update --network-add my-network my-service
```

### Port Publishing

Expose services externally:

```bash
# Publish port
sudo docker service create \
  --name web \
  --publish 80:8080 \
  my-image:tag

# Use ingress mode (default)
# Traffic to any swarm node on port 80 routes to the service
```

## Monitoring Deployments

### Check Service Status

```bash
# List services
sudo docker service ls

# Inspect service
sudo docker service inspect my-service

# Check service logs
sudo docker service logs my-service

# Follow logs
sudo docker service logs -f my-service
```

### Check Tasks

```bash
# List tasks for a service
sudo docker service ps my-service

# Show only running tasks
sudo docker service ps --filter "desired-state=running" my-service

# Show failed tasks
sudo docker service ps --filter "desired-state=failed" my-service
```

### Troubleshoot Failed Deployments

```bash
# Check service events
sudo docker service ps my-service --no-trunc

# Check node events
sudo docker node ps <node-id>

# Inspect task failure
sudo docker inspect <task-id>

# Check node logs
sudo journalctl -u docker.service
```

## Best Practices

### Health Checks

Always include health checks:

```yaml
services:
  my-service:
    image: my-image:tag
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Resource Limits

Set resource constraints:

```yaml
services:
  my-service:
    image: my-image:tag
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### Update Strategy

Configure update behavior:

```yaml
services:
  my-service:
    image: my-image:tag
    deploy:
      update_config:
        parallelism: 2
        delay: 10s
        failure_action: rollback
        monitor: 60s
        max_failure_ratio: 0.3
```

### Placement Constraints

Control where services run:

```yaml
services:
  my-service:
    image: my-image:tag
    deploy:
      placement:
        constraints:
          - node.role == worker
          - node.labels.environment == production
```

## Zero-Downtime Deployments

1. Use rolling updates (default)
2. Set appropriate update delay
3. Configure health checks
4. Use multiple replicas
5. Enable automatic rollback

```yaml
services:
  my-service:
    image: my-image:tag
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      rollback_config:
        parallelism: 1
        delay: 0s
```

## Cleanup

### Remove Services

```bash
# Remove a service
sudo docker service rm my-service

# Remove all services
sudo docker service rm $(sudo docker service ls -q)
```

### Clean Up Resources

```bash
# Remove unused images
sudo docker image prune -a

# Remove unused volumes
sudo docker volume prune

# Remove unused networks
sudo docker network prune
```

## Next Steps

- Set up monitoring (see `.specify/plan.md`)
- Configure CI/CD pipelines
- Implement automated testing
- Set up log aggregation
- Configure alerting

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for common issues and solutions.

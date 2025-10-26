# Troubleshooting Guide

This guide covers common issues and their solutions for the PR-CYBR Management Node.

## Docker Swarm Issues

### Swarm Won't Initialize

**Symptoms:**
- `docker swarm init` fails
- Error: "could not choose an IP address to advertise"

**Solutions:**

1. Specify the advertise address explicitly:
   ```bash
   sudo docker swarm init --advertise-addr <your-ip>
   ```

2. Check Docker is running:
   ```bash
   sudo systemctl status docker
   sudo systemctl start docker
   ```

3. Verify network interfaces:
   ```bash
   ip addr show
   ```

4. Check for existing swarm:
   ```bash
   sudo docker swarm leave --force
   sudo docker swarm init --advertise-addr <your-ip>
   ```

### Cannot Add Worker Nodes

**Symptoms:**
- Join command fails on worker
- Error: "could not connect to manager"

**Solutions:**

1. Verify network connectivity:
   ```bash
   # From worker, test connection to manager
   nc -zv <manager-ip> 2377
   ```

2. Check firewall rules:
   ```bash
   # On manager
   sudo ufw status
   sudo ufw allow 2377/tcp
   sudo ufw allow 7946/tcp
   sudo ufw allow 7946/udp
   sudo ufw allow 4789/udp
   ```

3. Regenerate join token:
   ```bash
   # On manager
   sudo docker swarm join-token worker
   ```

4. Check Docker version compatibility:
   ```bash
   docker --version  # Should match on manager and worker
   ```

### Node Shows as "Down"

**Symptoms:**
- `docker node ls` shows node status as "Down"

**Solutions:**

1. Check node connectivity:
   ```bash
   ping <node-ip>
   ```

2. Verify Docker is running on the node:
   ```bash
   # SSH to the node
   sudo systemctl status docker
   ```

3. Check node's swarm status:
   ```bash
   # On the node
   sudo docker info | grep Swarm
   ```

4. If node is truly offline, remove it:
   ```bash
   # On manager
   sudo docker node rm <node-id> --force
   ```

## Service Deployment Issues

### Service Won't Start

**Symptoms:**
- Service shows 0/N replicas
- Tasks keep restarting

**Solutions:**

1. Check service status:
   ```bash
   sudo docker service ps <service-name> --no-trunc
   ```

2. View service logs:
   ```bash
   sudo docker service logs <service-name>
   ```

3. Check image availability:
   ```bash
   # Try pulling image manually
   sudo docker pull <image-name>
   ```

4. Verify network configuration:
   ```bash
   sudo docker network ls
   sudo docker network inspect <network-name>
   ```

5. Check resource constraints:
   ```bash
   # Remove resource limits temporarily
   sudo docker service update --limit-memory 0 --limit-cpu 0 <service-name>
   ```

### Image Pull Failures

**Symptoms:**
- Error: "image not found"
- Error: "unauthorized: authentication required"

**Solutions:**

1. Login to registry:
   ```bash
   sudo docker login ghcr.io
   # or
   sudo docker login
   ```

2. Use full image path:
   ```bash
   # Instead of: nginx
   # Use: ghcr.io/pr-cybr/nginx:latest
   ```

3. Check image exists:
   ```bash
   docker search <image-name>
   ```

4. Use registry credentials in swarm:
   ```bash
   sudo docker service update --with-registry-auth <service-name>
   ```

### Port Conflicts

**Symptoms:**
- Error: "port is already allocated"

**Solutions:**

1. Check what's using the port:
   ```bash
   sudo lsof -i :<port-number>
   # or
   sudo netstat -tlnp | grep <port-number>
   ```

2. Change service port:
   ```bash
   sudo docker service update --publish-rm <old-port>:80 --publish-add <new-port>:80 <service-name>
   ```

3. Remove conflicting service:
   ```bash
   sudo docker service rm <conflicting-service>
   ```

## Networking Issues

### Services Can't Communicate

**Symptoms:**
- Services can't reach each other
- DNS resolution fails

**Solutions:**

1. Verify services are on same network:
   ```bash
   sudo docker service inspect <service-name> | grep -A10 Networks
   ```

2. Test DNS resolution:
   ```bash
   # From inside a container
   nslookup <service-name>
   ```

3. Recreate overlay network:
   ```bash
   sudo docker network rm <network-name>
   sudo docker network create --driver overlay --attachable <network-name>
   ```

4. Check network connectivity:
   ```bash
   # Between nodes
   ping <node-ip>
   ```

### Overlay Network Issues

**Symptoms:**
- Error: "network not found"
- Services can't join network

**Solutions:**

1. List available networks:
   ```bash
   sudo docker network ls
   ```

2. Create network if missing:
   ```bash
   sudo docker network create --driver overlay --attachable <network-name>
   ```

3. Verify network driver:
   ```bash
   sudo docker network inspect <network-name> | grep Driver
   ```

## Script Issues

### Script Permission Denied

**Symptoms:**
- Error: "Permission denied"

**Solutions:**

1. Make script executable:
   ```bash
   chmod +x scripts/swarm/*.sh
   chmod +x scripts/integrations/*.sh
   ```

2. Run with sudo if needed:
   ```bash
   sudo ./scripts/swarm/init-swarm.sh
   ```

### Script Won't Find Docker

**Symptoms:**
- Error: "docker: command not found"

**Solutions:**

1. Add user to docker group:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. Use full path to docker:
   ```bash
   /usr/bin/docker --version
   ```

3. Verify Docker installation:
   ```bash
   which docker
   docker --version
   ```

## Integration Issues

### Slack Notifications Not Working

**Symptoms:**
- No messages appear in Slack
- Script completes without error

**Solutions:**

1. Verify webhook URL is set:
   ```bash
   echo $SLACK_WEBHOOK_URL
   ```

2. Test webhook manually:
   ```bash
   curl -X POST $SLACK_WEBHOOK_URL \
     -H 'Content-Type: application/json' \
     -d '{"text":"Test message"}'
   ```

3. Check .env file is sourced:
   ```bash
   source .env
   ./scripts/integrations/slack-notify.sh "Test"
   ```

4. Verify webhook URL is valid in Slack settings

### Terraform Cloud Connection Fails

**Symptoms:**
- Error: "unauthorized"
- Error: "workspace not found"

**Solutions:**

1. Verify API token:
   ```bash
   echo $TFC_API_TOKEN
   ```

2. Test API connection:
   ```bash
   curl -H "Authorization: Bearer $TFC_API_TOKEN" \
     https://app.terraform.io/api/v2/account/details
   ```

3. Check organization and workspace names:
   ```bash
   ./scripts/integrations/tfc-sync.sh status
   ```

4. Verify token has correct permissions in TFC

### Notion Sync Fails

**Symptoms:**
- Error: "API token invalid"
- Error: "page not found"

**Solutions:**

1. Verify API token:
   ```bash
   echo $NOTION_API_TOKEN
   ```

2. Check page permissions in Notion

3. Verify database ID is correct:
   ```bash
   echo $NOTION_DATABASE_ID
   ```

4. Test API access:
   ```bash
   curl -X GET https://api.notion.com/v1/databases/$NOTION_DATABASE_ID \
     -H "Authorization: Bearer $NOTION_API_TOKEN" \
     -H "Notion-Version: 2022-06-28"
   ```

## GitHub Actions Issues

### Workflow Fails

**Symptoms:**
- Workflow shows red X
- Build or test failures

**Solutions:**

1. Check workflow logs:
   - Go to Actions tab in GitHub
   - Click on failed workflow
   - Review step-by-step logs

2. Run locally:
   ```bash
   # For lint
   shellcheck scripts/**/*.sh
   yamllint .github/workflows/
   markdownlint '**/*.md'
   ```

3. Check secrets are configured:
   - Settings → Secrets and variables → Actions
   - Verify required secrets exist

4. Verify workflow syntax:
   ```bash
   # Use GitHub CLI
   gh workflow view
   ```

### Secret Scanning Alerts

**Symptoms:**
- Workflow blocked by secret detection
- Gitleaks finds exposed secrets

**Solutions:**

1. Never commit actual secrets
2. Use .env files (in .gitignore)
3. Remove secrets from history:
   ```bash
   # Use git-filter-repo or BFG Repo-Cleaner
   git filter-repo --path <file-with-secret> --invert-paths
   ```

4. Rotate exposed secrets immediately

## Performance Issues

### High Memory Usage

**Symptoms:**
- Nodes run out of memory
- Services get OOMKilled

**Solutions:**

1. Set memory limits:
   ```bash
   sudo docker service update --limit-memory 512M <service-name>
   ```

2. Check memory usage:
   ```bash
   docker stats
   ```

3. Scale down replicas:
   ```bash
   ./scripts/swarm/scale-service.sh <service-name> 1
   ```

4. Add more worker nodes

### High CPU Usage

**Symptoms:**
- Nodes at 100% CPU
- Services slow to respond

**Solutions:**

1. Set CPU limits:
   ```bash
   sudo docker service update --limit-cpu 0.5 <service-name>
   ```

2. Check CPU usage:
   ```bash
   docker stats
   top
   ```

3. Identify problematic service:
   ```bash
   docker service ps <service-name>
   ```

4. Scale horizontally instead of vertically

## Storage Issues

### Disk Space Full

**Symptoms:**
- Error: "no space left on device"
- Cannot pull images

**Solutions:**

1. Check disk usage:
   ```bash
   df -h
   docker system df
   ```

2. Clean up Docker resources:
   ```bash
   docker system prune -a
   docker volume prune
   docker image prune -a
   ```

3. Remove old images:
   ```bash
   docker image ls
   docker image rm <image-id>
   ```

4. Clean up logs:
   ```bash
   sudo journalctl --vacuum-time=7d
   ```

## Getting More Help

### Collect Diagnostic Information

```bash
# System info
uname -a
docker version
docker info

# Swarm status
docker node ls
docker service ls
docker network ls

# Logs
docker service logs <service-name>
journalctl -u docker.service -n 100

# Resource usage
docker stats --no-stream
df -h
free -h
```

### Where to Get Help

1. Check GitHub Issues: https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/issues
2. Review documentation in `.specify/` directory
3. Check Docker documentation: https://docs.docker.com/
4. Open a new issue with diagnostic information

### Creating a Good Bug Report

Include:
1. Description of the problem
2. Steps to reproduce
3. Expected behavior
4. Actual behavior
5. Environment details (OS, Docker version)
6. Relevant logs
7. Configuration files (redact secrets)

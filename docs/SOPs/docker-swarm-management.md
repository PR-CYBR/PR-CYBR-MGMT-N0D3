# Docker Swarm Management SOP

## Overview

This Standard Operating Procedure (SOP) covers the management of Docker Swarm clusters for the PR-CYBR distributed architecture.

## Prerequisites

- Docker Engine installed on all nodes (version 20.10 or higher)
- Network connectivity between nodes
- Appropriate firewall rules configured
- Root or sudo access on all nodes

## Required Ports

- **2377/tcp**: Cluster management communications
- **7946/tcp & udp**: Communication among nodes
- **4789/udp**: Overlay network traffic

## Initializing a Swarm Cluster

### Procedure

1. **Select the manager node**

   Choose a node to act as the swarm manager. This should be a stable, reliable machine.

2. **Initialize the swarm**

   ```bash
   ./scripts/docker-swarm/init-swarm.sh
   ```

   Or manually:

   ```bash
   docker swarm init --advertise-addr <MANAGER-IP>
   ```

3. **Save the join tokens**

   After initialization, Docker outputs join tokens for workers and managers. Save these securely:

   ```bash
   # Worker token
   docker swarm join-token worker

   # Manager token (for adding additional managers)
   docker swarm join-token manager
   ```

4. **Store tokens in environment**

   Add tokens to your `.env` file:

   ```bash
   SWARM_JOIN_TOKEN_WORKER=SWMTKN-1-xxxxx
   SWARM_JOIN_TOKEN_MANAGER=SWMTKN-1-xxxxx
   SWARM_MANAGER_IP=192.168.1.100
   ```

## Adding Nodes to the Swarm

### Adding a Worker Node

1. **Prepare the worker node**

   - Install Docker
   - Configure firewall rules
   - Ensure network connectivity to manager

2. **Add the node**

   ```bash
   ./scripts/docker-swarm/add-node.sh worker <NODE-IP>
   ```

   Or manually on the worker node:

   ```bash
   docker swarm join --token <WORKER-TOKEN> <MANAGER-IP>:2377
   ```

3. **Verify the node joined**

   On the manager:

   ```bash
   docker node ls
   ```

### Adding a Manager Node

For high availability, add additional manager nodes:

1. **Prepare the manager node**

   Same as worker preparation

2. **Add the node**

   ```bash
   ./scripts/docker-swarm/add-node.sh manager <NODE-IP>
   ```

   Or manually on the new manager:

   ```bash
   docker swarm join --token <MANAGER-TOKEN> <MANAGER-IP>:2377
   ```

3. **Verify the manager joined**

   ```bash
   docker node ls
   ```

### Best Practices for Manager Nodes

- Use an odd number of managers (1, 3, 5, 7)
- Maximum recommended: 7 manager nodes
- Distribute managers across failure domains
- Minimum for HA: 3 managers

## Removing Nodes from the Swarm

### Graceful Node Removal

1. **Drain the node**

   This moves all tasks off the node:

   ```bash
   ./scripts/docker-swarm/remove-node.sh <NODE-NAME>
   ```

   Or manually:

   ```bash
   docker node update --availability drain <NODE-NAME>
   ```

2. **Wait for tasks to migrate**

   Monitor task status:

   ```bash
   docker service ps <SERVICE-NAME>
   ```

3. **Leave the swarm**

   On the node to be removed:

   ```bash
   docker swarm leave
   ```

4. **Remove the node from the swarm**

   On the manager:

   ```bash
   docker node rm <NODE-NAME>
   ```

### Force Removal (Emergency)

If a node is unresponsive:

```bash
docker node rm --force <NODE-NAME>
```

**Warning**: Force removal may cause task disruption.

## Deploying Services

### Using Stack Files

1. **Prepare your stack file**

   Example: `config/docker/stack-templates/web-app.yml`

2. **Deploy the stack**

   ```bash
   docker stack deploy -c config/docker/stack-templates/web-app.yml web-app
   ```

3. **Verify deployment**

   ```bash
   docker stack ps web-app
   docker stack services web-app
   ```

### Updating Services

1. **Update the stack file**

2. **Redeploy**

   ```bash
   ./scripts/docker-swarm/update-services.sh web-app
   ```

   Or manually:

   ```bash
   docker stack deploy -c config/docker/stack-templates/web-app.yml web-app
   ```

## Managing Secrets

### Creating Secrets

```bash
echo "my-secret-password" | docker secret create db_password -
```

Or from a file:

```bash
docker secret create db_password ./secrets/db_password.txt
```

### Using Secrets in Services

In your stack file:

```yaml
version: '3.8'
services:
  db:
    image: postgres:latest
    secrets:
      - db_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    external: true
```

## Monitoring the Swarm

### Check Swarm Status

```bash
docker info | grep Swarm
```

### List Nodes

```bash
docker node ls
```

### Inspect a Node

```bash
docker node inspect <NODE-NAME>
```

### View Service Logs

```bash
docker service logs <SERVICE-NAME>
```

### Monitor Service Status

```bash
docker service ps <SERVICE-NAME>
```

## Troubleshooting

### Node Not Joining Swarm

**Symptoms**: `docker swarm join` fails

**Solutions**:

1. Check firewall rules (ports 2377, 7946, 4789)
2. Verify network connectivity: `ping <MANAGER-IP>`
3. Check Docker daemon is running: `systemctl status docker`
4. Verify join token is correct
5. Check Docker logs: `journalctl -u docker.service`

### Service Not Starting

**Symptoms**: Service shows as "pending" or repeatedly restarts

**Solutions**:

1. Check service logs: `docker service logs <SERVICE-NAME>`
2. Inspect service: `docker service inspect <SERVICE-NAME>`
3. Verify resource availability on nodes
4. Check for image pull errors
5. Verify network connectivity

### Manager Node Down

**Symptoms**: Swarm becomes unresponsive

**Solutions**:

1. If you have multiple managers, promote a worker:
   ```bash
   docker node promote <WORKER-NODE>
   ```
2. Restart Docker daemon on manager nodes
3. Check manager node health
4. If quorum is lost, may need to force new cluster (last resort)

### Network Issues

**Symptoms**: Services can't communicate

**Solutions**:

1. Verify overlay network exists: `docker network ls`
2. Check network driver: `docker network inspect <NETWORK-NAME>`
3. Ensure port 4789/udp is open
4. Check encryption settings if using encrypted networks

## Backup and Recovery

### Backup Manager State

On the manager node:

```bash
sudo systemctl stop docker
sudo tar -czvf swarm-backup-$(date +%Y%m%d).tar.gz /var/lib/docker/swarm
sudo systemctl start docker
```

### Restore Manager State

**Warning**: Only restore to a single manager node first

```bash
sudo systemctl stop docker
sudo rm -rf /var/lib/docker/swarm
sudo tar -xzvf swarm-backup-YYYYMMDD.tar.gz -C /
sudo systemctl start docker
docker swarm init --force-new-cluster
```

## Security Best Practices

1. **Use encrypted overlay networks**

   ```bash
   docker network create --opt encrypted --driver overlay my-network
   ```

2. **Regularly rotate join tokens**

   ```bash
   docker swarm join-token --rotate worker
   docker swarm join-token --rotate manager
   ```

3. **Use Docker secrets for sensitive data**

4. **Enable auto-lock for managers**

   ```bash
   docker swarm update --autolock=true
   ```

5. **Limit manager node access**

6. **Keep Docker updated**

## Maintenance Schedule

### Daily

- Monitor service health
- Check resource utilization

### Weekly

- Review node status
- Check for Docker updates
- Review service logs

### Monthly

- Rotate join tokens
- Backup manager state
- Review and update security policies
- Test disaster recovery procedures

## References

- [Docker Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- PR-CYBR Architecture Documentation: `docs/architecture/system-overview.md`

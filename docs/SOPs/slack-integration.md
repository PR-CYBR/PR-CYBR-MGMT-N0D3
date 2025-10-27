# Slack Integration SOP

## Overview

This SOP covers the integration of Slack for automated notifications from PR-CYBR-MGMT-N0D3.

## Prerequisites

- Slack workspace admin access
- Slack channel for notifications

## Setup

### 1. Create Incoming Webhook

1. Go to [https://api.slack.com/apps](https://api.slack.com/apps)
2. Click "Create New App" → "From scratch"
3. App name: `PR-CYBR Notifications`
4. Select workspace
5. Click "Incoming Webhooks"
6. Toggle "Activate Incoming Webhooks" to On
7. Click "Add New Webhook to Workspace"
8. Select channel (e.g., `#pr-cybr-alerts`)
9. Copy webhook URL

### 2. Configure Secrets

1. Store webhook in GitHub Secrets: `SLACK_WEBHOOK_URL`
2. Add to `.env`:

   ```bash
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxx/yyy/zzz
   SLACK_CHANNEL=#pr-cybr-alerts
   ```

## Notification Types

### Docker Swarm Events

- Node join/leave
- Service deployment
- Service updates
- Health check failures

### Terraform Cloud Events

- Plan started/completed
- Apply started/completed
- Run errors
- Policy violations

### CI/CD Events

- Workflow started/completed
- Build success/failure
- Deployment status
- Test results

### Security Alerts

- Vulnerability scans
- Secret detection
- Access anomalies

## Usage

### Send Manual Notification

```bash
./scripts/integrations/slack-notify.sh "Your message here"
```

### Send with Severity

```bash
./scripts/integrations/slack-notify.sh "Critical error" "error"
```

Severity levels:

- `info`: Blue (default)
- `success`: Green
- `warning`: Yellow
- `error`: Red

### From Workflows

In GitHub Actions:

```yaml
- name: Notify Slack
  run: |
    ./scripts/integrations/slack-notify.sh "Deployment completed" "success"
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## Message Format

Messages include:

- Timestamp
- Severity indicator
- Message text
- Source (workflow/script name)
- Link to relevant resource

## Troubleshooting

### Webhook Not Working

**Solution**: Verify webhook URL is correct and active

### Messages Not Appearing

**Solution**: Check channel permissions and app installation

### Rate Limiting

**Solution**: Reduce notification frequency, batch messages

## References

- [Slack API Documentation](https://api.slack.com/)
- PR-CYBR Architecture: `docs/architecture/system-overview.md`

# Terraform Cloud Setup SOP

## Overview

This Standard Operating Procedure (SOP) covers the setup and integration of Terraform Cloud with PR-CYBR-MGMT-N0D3 for infrastructure automation.

## Prerequisites

- Terraform Cloud account (free or paid tier)
- GitHub account with access to PR-CYBR-MGMT-N0D3 repository
- Terraform CLI installed locally (version 1.0+)
- API tokens for Terraform Cloud

## Initial Setup

### 1. Create Terraform Cloud Account

1. Visit [https://app.terraform.io/signup/account](https://app.terraform.io/signup/account)
2. Sign up for a Terraform Cloud account
3. Verify your email address

### 2. Create Organization

1. Log in to Terraform Cloud
2. Click "Create Organization"
3. Enter organization name: `pr-cybr` (or your chosen name)
4. Save the organization name to your `.env` file:

   ```bash
   TFC_ORGANIZATION=pr-cybr
   ```

### 3. Create API Token

1. Go to User Settings → Tokens
2. Click "Create an API token"
3. Name: `pr-cybr-mgmt-node`
4. Copy the token immediately (it won't be shown again)
5. Store securely in GitHub Secrets:

   - Go to repository Settings → Secrets → Actions
   - Create secret: `TFC_API_TOKEN`
   - Paste the token value

6. Also add to local `.env` file:

   ```bash
   TFC_API_TOKEN=your-token-here
   ```

### 4. Create Workspace

1. In Terraform Cloud, click "New Workspace"
2. Choose workflow: "Version control workflow" or "API-driven workflow"
3. Workspace name: `pr-cybr-infrastructure`
4. Configure workspace settings:
   - Execution Mode: Remote
   - Terraform Version: Latest stable
   - Apply Method: Manual (for safety)

5. Save workspace name to `.env`:

   ```bash
   TFC_WORKSPACE=pr-cybr-infrastructure
   ```

## Configuration Files

### 1. Backend Configuration

Create `config/terraform/backend.tf`:

```hcl
terraform {
  cloud {
    organization = "pr-cybr"
    
    workspaces {
      name = "pr-cybr-infrastructure"
    }
  }
}
```

### 2. Workspace Variables

Configure in Terraform Cloud UI:

**Terraform Variables**:

- `region`: AWS/cloud region
- `environment`: dev/staging/prod
- `project_name`: pr-cybr

**Environment Variables** (mark as sensitive):

- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- Or equivalent for your cloud provider

### 3. Variable Definitions

Create `config/terraform/variables.tf`:

```hcl
variable "region" {
  description = "Cloud provider region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "pr-cybr"
}
```

## GitHub Actions Integration

### 1. Configure Secrets

Add these secrets to GitHub repository:

- `TFC_API_TOKEN`: Terraform Cloud API token
- `TFC_ORGANIZATION`: Organization name
- `TFC_WORKSPACE`: Workspace name

### 2. Workflow Configuration

The `terraform-cloud-bridge.yml` workflow handles:

- Validation of Terraform configurations
- Triggering Terraform Cloud runs
- Monitoring run status
- Reporting results to Slack

### 3. Trigger Workflow

The workflow triggers on:

- Push to `main`, `stage`, or `prod` branches
- Manual workflow dispatch
- Pull requests (validation only)

## Using Terraform Cloud

### Local Development

1. **Initialize Terraform**

   ```bash
   cd config/terraform
   terraform init
   ```

2. **Validate Configuration**

   ```bash
   terraform validate
   ```

3. **Plan Changes**

   ```bash
   terraform plan
   ```

4. **Apply Changes**

   ```bash
   terraform apply
   ```

### Via GitHub Actions

1. **Make changes to Terraform files**

   Edit files in `config/terraform/`

2. **Commit and push**

   ```bash
   git add config/terraform/
   git commit -m "Update infrastructure configuration"
   git push
   ```

3. **Monitor workflow**

   - Check GitHub Actions tab
   - Review Terraform Cloud run
   - Approve apply if needed

### Via Terraform Cloud UI

1. **Queue Plan**

   - Go to workspace
   - Click "Queue plan"
   - Add optional message

2. **Review Plan**

   - Review proposed changes
   - Check for unexpected modifications

3. **Apply**

   - Click "Confirm & Apply"
   - Add comment for audit trail

## Workspace Management

### Creating Additional Workspaces

For multi-environment setup:

1. **Development Workspace**

   - Name: `pr-cybr-dev`
   - Branch: `dev`
   - Auto-apply: Enabled

2. **Staging Workspace**

   - Name: `pr-cybr-staging`
   - Branch: `stage`
   - Auto-apply: Disabled

3. **Production Workspace**

   - Name: `pr-cybr-prod`
   - Branch: `prod`
   - Auto-apply: Disabled

### Workspace Synchronization

Use the sync script:

```bash
./scripts/terraform/sync-workspaces.sh
```

This script:

- Reads workspace configurations
- Creates/updates workspaces via API
- Configures variables
- Sets up VCS integration

## API Integration

### Using the Terraform Cloud API

The `setup-tfc.sh` script uses the API to:

1. Create workspaces
2. Configure variables
3. Set up VCS connections
4. Trigger runs

Example API call:

```bash
curl \
  --header "Authorization: Bearer $TFC_API_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/$TFC_ORGANIZATION/workspaces
```

## Monitoring and Notifications

### Run Status

Monitor run status:

```bash
# Via API
./scripts/terraform/check-run-status.sh <RUN-ID>

# Via UI
# Check workspace runs page
```

### Slack Notifications

Configure in workflow:

- Run started
- Plan completed
- Apply successful/failed
- Errors and warnings

## Security Best Practices

### 1. Token Management

- Store tokens in GitHub Secrets, never in code
- Use separate tokens for different environments
- Rotate tokens regularly (quarterly)
- Use team tokens for shared access

### 2. Workspace Security

- Enable workspace-level permissions
- Use sentinel policies for compliance
- Require plan approval for production
- Enable audit logging

### 3. State File Security

- State files contain sensitive data
- Never download state files unnecessarily
- Use remote state exclusively
- Enable state versioning

### 4. Variable Management

- Mark sensitive variables as sensitive
- Use workspace variables for secrets
- Don't store secrets in .tf files
- Use external secret managers when possible

## Troubleshooting

### Authentication Errors

**Symptoms**: 401 Unauthorized

**Solutions**:

1. Verify token is correct
2. Check token hasn't expired
3. Ensure token has proper permissions
4. Regenerate token if needed

### Workspace Not Found

**Symptoms**: 404 Workspace not found

**Solutions**:

1. Check workspace name spelling
2. Verify organization is correct
3. Ensure workspace exists
4. Check API token organization access

### Plan Fails

**Symptoms**: Terraform plan errors

**Solutions**:

1. Review error message in run log
2. Validate configuration locally
3. Check variable values
4. Verify provider credentials
5. Review recent changes

### Apply Hangs

**Symptoms**: Apply doesn't complete

**Solutions**:

1. Check for manual approval requirement
2. Review run logs for errors
3. Check provider API rate limits
4. Verify resource dependencies

### State Lock

**Symptoms**: State locked by another operation

**Solutions**:

1. Wait for other operation to complete
2. Check for stuck runs in UI
3. Force unlock if necessary (use caution):
   ```bash
   terraform force-unlock <LOCK-ID>
   ```

## Backup and Recovery

### State Backup

Terraform Cloud automatically versions state:

1. **View State Versions**

   - Go to workspace
   - Click "States" tab
   - View version history

2. **Download State**

   ```bash
   terraform state pull > backup-state.json
   ```

3. **Restore State**

   Only if absolutely necessary:

   ```bash
   terraform state push backup-state.json
   ```

### Configuration Backup

All Terraform configuration is version controlled in Git.

## Maintenance Schedule

### Daily

- Review run status
- Check for failed applies

### Weekly

- Review workspace configurations
- Check for Terraform updates
- Review costs (if applicable)

### Monthly

- Rotate API tokens
- Review and update policies
- Audit workspace permissions
- Review and cleanup old state versions

### Quarterly

- Review overall architecture
- Update Terraform to latest version
- Review and update provider versions
- Disaster recovery drill

## Advanced Features

### Sentinel Policies

For policy-as-code:

1. Create policy files
2. Upload to Terraform Cloud
3. Attach to workspaces
4. Set enforcement levels

### Cost Estimation

Enable cost estimation:

1. Go to organization settings
2. Enable cost estimation
3. Configure cloud provider credentials
4. View estimates in run logs

### Workspace Notifications

Configure notifications:

1. Go to workspace settings
2. Add notification configuration
3. Choose events (started, completed, errored)
4. Configure webhook or email

## References

- [Terraform Cloud Documentation](https://www.terraform.io/docs/cloud/index.html)
- [Terraform Cloud API](https://www.terraform.io/docs/cloud/api/index.html)
- [Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- PR-CYBR Architecture: `docs/architecture/system-overview.md`

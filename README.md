# PR-CYBR-MGMT-N0D3

[![Spec-Kit Validation](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/actions/workflows/spec-kit.yml/badge.svg)](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/actions/workflows/spec-kit.yml)
[![Lint](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/actions/workflows/lint.yml/badge.svg)](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/actions/workflows/lint.yml)
[![Test](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/actions/workflows/test.yml/badge.svg)](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/actions/workflows/test.yml)

Central management node for PR-CYBR distributed architecture, orchestrating Docker Swarm deployment, secrets, networking, and automation across client nodes. Contains SOP bootstrap and infrastructure automation.

## Overview

The PR-CYBR Management Node serves as the control plane for the entire PR-CYBR distributed infrastructure. It provides:

- **Docker Swarm Management**: Initialize, configure, and manage Docker Swarm clusters
- **Infrastructure Automation**: Scripts and workflows for common operations
- **Integration Hub**: Connects with Terraform Cloud, Notion, Slack, and GitHub
- **Secret Management**: Secure handling of credentials and sensitive data
- **CI/CD Pipeline**: Automated testing, building, and deployment
- **Specification-Driven Development**: Uses Spec-Kit framework for all changes

## Quick Start

### Prerequisites

- Docker Engine 20.10 or higher
- Bash 4.0 or higher
- Git 2.20 or higher
- Access to required external services (optional)

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3.git
   cd PR-CYBR-MGMT-N0D3
   ```

2. **Configure environment variables**
   ```bash
   cp config/templates/.env.template .env
   # Edit .env with your actual values
   nano .env
   ```

3. **Initialize Docker Swarm**
   ```bash
   ./scripts/swarm/init-swarm.sh
   ```

4. **Verify installation**
   ```bash
   docker node ls
   docker network ls
   ```

## Repository Structure

```
PR-CYBR-MGMT-N0D3/
├── .github/
│   └── workflows/          # GitHub Actions CI/CD workflows
│       ├── lint.yml        # Linting and code quality
│       ├── test.yml        # Integration tests
│       ├── build.yml       # Container image builds
│       ├── tfc-bridge.yml  # Terraform Cloud integration
│       └── spec-kit.yml    # Spec framework validation
├── .specify/               # Specification framework
│   ├── constitution.md     # Project principles
│   ├── spec.md            # Technical specifications
│   ├── plan.md            # Implementation plan
│   └── tasks/             # Task breakdowns
├── scripts/
│   ├── swarm/             # Docker Swarm management
│   │   ├── init-swarm.sh  # Initialize swarm
│   │   └── add-node.sh    # Add nodes to swarm
│   ├── integrations/      # External service integrations
│   │   ├── slack-notify.sh
│   │   ├── notion-sync.sh
│   │   └── tfc-sync.sh
│   └── secrets/           # Secret management (future)
├── config/
│   ├── docker/            # Docker configurations
│   │   └── docker-compose.yml
│   ├── terraform/         # Terraform configurations
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── templates/         # Configuration templates
│       └── .env.template
├── docs/                  # Additional documentation (future)
├── BRANCHING.md          # Branching strategy
└── README.md             # This file
```

## Scripts

### Docker Swarm Management

#### Initialize Swarm
```bash
./scripts/swarm/init-swarm.sh [advertise-addr]
```
Initializes a new Docker Swarm cluster on this node.

#### Add Node to Swarm
```bash
./scripts/swarm/add-node.sh <node-ip> <role>
```
Displays instructions to add a new worker or manager node to the swarm.

### Integrations

#### Slack Notifications
```bash
./scripts/integrations/slack-notify.sh "<message>" "[title]" "[color]"
```
Sends a notification to Slack. Requires `SLACK_WEBHOOK_URL` environment variable.

#### Notion Sync
```bash
./scripts/integrations/notion-sync.sh <file-path> [page-id]
```
Syncs documentation to Notion. Requires `NOTION_API_TOKEN` environment variable.

#### Terraform Cloud Sync
```bash
./scripts/integrations/tfc-sync.sh <action> [workspace]
```
Interacts with Terraform Cloud. Actions: `status`, `plan`, `apply`. Requires `TFC_API_TOKEN`.

## GitHub Actions Workflows

### Lint Workflow
Runs on every push and pull request to validate:
- Shell scripts with shellcheck
- YAML files with yamllint
- Markdown with markdownlint
- Terraform configurations
- Secret scanning with gitleaks

### Test Workflow
Executes integration and unit tests:
- Script functionality tests
- Configuration validation
- Terraform validation

### Build Workflow
Builds and publishes container images:
- Builds Docker images
- Runs security scans
- Pushes to GitHub Container Registry

### Terraform Cloud Bridge
Automates Terraform operations:
- Triggers TFC workspace runs
- Monitors run status
- Reports results to Slack

### Spec-Kit Validation
Validates specification framework:
- Checks required files exist
- Validates markdown syntax
- Checks for broken links

## Environment Variables

Create a `.env` file from the template and configure:

### Required Variables
- `SWARM_MANAGER_IP`: IP address for swarm manager
- `TFC_API_TOKEN`: Terraform Cloud API token
- `NOTION_API_TOKEN`: Notion API token
- `SLACK_WEBHOOK_URL`: Slack webhook URL

### Optional Variables
- `TFC_ORGANIZATION`: Terraform Cloud organization (default: PR-CYBR)
- `TFC_WORKSPACE`: Workspace name (default: pr-cybr-mgmt-node)
- `SLACK_CHANNEL`: Default Slack channel (default: #pr-cybr-ops)
- `LOG_LEVEL`: Logging level (default: INFO)

See `config/templates/.env.template` for complete list.

## Branching Strategy

This repository follows a comprehensive branching model for specification-driven development:

- `spec` → `plan` → `impl` → `dev` → `main` → `stage` → `prod`
- Automated PRs between branches
- Branch-specific workflows

See [BRANCHING.md](BRANCHING.md) for detailed documentation.

## Specification Framework

This project uses the Spec-Kit framework for specification-driven development:

- **Constitution** (`.specify/constitution.md`): Project principles and governance
- **Specifications** (`.specify/spec.md`): Technical requirements
- **Plan** (`.specify/plan.md`): Implementation roadmap
- **Tasks** (`.specify/tasks/`): Individual task breakdowns

## Security

### Secret Management
- Never commit secrets to the repository
- Use environment variables for all sensitive data
- Rotate secrets regularly
- Use Docker secrets for swarm services

### Secret Scanning
The repository includes automated secret scanning with gitleaks. All commits are checked for exposed secrets.

### Network Security
- Use TLS for all external communications
- Configure firewall rules for swarm ports (2377, 7946, 4789)
- Implement network segmentation with overlay networks

## Integrations

### Terraform Cloud
Manages infrastructure state and provisioning through Terraform Cloud API.

### Notion
Syncs documentation and SOPs to Notion for team collaboration.

### Slack
Sends notifications for deployments, alerts, and CI/CD events.

### GitHub
Automates workflows and manages repository operations.

## Contributing

1. Review the constitution: `.specify/constitution.md`
2. Check the specifications: `.specify/spec.md`
3. Follow the branching strategy: `BRANCHING.md`
4. Create feature branches from appropriate branch
5. Ensure all tests pass before creating PR
6. Update specifications if making architectural changes

## Monitoring and Logging

Monitoring and centralized logging will be implemented in future phases. See `.specify/plan.md` for roadmap.

## Disaster Recovery

Backup and recovery procedures will be documented in `docs/` directory. See `.specify/plan.md` for implementation timeline.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Review documentation in `.specify/` directory
- Check `BRANCHING.md` for workflow questions

## Roadmap

See `.specify/plan.md` for detailed implementation roadmap and current status.

## Acknowledgments

Built using the [spec-bootstrap](https://github.com/PR-CYBR/spec-bootstrap) template for specification-driven development.

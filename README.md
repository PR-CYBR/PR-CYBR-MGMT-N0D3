# PR-CYBR-MGMT-N0D3

[![Spec-Kit Validation](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/actions/workflows/spec-kit.yml/badge.svg)](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/actions/workflows/spec-kit.yml)

Central management node for PR-CYBR distributed architecture, orchestrating Docker Swarm deployment, secrets management, networking, and automation across client nodes. Integrates with Terraform Cloud, Notion, and Slack for complete infrastructure management.

## Overview

PR-CYBR-MGMT-N0D3 is the orchestration hub for the PR-CYBR distributed architecture, providing:

- **Docker Swarm Management**: Initialize, configure, and manage Docker Swarm clusters
- **Terraform Cloud Integration**: Infrastructure as Code automation via Terraform Cloud
- **Notion Integration**: Automated documentation synchronization
- **Slack Notifications**: Real-time alerts and status updates
- **Secrets Management**: Centralized secrets and configuration management
- **SOP Documentation**: Standard Operating Procedures for all operations

## Quick Start

### Prerequisites

- Docker with Swarm mode capability
- Terraform Cloud account
- Notion API access (optional)
- Slack workspace with webhook access (optional)
- GitHub account with Actions enabled

### Initial Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3.git
   cd PR-CYBR-MGMT-N0D3
   ```

2. **Configure environment variables**

   ```bash
   cp config/.env.example .env
   # Edit .env with your configuration
   ```

3. **Initialize the environment**

   ```bash
   ./scripts/setup/init-env.sh
   ```

4. **Configure secrets**

   ```bash
   ./scripts/setup/configure-secrets.sh
   ```

## Directory Structure

```
/
├── .specify/              # Spec-Kit framework files
│   ├── constitution.md    # Project principles and governance
│   ├── spec.md           # Technical specifications
│   ├── plan.md           # Implementation plan
│   └── tasks/            # Task specifications
├── .github/
│   └── workflows/        # GitHub Actions workflows
├── docs/
│   ├── SOPs/            # Standard Operating Procedures
│   └── architecture/    # System documentation
├── scripts/
│   ├── docker-swarm/    # Docker Swarm management scripts
│   ├── terraform/       # Terraform Cloud scripts
│   ├── integrations/    # Notion and Slack integration scripts
│   └── setup/           # Setup and configuration scripts
├── config/
│   ├── docker/          # Docker Swarm configurations
│   ├── terraform/       # Terraform configurations
│   └── .env.example     # Environment variables template
├── README.md            # This file
├── BRANCHING.md         # Branching strategy documentation
└── LICENSE              # MIT License
```

## Live Codebase Mindmap

Auto-generated on each push: **repo-map.html** (via GitHub Pages and CI artifact).
When Pages is enabled, it will be served at: `https://<owner>.github.io/<repo>/repo-map.html`

## Features

### Docker Swarm Management

Manage your Docker Swarm cluster with ease:

- Initialize new swarm clusters
- Add worker and manager nodes
- Remove nodes gracefully
- Update services across the swarm
- Deploy stack templates

See [docs/SOPs/docker-swarm-management.md](docs/SOPs/docker-swarm-management.md) for detailed instructions.

### Terraform Cloud Integration

Automate infrastructure management:

- Workspace synchronization
- Automated plan and apply via GitHub Actions
- Status reporting to Slack
- Configuration validation

See [docs/SOPs/terraform-cloud-setup.md](docs/SOPs/terraform-cloud-setup.md) for setup instructions.

### Notion Integration

Keep documentation synchronized:

- Automatic doc sync to Notion workspace
- Structured documentation database
- Version tracking

See [docs/SOPs/notion-integration.md](docs/SOPs/notion-integration.md) for configuration.

### Slack Integration

Stay informed with real-time notifications:

- Deployment status updates
- Docker Swarm events
- CI/CD pipeline results
- Security alerts

See [docs/SOPs/slack-integration.md](docs/SOPs/slack-integration.md) for webhook setup.

## Branching Strategy

This repository follows the Spec-Kit branching model with comprehensive branch structure:

- `spec` → `plan` → `impl` → `dev` → `main` → `stage` → `prod` → `pages`
- Additional branches: `design`, `test`, `codex`, `gh-pages`

See [BRANCHING.md](BRANCHING.md) for complete documentation on the branching workflow.

## GitHub Actions Workflows

### Core Workflows

- **spec-kit.yml**: Validates Spec-Kit framework files
- **lint.yml**: Lints shell scripts, YAML files, and markdown
- **test.yml**: Tests scripts and configurations
- **build.yml**: Builds Docker images and artifacts
- **terraform-cloud-bridge.yml**: Integrates with Terraform Cloud

### Branch-Specific Workflows

Each branch has dedicated workflows for validation and deployment:

- `spec.yml`, `plan.yml`, `impl.yml`, `dev.yml`
- `test.yml`, `stage.yml`, `prod.yml`, `pages.yml`
- `design.yml`, `codex.yml`, `gh-pages.yml`

### Auto-PR Workflows

Automated pull requests promote changes through the branching flow:

- `auto-pr-spec-to-plan.yml`
- `auto-pr-plan-to-impl.yml`
- `auto-pr-impl-to-dev.yml`
- And more...

## Contributing

This project uses specification-driven development:

1. **Start with specs**: Update `.specify/spec.md` with requirements
2. **Plan implementation**: Update `.specify/plan.md` with tasks
3. **Create task files**: Add specific tasks to `.specify/tasks/`
4. **Implement**: Follow the branching workflow
5. **Document**: Update SOPs and README as needed

## Security

- All secrets are managed via GitHub Secrets or secure environment files
- Never commit secrets to the repository
- Follow the principle of least privilege for all integrations
- Review security documentation in [docs/SOPs/](docs/SOPs/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions:

1. Check existing [issues](https://github.com/PR-CYBR/PR-CYBR-MGMT-N0D3/issues)
2. Review [documentation](docs/)
3. Open a new issue with detailed information

## Acknowledgments

- Built on the [Spec-Kit framework](https://github.com/PR-CYBR/spec-bootstrap)
- Part of the PR-CYBR distributed architecture

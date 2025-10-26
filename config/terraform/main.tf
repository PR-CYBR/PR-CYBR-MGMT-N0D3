# Terraform Cloud Configuration
# This configuration should be synced with your TFC workspace

terraform {
  required_version = ">= 1.0"
  
  # Uncomment and configure when ready to use Terraform Cloud
  # cloud {
  #   organization = "PR-CYBR"
  #   
  #   workspaces {
  #     name = "pr-cybr-mgmt-node"
  #   }
  # }
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Provider configuration
# provider "docker" {
#   host = "unix:///var/run/docker.sock"
# }

# Placeholder resources
# Add your infrastructure resources here

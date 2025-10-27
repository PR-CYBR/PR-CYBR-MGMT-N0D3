# Terraform Cloud Configuration
terraform {
  cloud {
    organization = "pr-cybr"
    
    workspaces {
      name = "pr-cybr-infrastructure"
    }
  }
  
  required_version = ">= 1.0"
  
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

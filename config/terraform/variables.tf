# Variable definitions for Terraform Cloud workspaces

variable "region" {
  description = "Cloud provider region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "pr-cybr"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "PR-CYBR"
    ManagedBy = "Terraform"
  }
}

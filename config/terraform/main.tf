# Example Terraform configuration for PR-CYBR infrastructure
# This is a placeholder - customize for your needs

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Example: Create a local file
resource "local_file" "example" {
  content  = "PR-CYBR Management Node - Terraform Cloud Managed"
  filename = "${path.module}/example.txt"
}

# Output example
output "example_file" {
  description = "Example file path"
  value       = local_file.example.filename
}

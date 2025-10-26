variable "swarm_manager_ip" {
  description = "IP address of the Docker Swarm manager node"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "log_level" {
  description = "Logging level"
  type        = string
  default     = "INFO"
}

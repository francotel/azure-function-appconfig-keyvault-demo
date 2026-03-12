variable "project-name" {
  description = "Project name"
  type        = string
  default     = "secure-banking"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "secure-banking"
    ManagedBy   = "Terraform"
  }
}

variable "env" {
  description = "Environment name"
  type        = string
}
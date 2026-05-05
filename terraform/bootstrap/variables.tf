# terraform/bootstrap/variables.tf

variable "project_id" {
  type        = string
  description = "The GCP Project ID"
  default     = "ldp21k-labs"
}

variable "region" {
  type        = string
  description = "Primary region for resources"
  default     = "us-central1"
}

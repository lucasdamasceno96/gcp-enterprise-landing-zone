# terraform/bootstrap/main.tf

terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket = "ldp21k-labs-tfstate"
    prefix = "bootstrap/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Ativação de APIs fundamentais
resource "google_project_service" "required_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

# terraform/workloads/iam.tf

resource "google_service_account" "hospital_api_sa" {
  account_id   = "sa-hospital-api"
  display_name = "Service Account for Hospital API"
  project      = var.project_id
}
# terraform/workloads/iam.tf

# 1. Criação da identidade da API (Você já tem esse código)
resource "google_service_account" "hospital_api_sa" {
  account_id   = "sa-hospital-api"
  display_name = "Service Account for Hospital API"
}

# 2. Permissão para a API escrever logs (Essencial para troubleshooting)
resource "google_project_iam_member" "api_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.hospital_api_sa.email}"
}

# 3. Permissão para a API enviar métricas ao Monitoring
resource "google_project_iam_member" "api_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.hospital_api_sa.email}"
}
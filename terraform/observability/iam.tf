# terraform/observability/iam.tf

# Permissão para o time médico/gestão ver apenas os dashboards de performance
resource "google_project_iam_member" "ops_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "group:gestao-ti@seu-dominio.com"
}
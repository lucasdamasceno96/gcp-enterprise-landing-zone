# terraform/network/iam.tf

# Role para o time de auditoria/segurança apenas visualizar a rede
resource "google_compute_network_iam_member" "network_viewer" {
  project = var.project_id
  name    = google_compute_network.main_vpc.name
  role    = "roles/compute.networkViewer"
  member  = "group:ti-seguranca@gcphospital.lz" # Exemplo de grupo real
}
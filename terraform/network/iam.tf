# terraform/network/iam.tf

# TODO: Link to corporate Google Group once Google Workspace is synced
# resource "google_project_iam_member" "network_viewer" {
#   project = var.project_id
#   role    = "roles/compute.networkViewer"
#   member  = "group:ti-seguranca@hospital-real.com"
# }
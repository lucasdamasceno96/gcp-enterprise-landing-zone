# terraform/security/main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}
resource "google_artifact_registry_repository" "hospital_repo" {
  project       = var.project_id # Adicione esta linha explicitamente
  location      = var.region
  repository_id = "hospital-images"
  description   = "Private docker repository for hospital applications"
  format        = "DOCKER"
}

output "repo_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.hospital_repo.repository_id}"
}
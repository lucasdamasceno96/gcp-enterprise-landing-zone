output "repository_id" {
  value       = google_artifact_registry_repository.hospital_repo.id
  description = "The ID of the Artifact Registry repository"
}

output "repository_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.hospital_repo.repository_id}"
  description = "The full URL for the Docker repository"
}
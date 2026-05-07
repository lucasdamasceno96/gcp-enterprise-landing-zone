# Lendo o estado do workload para pegar o e-mail da Service Account da API
data "terraform_remote_state" "workloads" {
  backend = "gcs"
  config = {
    bucket = "ldp21k-labs-tfstate"
    prefix = "workloads/state"
  }
}

# Concedendo permissão de Leitor de Artefatos para a API do Hospital
resource "google_artifact_registry_repository_iam_member" "api_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.hospital_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:sa-hospital-api@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_artifact_registry_repository_iam_member" "ci_pusher" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.hospital_repo.name
  role       = "roles/artifactregistry.repoAdmin"
  member     = "serviceAccount:github-actions-tf@${var.project_id}.iam.gserviceaccount.com"
}
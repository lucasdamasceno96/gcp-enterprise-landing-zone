# terraform/workloads/main.tf

terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = "ldp21k-labs-tfstate"
    prefix = "workloads/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Consumindo a rede que criamos no passo anterior
data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = "ldp21k-labs-tfstate"
    prefix = "network/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Cloud Run: A API de Agendamento do Hospital
resource "google_cloud_run_v2_service" "hospital_api" {
  name     = "hospital-api"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL" # Em prod, isso seria INTERNAL se tivéssemos um Load Balancer

  template {
    service_account = google_service_account.hospital_api_sa.email
    
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Imagem padrão do Google para teste
      
      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
    }

    # Estratégia de Rede: Direct VPC Egress
    # Faz com que o Cloud Run "nasça" dentro da nossa subnet privada
    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.network.outputs.network_name
        subnetwork = data.terraform_remote_state.network.outputs.app_subnet_id
      }
      egress = "ALL_TRAFFIC" 
    }
  }

  depends_on = [google_service_account.hospital_api_sa]
}

# Permitir acesso público apenas para este lab (No hospital real, usaríamos IAP)
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.hospital_api.location
  name     = google_cloud_run_v2_service.hospital_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
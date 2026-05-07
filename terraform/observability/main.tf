# terraform/observability/main.tf

terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = "ldp21k-labs-tfstate"
    prefix = "observability/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Lendo o estado do workload para saber a URL do Cloud Run
data "terraform_remote_state" "workloads" {
  backend = "gcs"
  config = {
    bucket = "ldp21k-labs-tfstate"
    prefix = "workloads/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Dashboard de Monitoramento para o Hospital
resource "google_monitoring_dashboard" "hospital_dashboard" {
  project        = var.project_id
  dashboard_json = <<EOF
{
  "displayName": "Hospital API Performance",
  "gridLayout": {
    "widgets": [
      {
        "title": "Cloud Run Request Count",
        "xyChart": {
          "dataSets": [{
            "plotType": "LINE",
            "targetAxis": "Y1",
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "resource.type=\"cloud_run_revision\" metric.type=\"run.googleapis.com/request_count\""
              }
            }
          }]
        }
      }
    ]
  }
}
EOF
}

# 2. Uptime Check: Verifica se a API está viva a cada 1 minuto
resource "google_monitoring_uptime_check_config" "api_health" {
  display_name = "hospital-api-uptime-check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path = "/"
    port = "443"
    use_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = split("/", data.terraform_remote_state.workloads.outputs.service_url)[2]
    }
  }
}
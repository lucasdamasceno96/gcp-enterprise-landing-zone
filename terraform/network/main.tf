# terraform/network/main.tf

terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = "ldp21k-labs-tfstate"
    prefix = "network/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. The Hub: Virtual Private Cloud (VPC)
resource "google_compute_network" "main_vpc" {
  name                            = "vpc-hospital-hub"
  auto_create_subnetworks         = false # Best practice: always control your IP space
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = false
}

# 2. The Spoke Subnet: Where Cloud Run will connect
resource "google_compute_subnetwork" "app_subnet" {
  name          = "sb-us-central1-apps"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main_vpc.id

  # Enables private access to Google APIs (Crucial for Cloud Run)
  private_ip_google_access = true
}

# 3. Cloud Router (Required for NAT)
resource "google_compute_router" "router" {
  name    = "rt-hospital-gateway"
  region  = var.region
  network = google_compute_network.main_vpc.id
}

# 4. Cloud NAT: Allows private resources to reach the internet safely
resource "google_compute_router_nat" "nat" {
  name                               = "nat-hospital-gateway"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

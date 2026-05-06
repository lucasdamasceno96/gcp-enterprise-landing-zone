# terraform/network/outputs.tf

output "vpc_id" {
  value       = google_compute_network.main_vpc.id
  description = "The ID of the VPC Hub"
}

output "app_subnet_id" {
  value       = google_compute_subnetwork.app_subnet.id
  description = "The ID of the application subnet"
}

output "network_name" {
  value       = google_compute_network.main_vpc.name
  description = "The name of the VPC Hub"
}
output "router_name" {
  value       = google_compute_router.router.name
  description = "The name of the Cloud Router"
}

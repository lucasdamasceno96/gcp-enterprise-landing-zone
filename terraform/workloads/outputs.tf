output "service_url" {
  value       = google_cloud_run_v2_service.hospital_api.uri
  description = "The URL of the Hospital API"
}
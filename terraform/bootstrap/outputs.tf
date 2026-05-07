output "uptime_check_id" {
  value       = google_monitoring_uptime_check_config.api_health.uptime_check_id
  description = "The ID of the uptime check"
}

output "dashboard_id" {
  value       = google_monitoring_dashboard.hospital_dashboard.id
  description = "The ID of the monitoring dashboard"
}
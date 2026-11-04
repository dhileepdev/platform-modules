output "network_id" {
  description = "ID of the VPC network."
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "Name of the VPC network."
  value       = google_compute_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs keyed by region."
  value       = { for region, subnet in google_compute_subnetwork.this : region => subnet.id }
}

output "subnet_names" {
  description = "Subnet names keyed by region."
  value       = { for region, subnet in google_compute_subnetwork.this : region => subnet.name }
}

##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "instance_name" {
  description = "The name of the Cloud SQL instance."
  value       = google_sql_database_instance.this.name
}

output "instance_id" {
  description = "The ID of the Cloud SQL instance."
  value       = google_sql_database_instance.this.id
}

output "connection_name" {
  description = "The connection name of the Cloud SQL instance (project:region:instance)."
  value       = google_sql_database_instance.this.connection_name
}

output "ip_address" {
  description = "The first IPv4 address of the Cloud SQL instance."
  value       = try(google_sql_database_instance.this.ip_address[0].ip_address, null)
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.this.private_ip_address
}

output "database_version" {
  description = "The database version of the Cloud SQL instance."
  value       = google_sql_database_instance.this.database_version
}

output "database_name" {
  description = "The initial database name created on the instance."
  value       = google_sql_database.initial.name
}

output "master_username" {
  description = "The master/admin username for the instance."
  value       = local.master_username
}

output "credentials_secret_id" {
  description = "The GCP Secret Manager secret ID storing the master credentials JSON."
  value       = try(google_secret_manager_secret.master_credentials[0].id, null)
}

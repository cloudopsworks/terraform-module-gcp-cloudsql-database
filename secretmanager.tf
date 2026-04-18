##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  db_engine_prefix = startswith(try(var.settings.database_version, ""), "POSTGRES") ? "postgresql" : startswith(try(var.settings.database_version, ""), "MYSQL") ? "mysql" : "sqlserver"
  db_port          = local.db_engine_prefix == "postgresql" ? 5432 : local.db_engine_prefix == "mysql" ? 3306 : 1433
  credentials_secret_id = lower(replace(
    format("%s/%s/%s/master-credentials", local.secret_store_path, local.db_engine_prefix, local.instance_name),
    "/[^a-zA-Z0-9_-]/", "-"
  ))
  master_credentials = {
    username        = local.master_username
    password        = try(var.settings.managed_password, false) ? null : random_password.master[0].result
    host            = try(google_sql_database_instance.this.ip_address[0].ip_address, google_sql_database_instance.this.private_ip_address)
    port            = local.db_port
    dbname          = local.database_name
    engine          = local.db_engine_prefix
    sslmode         = "require"
    connection_name = google_sql_database_instance.this.connection_name
  }
}

resource "google_secret_manager_secret" "master_credentials" {
  count     = try(var.settings.managed_password, false) ? 0 : 1
  secret_id = local.credentials_secret_id
  project   = data.google_project.current.project_id

  labels = merge(local.all_tags, {
    "cloudsql-instance" = local.instance_name
    "cloudsql-engine"   = local.db_engine_prefix
  })

  replication {
    auto {
      dynamic "customer_managed_encryption" {
        for_each = try(var.settings.password_kms_key_name, null) != null ? [1] : []
        content {
          kms_key_name = var.settings.password_kms_key_name
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "master_credentials" {
  count       = try(var.settings.managed_password, false) ? 0 : 1
  secret      = google_secret_manager_secret.master_credentials[0].id
  secret_data = jsonencode(local.master_credentials)

  lifecycle {
    create_before_destroy = true
  }
}

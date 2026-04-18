##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  hoop_enabled    = try(var.settings.hoop.enabled, false) && !try(var.settings.managed_password, false)
  hoop_enterprise = local.hoop_enabled && !try(var.settings.hoop.community, true)
  hoop_subtype    = local.db_engine_prefix == "postgresql" ? "postgres" : local.db_engine_prefix == "mysql" ? "mysql" : "sqlserver"
  hoop_host       = try(google_sql_database_instance.this.ip_address[0].ip_address, google_sql_database_instance.this.private_ip_address)
}

resource "google_secret_manager_secret" "hoop_host" {
  count     = local.hoop_enterprise ? 1 : 0
  secret_id = lower(replace("${local.credentials_secret_id}-hoop-host", "/[^a-zA-Z0-9_-]/", "-"))
  project   = data.google_project.current.project_id
  labels    = local.all_tags

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "hoop_host" {
  count       = local.hoop_enterprise ? 1 : 0
  secret      = google_secret_manager_secret.hoop_host[0].id
  secret_data = local.hoop_host

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_secret_manager_secret" "hoop_port" {
  count     = local.hoop_enterprise ? 1 : 0
  secret_id = lower(replace("${local.credentials_secret_id}-hoop-port", "/[^a-zA-Z0-9_-]/", "-"))
  project   = data.google_project.current.project_id
  labels    = local.all_tags

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "hoop_port" {
  count       = local.hoop_enterprise ? 1 : 0
  secret      = google_secret_manager_secret.hoop_port[0].id
  secret_data = tostring(local.db_port)

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_secret_manager_secret" "hoop_user" {
  count     = local.hoop_enterprise ? 1 : 0
  secret_id = lower(replace("${local.credentials_secret_id}-hoop-user", "/[^a-zA-Z0-9_-]/", "-"))
  project   = data.google_project.current.project_id
  labels    = local.all_tags

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "hoop_user" {
  count       = local.hoop_enterprise ? 1 : 0
  secret      = google_secret_manager_secret.hoop_user[0].id
  secret_data = local.master_username

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_secret_manager_secret" "hoop_pass" {
  count     = local.hoop_enterprise ? 1 : 0
  secret_id = lower(replace("${local.credentials_secret_id}-hoop-pass", "/[^a-zA-Z0-9_-]/", "-"))
  project   = data.google_project.current.project_id
  labels    = local.all_tags

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "hoop_pass" {
  count       = local.hoop_enterprise ? 1 : 0
  secret      = google_secret_manager_secret.hoop_pass[0].id
  secret_data = random_password.master[0].result

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_secret_manager_secret" "hoop_db" {
  count     = local.hoop_enterprise ? 1 : 0
  secret_id = lower(replace("${local.credentials_secret_id}-hoop-db", "/[^a-zA-Z0-9_-]/", "-"))
  project   = data.google_project.current.project_id
  labels    = local.all_tags

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "hoop_db" {
  count       = local.hoop_enterprise ? 1 : 0
  secret      = google_secret_manager_secret.hoop_db[0].id
  secret_data = local.database_name

  lifecycle {
    create_before_destroy = true
  }
}

output "hoop_connections" {
  description = "Hoop connection definitions. Enterprise mode only (GCP Secret Manager has no sub-key access). Community mode returns null."
  value = local.hoop_enterprise ? {
    "owner" = {
      name           = "${local.instance_name}-ow"
      agent_id       = var.settings.hoop.agent_id
      type           = "database"
      subtype        = local.hoop_subtype
      tags           = try(var.settings.hoop.tags, {})
      access_control = toset(try(var.settings.hoop.access_control, []))
      access_modes   = { connect = "enabled", exec = "enabled", runbooks = "enabled", schema = "enabled" }
      import         = try(var.settings.hoop.import, false)
      secrets = {
        "envvar:HOST"    = "_envs/gcp/${google_secret_manager_secret.hoop_host[0].secret_id}"
        "envvar:PORT"    = "_envs/gcp/${google_secret_manager_secret.hoop_port[0].secret_id}"
        "envvar:USER"    = "_envs/gcp/${google_secret_manager_secret.hoop_user[0].secret_id}"
        "envvar:PASS"    = "_envs/gcp/${google_secret_manager_secret.hoop_pass[0].secret_id}"
        "envvar:DB"      = "_envs/gcp/${google_secret_manager_secret.hoop_db[0].secret_id}"
        "envvar:SSLMODE" = "require"
      }
    }
  } : null

  precondition {
    condition     = !local.hoop_enterprise || try(var.settings.hoop.agent_id, "") != ""
    error_message = "settings.hoop.agent_id must be set when settings.hoop.enabled=true and settings.hoop.community=false."
  }
}

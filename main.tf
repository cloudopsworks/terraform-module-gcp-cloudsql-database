##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  instance_name   = try(var.settings.name_prefix, "") != "" ? "${local.system_name}-${var.settings.name_prefix}" : local.system_name
  database_name   = try(var.settings.database_name, startswith(try(var.settings.database_version, ""), "POSTGRES") ? "postgres" : startswith(try(var.settings.database_version, ""), "MYSQL") ? "mysql" : "master")
  master_username = try(var.settings.master_username, "admin")
}

resource "google_sql_database_instance" "this" {
  name                = local.instance_name
  database_version    = var.settings.database_version
  region              = try(var.settings.region, data.google_client_config.current.region)
  deletion_protection = try(var.settings.deletion_protection, false)

  settings {
    tier                  = var.settings.tier
    availability_type     = try(var.settings.availability_type, "ZONAL")
    disk_size             = try(var.settings.disk_size, 10)
    disk_autoresize       = try(var.settings.disk_autoresize, true)
    disk_autoresize_limit = try(var.settings.disk_autoresize_limit, 0)
    disk_type             = try(var.settings.disk_type, "PD_SSD")
    user_labels           = local.all_tags

    backup_configuration {
      enabled                        = try(var.settings.backup.enabled, false)
      start_time                     = try(var.settings.backup.start_time, "03:00")
      point_in_time_recovery_enabled = try(var.settings.backup.point_in_time_recovery, false)
      backup_retention_settings {
        retained_backups = try(var.settings.backup.retained_backups, 7)
        retention_unit   = try(var.settings.backup.retention_unit, "COUNT")
      }
    }

    maintenance_window {
      day          = try(var.settings.maintenance.day, 1)
      hour         = try(var.settings.maintenance.hour, 0)
      update_track = try(var.settings.maintenance.update_track, "stable")
    }

    dynamic "database_flags" {
      for_each = try(var.settings.database_flags, [])
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    insights_config {
      query_insights_enabled = try(var.settings.insights.enabled, false)
      query_string_length    = try(var.settings.insights.query_string_length, 1024)
      record_client_address  = try(var.settings.insights.record_client_address, false)
    }

    ip_configuration {
      ipv4_enabled       = !try(var.settings.private_ip.enabled, false)
      private_network    = try(var.settings.private_ip.enabled, false) ? var.network.network_id : null
      allocated_ip_range = try(var.settings.private_ip.enabled, false) ? try(var.network.allocated_ip_range, null) : null
      ssl_mode           = try(var.settings.private_ip.require_ssl, true) ? "ENCRYPTED_ONLY" : "ALLOW_UNENCRYPTED_AND_ENCRYPTED"

      dynamic "authorized_networks" {
        for_each = try(var.network.authorized_networks, [])
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }
  }
}

resource "google_sql_database" "initial" {
  name     = local.database_name
  instance = google_sql_database_instance.this.name
}

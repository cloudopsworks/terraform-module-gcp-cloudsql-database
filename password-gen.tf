##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "random_password" "master" {
  count            = try(var.settings.managed_password, false) ? 0 : 1
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "google_sql_user" "master" {
  count    = try(var.settings.managed_password, false) ? 0 : 1
  name     = local.master_username
  instance = google_sql_database_instance.this.name
  password = random_password.master[0].result
}

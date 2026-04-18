##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## YAML Input Format
# settings:
#   name_prefix: "mydb"              # (Required) Name prefix for the Cloud SQL instance.
#   database_name: "mydb"            # (Optional) Initial database name. Defaults to "postgres", "mysql", or "master" depending on engine.
#   master_username: "admin"         # (Optional) Admin username. Defaults to "admin".
#   database_version: "POSTGRES_16"  # (Required) Cloud SQL version. Possible values: POSTGRES_15, POSTGRES_16, MYSQL_8_0, MYSQL_8_4, SQLSERVER_2022_STANDARD, SQLSERVER_2022_ENTERPRISE, etc.
#   tier: "db-custom-2-7680"         # (Required) Machine tier (e.g., db-f1-micro, db-custom-4-15360).
#   region: ""                       # (Optional) Override region; defaults to provider region.
#   deletion_protection: false       # (Optional) Prevent accidental deletion. Default: false.
#   availability_type: "ZONAL"       # (Optional) REGIONAL (HA) or ZONAL. Default: ZONAL.
#   disk_size: 10                    # (Optional) Initial disk size in GB. Default: 10.
#   disk_autoresize: true            # (Optional) Auto-grow disk. Default: true.
#   disk_autoresize_limit: 0         # (Optional) Max auto-resize GB; 0 = unlimited. Default: 0.
#   disk_type: "PD_SSD"              # (Optional) PD_SSD or PD_HDD. Default: PD_SSD.
#   backup:
#     enabled: false                 # (Optional) Enable automated backups. Default: false.
#     start_time: "03:00"            # (Optional) Backup start time HH:MM UTC. Default: "03:00".
#     point_in_time_recovery: false  # (Optional) Enable PITR (PostgreSQL only). Default: false.
#     retained_backups: 7            # (Optional) Number of backups to retain. Default: 7.
#     retention_unit: "COUNT"        # (Optional) COUNT or TIME. Default: COUNT.
#   maintenance:
#     day: 1                         # (Optional) Day of week 1=Monday..7=Sunday. Default: 1.
#     hour: 0                        # (Optional) Hour of day 0-23 UTC. Default: 0.
#     update_track: "stable"         # (Optional) canary or stable. Default: stable.
#   database_flags: []               # (Optional) List of {name, value} flag objects for the instance.
#   insights:
#     enabled: false                 # (Optional) Enable Query Insights. Default: false.
#     query_string_length: 1024      # (Optional) Max query string length. Default: 1024.
#     record_client_address: false   # (Optional) Record client IP address. Default: false.
#   private_ip:
#     enabled: false                 # (Optional) Assign private IP via VPC peering. Default: false.
#     require_ssl: true              # (Optional) Require SSL for connections. Default: true.
#   managed_password: false          # (Optional) Use auto-generated Cloud SQL managed password (not stored in Secret Manager). Default: false.
#   password_kms_key_name: ""        # (Optional) GCP KMS key name for encrypting the secret at rest.
#   hoop:
#     enabled: false                 # (Optional) Generate hoop_connections output. Default: false.
#     agent_id: ""                   # (Required when enabled) Hoop agent UUID.
#     community: true                # (Optional) true=returns null (GCP SM has no sub-key access); false=enterprise mode. Default: true.
#     import: false                  # (Optional) Import existing Hoop connection. Default: false.
#     tags: {}                       # (Optional) Tags map for Hoop connection.
#     access_control: []             # (Optional) Access control groups list.
variable "settings" {
  description = "Settings for Cloud SQL instance — see inline docs for full YAML structure."
  type        = any
  default     = {}
}

## YAML Input Format
# network:
#   network_id: ""                   # (Required if private_ip.enabled) VPC network self_link or ID.
#   allocated_ip_range: ""           # (Optional) Named IP range for private services connection.
#   authorized_networks:             # (Optional) Public IP authorized networks list.
#     - name: "office"               # (Required) Display name.
#       cidr: "203.0.113.0/24"       # (Required) CIDR block.
variable "network" {
  description = "Network configuration for Cloud SQL instance."
  type        = any
  default     = {}
}

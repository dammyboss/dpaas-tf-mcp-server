############################# Start of null-label Variables #############################
variable "context" {
  type        = any
  description = <<-EOT
    Single object for setting entire context at once.
    See description of individual variables for details.
    Leave string and numeric variables as `null` to use default value.
    Individual variable settings (non-null) override settings in context object,
    except for attributes, tags, and additional_tag_map, which are merged.
  EOT
  default = {
    enabled             = true
    namespace           = null
    tenant              = null
    environment         = null
    stage               = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = ["namespace", "stage", "tenant", "environment", "name", "attributes"]
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    # Note: we have to use [] instead of null for unset lists due to
    # https://github.com/hashicorp/terraform/issues/28137
    # which was not fixed until Terraform 1.0.0,
    # but we want the default to be all the labels in `label_order`
    # and we want users to be able to prevent all tag generation
    # by setting `labels_as_tags` to `[]`, so we need
    # a different sentinel to indicate "default"
    labels_as_tags = ["unset"]
  }
  validation {
    condition     = lookup(var.context, "label_key_case", null) == null ? true : contains(["lower", "title", "upper"], var.context["label_key_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }

  validation {
    condition     = lookup(var.context, "label_value_case", null) == null ? true : contains(["lower", "title", "upper", "none"], var.context["label_value_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources"
  default     = null
}

variable "namespace" {
  type        = string
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'expn', to help ensure generated IDs are globally unique"
  default     = null
}

variable "create_mssql_database" {
  type        = bool
  description = "Whether to create the Mssql Database."
  default     = true
}

variable "tenant" {
  type        = string
  description = "A customer identifier to which tenant and application, the resource belongs to, <business-unit>-<application>-<subtenant> eg: cs-bis-sbfe "
  default     = null
}

variable "environment" {
  type        = string
  description = "ID element. Usually used for environment e.g.  'prd', 'sbx', 'dev', 'UAT'"
  default     = null
}

variable "stage" {
  type        = string
  description = "ID element. Usually used to indicate role."
  default     = null
}

variable "name" {
  type        = string
  description = <<-EOT
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.
    This is the only ID element not also included as a `tag`.
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.
    EOT
  default     = null
}

variable "delimiter" {
  type        = string
  description = <<-EOT
    Delimiter to be used between ID elements.
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.
  EOT
  default     = null
}

variable "attributes" {
  type        = list(string)
  description = <<-EOT
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,
    in the order they appear in the list. New attributes are appended to the
    end of the list. The elements of the list are joined by the `delimiter`
    and treated as a single ID element.
    EOT
  default     = []
}

variable "labels_as_tags" {
  type        = set(string)
  description = <<-EOT
    Set of labels (ID elements) to include as tags in the `tags` output.
    Default is to include all labels.
    Tags with empty values will not be included in the `tags` output.
    Set to `[]` to suppress all generated tags.
    **Notes:**
      The value of the `name` tag, if included, will be the `id`, not the `name`.
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be
      changed in later chained modules. Attempts to change it will be silently ignored.
    EOT
  default     = []
}

variable "additional_tag_map" {
  type        = map(string)
  description = <<-EOT
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.
    This is for some rare cases where resources want additional configuration of tags
    and therefore take a list of maps with tag key, value, and additional configuration.
    EOT
  default     = {}
}

variable "label_order" {
  type        = list(string)
  description = <<-EOT
    The order in which the labels (ID elements) appear in the `id`.
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.
    EOT
  default     = ["namespace", "stage", "tenant", "environment", "name", "attributes"]
}

variable "regex_replace_chars" {
  type        = string
  description = <<-EOT
    Terraform regular expression (regex) string.
    Characters matching the regex will be removed from the ID elements.
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.
  EOT
  default     = null
}

variable "id_length_limit" {
  type        = number
  description = <<-EOT
    Limit `id` to this many characters (minimum 6).
    Set to `0` for unlimited length.
    Set to `null` for keep the existing setting, which defaults to `0`.
    Does not affect `id_full`.
  EOT
  default     = null
  validation {
    condition     = var.id_length_limit == null ? true : var.id_length_limit >= 6 || var.id_length_limit == 0
    error_message = "The id_length_limit must be >= 6 if supplied (not null), or 0 for unlimited length."
  }
}

variable "label_key_case" {
  type        = string
  description = <<-EOT
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.
    Does not affect keys of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper`.
    Default value: `title`.
  EOT
  default     = null

  validation {
    condition     = var.label_key_case == null ? true : contains(["lower", "title", "upper"], var.label_key_case)
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }
}

variable "label_value_case" {
  type        = string
  description = <<-EOT
    Controls the letter case of ID elements (labels) as included in `id`,
    set as tag values, and output by this module individually.
    Does not affect values of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.
    Default value: `lower`.
  EOT
  default     = null

  validation {
    condition     = var.label_value_case == null ? true : contains(["lower", "title", "upper", "none"], var.label_value_case)
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "descriptor_formats" {
  type        = any
  description = <<-EOT
    Describe additional descriptors to be output in the `descriptors` output map.
    Map of maps. Keys are names of descriptors. Values are maps of the form
    `{
       format = string
       labels = list(string)
    }`
    (Type is `any` so the map values can later be enhanced to provide additional options.)
    `format` is a Terraform format string to be passed to the `format()` function.
    `labels` is a list of labels, in order, to pass to `format()` function.
    Label values will be normalized before being passed to `format()` so they will be
    identical to how they appear in `id`.
    Default is `{}` (`descriptors` output will be empty).
    EOT
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = <<-EOT
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).
    Neither the tag keys nor the tag values will be modified by this module.
    EOT
  default     = {}
  validation {
    condition = alltrue([
      contains(keys(var.tags), "AppID"),
      contains(keys(var.tags), "CostString"),
      contains(keys(var.tags), "Environment") && contains(["prd", "stg", "tst", "uat", "dev", "sbx"], var.tags["Environment"])
    ])
    error_message = "Mandatory tags are not passed correctly, check the variable condition"
  }
}
############################# End of null-label Variables #############################

variable "mssql_database_name" {
  description = "Specifies the name of the Mssql Database"
  type        = string
  default     = null
}

variable "server_id" {
  description = "(Required) The id of the MS SQL Server on which to create the database. Changing this forces a new resource to be created."
  type        = string
}

variable "auto_pause_delay_in_minutes" {
  description = "(Optional) Time in minutes after which database is automatically paused. A value of `-1` means that automatic pause is disabled. This property is only settable for Serverless databases."
  type        = number
  default     = null
}

variable "collation" {
  description = "(Optional) Specifies the collation of the database. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "create_mode" {
  description = "(Optional) The create mode of the database. Possible values are `Copy`, `Default`, `OnlineSecondary`, `PointInTimeRestore`, `Recovery`, `Restore`, `RestoreExternalBackup`, `RestoreExternalBackupSec..."
  type        = string
  default     = null
  validation {
    condition     = var.create_mode == null || contains(["Copy", "Default", "OnlineSecondary", "PointInTimeRestore", "Recovery", "Restore", "RestoreExternalBackup", "RestoreExternalBackupSecondary", "RestoreLongTermRetentionBackup", "Secondary"], var.create_mode)
    error_message = "create_mode must be one of: Copy, Default, OnlineSecondary, PointInTimeRestore, Recovery, Restore, RestoreExternalBackup, RestoreExternalBackupSecondary, RestoreLongTermRetentionBackup, Secondary."
  }
}

variable "creation_source_database_id" {
  description = "(Optional) The ID of the source database from which to create the new database. This should only be used for databases with `create_mode` values that use another database as reference. Changing thi..."
  type        = string
  default     = null
}

variable "elastic_pool_id" {
  description = "(Optional) Specifies the ID of the elastic pool containing this database."
  type        = string
  default     = null
}

variable "enclave_type" {
  description = "(Optional) Specifies the type of enclave to be used by the elastic pool. When `enclave_type` is not specified (e.g., the default) enclaves are not enabled on the database. Once enabled (e.g., by sp..."
  type        = string
  default     = null
}

variable "geo_backup_enabled" {
  description = "(Optional) A boolean that specifies if the Geo Backup Policy is enabled. Defaults to `true`."
  type        = bool
  default     = null
}

variable "ledger_enabled" {
  description = "(Optional) A boolean that specifies if this is a ledger database. Defaults to `false`. Changing this forces a new resource to be created."
  type        = bool
  default     = null
}

variable "license_type" {
  description = "(Optional) Specifies the license type applied to this database. Possible values are `LicenseIncluded` and `BasePrice`."
  type        = string
  default     = null
  validation {
    condition     = var.license_type == null || contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "license_type must be one of: LicenseIncluded, BasePrice."
  }
}

variable "maintenance_configuration_name" {
  description = "(Optional) The name of the Public Maintenance Configuration window to apply to the database. Valid values include `SQL_Default`, `SQL_EastUS_DB_1`, `SQL_EastUS2_DB_1`, `SQL_SoutheastAsia_DB_1`, `SQ..."
  type        = string
  default     = null
}

variable "max_size_gb" {
  description = "(Optional) The max size of the database in gigabytes."
  type        = number
  default     = null
}

variable "min_capacity" {
  description = "(Optional) Minimal capacity that database will always have allocated, if not paused. This property is only settable for Serverless databases."
  type        = number
  default     = null
}

variable "read_replica_count" {
  description = "(Optional) The number of readonly secondary replicas associated with the database to which readonly application intent connections may be routed. This property is only settable for Hyperscale editi..."
  type        = number
  default     = null
}

variable "read_scale" {
  description = "(Optional) If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property is only settable for Premium ..."
  type        = bool
  default     = null
}

variable "recover_database_id" {
  description = "(Optional) The ID of the database to be recovered. This property is only applicable when the `create_mode` is `Recovery`."
  type        = string
  default     = null
}

variable "recovery_point_id" {
  description = "(Optional) The ID of the Recovery Services Recovery Point Id to be restored. This property is only applicable when the `create_mode` is `Recovery`."
  type        = string
  default     = null
}

variable "restore_dropped_database_id" {
  description = "(Optional) The ID of the database to be restored. This property is only applicable when the `create_mode` is `Restore`."
  type        = string
  default     = null
}

variable "restore_long_term_retention_backup_id" {
  description = "(Optional) The ID of the long term retention backup to be restored. This property is only applicable when the `create_mode` is `RestoreLongTermRetentionBackup`."
  type        = string
  default     = null
}

variable "restore_point_in_time" {
  description = "(Optional) Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. This property is only settable for `create_mode`= `PointInTimeRestor..."
  type        = string
  default     = null
}

variable "sample_name" {
  description = "(Optional) Specifies the name of the sample schema to apply when creating this database. Possible value is `AdventureWorksLT`."
  type        = string
  default     = null
}

variable "secondary_type" {
  description = "(Optional) How do you want your replica to be made? Valid values include `Geo`, `Named` and `Standby`. Defaults to `Geo`. Changing this forces a new resource to be created."
  type        = string
  default     = null
  validation {
    condition     = var.secondary_type == null || contains(["Geo", "Named", "Standby"], var.secondary_type)
    error_message = "secondary_type must be one of: Geo, Named, Standby."
  }
}

variable "sku_name" {
  description = "(Optional) Specifies the name of the SKU used by the database. For example, `GP_S_Gen5_2`,`HS_Gen4_1`,`BC_Gen5_2`, `ElasticPool`, `Basic`,`S0`, `P2` ,`DW100c`, `DS100`. Changing this from the Hyper..."
  type        = string
  default     = null
}

variable "storage_account_type" {
  description = "(Optional) Specifies the storage account type used to store backups for this database. Possible values are `Geo`, `GeoZone`, `Local` and `Zone`. Defaults to `Geo`."
  type        = string
  default     = null
  validation {
    condition     = var.storage_account_type == null || contains(["Geo", "GeoZone", "Local", "Zone"], var.storage_account_type)
    error_message = "storage_account_type must be one of: Geo, GeoZone, Local, Zone."
  }
}

variable "transparent_data_encryption_enabled" {
  description = "(Optional) If set to true, Transparent Data Encryption will be enabled on the database. Defaults to `true`."
  type        = bool
  default     = null
}

variable "transparent_data_encryption_key_automatic_rotation_enabled" {
  description = "(Optional) Boolean flag to specify whether TDE automatically rotates the encryption Key to latest version or not. Possible values are `true` or `false`. Defaults to `false`."
  type        = bool
  default     = null
}

variable "transparent_data_encryption_key_vault_key_id" {
  description = "(Optional) The fully versioned `Key Vault` `Key` URL (e.g. `'https://<YourVaultName>.vault.azure.net/keys/<YourKeyName>/<YourKeyVersion>`) to be used as the `Customer Managed Key`(CMK/BYOK) for the..."
  type        = string
  default     = null
}

variable "zone_redundant" {
  description = "(Optional) Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. This property is only settable for Premium an..."
  type        = bool
  default     = null
}

variable "identity" {
  type = object({
    identity_ids = set(string)
    type         = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `identity_ids` - (Required) Specifies a list of User Assigned Managed Identity IDs to be assigned to this SQL Database.
  - `type` - (Required) Specifies the type of Managed Service Identity that should be configured on this SQL Database. Possible value is `UserAssigned`.
  DESCRIPTION
}

variable "import" {
  type = object({
    administrator_login          = string
    administrator_login_password = string
    authentication_type          = string
    storage_account_id           = optional(string)
    storage_key                  = string
    storage_key_type             = string
    storage_uri                  = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `administrator_login` - (Required) Specifies the name of the SQL administrator.
  - `administrator_login_password` - (Required) Specifies the password of the SQL administrator.
  - `authentication_type` - (Required) Specifies the type of authentication used to access the server. Valid values are `SQL` or `ADPassword`.
  - `storage_account_id` - (Optional) The resource id for the storage account used to store BACPAC file. If set, private endpoint connection will be created for the storage account. Must match storage account used for storage_uri parameter.
  - `storage_key` - (Required) Specifies the access key for the storage account.
  - `storage_key_type` - (Required) Specifies the type of access key for the storage account. Valid values are `StorageAccessKey` or `SharedAccessKey`.
  - `storage_uri` - (Required) Specifies the blob URI of the .bacpac file.
  DESCRIPTION
}

variable "long_term_retention_policy" {
  type = object({
    immutable_backups_enabled = optional(bool)
    monthly_retention         = optional(string)
    week_of_year              = optional(number)
    weekly_retention          = optional(string)
    yearly_retention          = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `immutable_backups_enabled` - (Optional) Specifies if the backups are immutable. Defaults to `false`.
  - `monthly_retention` - (Optional) The monthly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 120 months. e.g. `P1Y`, `P1M`, `P4W` or `P30D`. Defaults to `PT0S`.
  - `week_of_year` - (Optional) The week of year to take the yearly backup. Value has to be between `1` and `52`.
  - `weekly_retention` - (Optional) The weekly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 520 weeks. e.g. `P1Y`, `P1M`, `P1W` or `P7D`. Defaults to `PT0S`.
  - `yearly_retention` - (Optional) The yearly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 10 years. e.g. `P1Y`, `P12M`, `P52W` or `P365D`. Defaults to `PT0S`.
  DESCRIPTION
}

variable "short_term_retention_policy" {
  type = object({
    backup_interval_in_hours = optional(number)
    retention_days           = number
  })
  default     = null
  description = <<-DESCRIPTION
  - `backup_interval_in_hours` - (Optional) The hours between each differential backup. This is only applicable to live databases but not dropped databases. Value has to be `12` or `24`. Defaults to `12` hours.
  - `retention_days` - (Required) Point In Time Restore configuration. Value has to be between `1` and `35`.
  DESCRIPTION
}

variable "threat_detection_policy" {
  type = object({
    disabled_alerts            = optional(set(string))
    email_account_admins       = optional(string)
    email_addresses            = optional(set(string))
    retention_days             = optional(number)
    state                      = optional(string)
    storage_account_access_key = optional(string)
    storage_endpoint           = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `disabled_alerts` - (Optional) Specifies a list of alerts which should be disabled. Possible values include `Access_Anomaly`, `Sql_Injection` and `Sql_Injection_Vulnerability`.
  - `email_account_admins` - (Optional) Should the account administrators be emailed when this alert is triggered? Possible values are `Enabled` or `Disabled`. Defaults to `Disabled`.
  - `email_addresses` - (Optional) A list of email addresses which alerts should be sent to.
  - `retention_days` - (Optional) Specifies the number of days to keep in the Threat Detection audit logs.
  - `state` - (Optional) The State of the Policy. Possible values are `Enabled` or `Disabled`. Defaults to `Disabled`.
  - `storage_account_access_key` - (Optional) Specifies the identifier key of the Threat Detection audit storage account. Required if `state` is `Enabled`.
  - `storage_endpoint` - (Optional) Specifies the blob storage endpoint (e.g. <https://example.blob.core.windows.net>). This blob storage will hold all Threat Detection audit logs. Required if `state` is `Enabled`.
  DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `create` - (Optional) The create value.
  - `delete` - (Optional) The delete value.
  - `read` - (Optional) The read value.
  - `update` - (Optional) The update value.
  DESCRIPTION
}


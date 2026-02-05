resource "azurerm_mssql_database" "this" {
  count = local.enabled ? 1 : 0

  name = var.mssql_database_name != null ? var.mssql_database_name : module.this.id

  auto_pause_delay_in_minutes                                = try(var.auto_pause_delay_in_minutes, null)
  collation                                                  = try(var.collation, null)
  create_mode                                                = try(var.create_mode, null)
  creation_source_database_id                                = try(var.creation_source_database_id, null)
  elastic_pool_id                                            = try(var.elastic_pool_id, null)
  enclave_type                                               = try(var.enclave_type, null)
  geo_backup_enabled                                         = try(var.geo_backup_enabled, null)
  ledger_enabled                                             = try(var.ledger_enabled, null)
  license_type                                               = try(var.license_type, null)
  maintenance_configuration_name                             = try(var.maintenance_configuration_name, null)
  max_size_gb                                                = try(var.max_size_gb, null)
  min_capacity                                               = try(var.min_capacity, null)
  read_replica_count                                         = try(var.read_replica_count, null)
  read_scale                                                 = try(var.read_scale, null)
  recover_database_id                                        = try(var.recover_database_id, null)
  recovery_point_id                                          = try(var.recovery_point_id, null)
  restore_dropped_database_id                                = try(var.restore_dropped_database_id, null)
  restore_long_term_retention_backup_id                      = try(var.restore_long_term_retention_backup_id, null)
  restore_point_in_time                                      = try(var.restore_point_in_time, null)
  sample_name                                                = try(var.sample_name, null)
  secondary_type                                             = try(var.secondary_type, null)
  server_id                                                  = var.server_id
  sku_name                                                   = try(var.sku_name, null)
  storage_account_type                                       = try(var.storage_account_type, null)
  transparent_data_encryption_enabled                        = try(var.transparent_data_encryption_enabled, null)
  transparent_data_encryption_key_automatic_rotation_enabled = try(var.transparent_data_encryption_key_automatic_rotation_enabled, null)
  transparent_data_encryption_key_vault_key_id               = try(var.transparent_data_encryption_key_vault_key_id, null)
  zone_redundant                                             = try(var.zone_redundant, null)
  tags                                                       = local.tags

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      identity_ids = identity.value.identity_ids
      type         = identity.value.type
    }
  }
  dynamic "import" {
    for_each = var.import != null ? [var.import] : []
    content {
      administrator_login          = import.value.administrator_login
      administrator_login_password = import.value.administrator_login_password
      authentication_type          = import.value.authentication_type
      storage_account_id           = import.value.storage_account_id
      storage_key                  = import.value.storage_key
      storage_key_type             = import.value.storage_key_type
      storage_uri                  = import.value.storage_uri
    }
  }
  dynamic "long_term_retention_policy" {
    for_each = var.long_term_retention_policy != null ? [var.long_term_retention_policy] : []
    content {
      immutable_backups_enabled = long_term_retention_policy.value.immutable_backups_enabled
      monthly_retention         = long_term_retention_policy.value.monthly_retention
      week_of_year              = long_term_retention_policy.value.week_of_year
      weekly_retention          = long_term_retention_policy.value.weekly_retention
      yearly_retention          = long_term_retention_policy.value.yearly_retention
    }
  }
  dynamic "short_term_retention_policy" {
    for_each = var.short_term_retention_policy != null ? [var.short_term_retention_policy] : []
    content {
      backup_interval_in_hours = short_term_retention_policy.value.backup_interval_in_hours
      retention_days           = short_term_retention_policy.value.retention_days
    }
  }
  dynamic "threat_detection_policy" {
    for_each = var.threat_detection_policy != null ? [var.threat_detection_policy] : []
    content {
      disabled_alerts            = threat_detection_policy.value.disabled_alerts
      email_account_admins       = threat_detection_policy.value.email_account_admins
      email_addresses            = threat_detection_policy.value.email_addresses
      retention_days             = threat_detection_policy.value.retention_days
      state                      = threat_detection_policy.value.state
      storage_account_access_key = threat_detection_policy.value.storage_account_access_key
      storage_endpoint           = threat_detection_policy.value.storage_endpoint
    }
  }
  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

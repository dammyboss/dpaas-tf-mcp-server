resource "azurerm_mssql_server" "this" {
  count               = local.enabled ? 1 : 0

  name                = var.mssql_server_name != null ? var.mssql_server_name : module.this.id
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login                          = try(var.administrator_login, null)
  administrator_login_password                 = try(var.administrator_login_password, null)
  administrator_login_password_wo              = try(var.administrator_login_password_wo, null)
  administrator_login_password_wo_version      = try(var.administrator_login_password_wo_version, null)
  connection_policy                            = try(var.connection_policy, null)
  express_vulnerability_assessment_enabled     = try(var.express_vulnerability_assessment_enabled, null)
  minimum_tls_version                          = try(var.minimum_tls_version, null)
  outbound_network_restriction_enabled         = try(var.outbound_network_restriction_enabled, null)
  primary_user_assigned_identity_id            = try(var.primary_user_assigned_identity_id, null)
  public_network_access_enabled                = try(var.public_network_access_enabled, null)
  transparent_data_encryption_key_vault_key_id = try(var.transparent_data_encryption_key_vault_key_id, null)
  version                                      = var.version
  tags                = local.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [var.azuread_administrator] : []
    content {
      azuread_authentication_only = azuread_administrator.value.azuread_authentication_only
      login_username = azuread_administrator.value.login_username
      object_id = azuread_administrator.value.object_id
      tenant_id = azuread_administrator.value.tenant_id
    }
  }
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      identity_ids = identity.value.identity_ids
      type = identity.value.type
    }
  }
  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

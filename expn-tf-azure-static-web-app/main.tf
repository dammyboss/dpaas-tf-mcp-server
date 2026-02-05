resource "azurerm_static_web_app" "this" {
  count = local.enabled ? 1 : 0

  name                = var.static_web_app_name != null ? var.static_web_app_name : module.this.id
  location            = var.location
  resource_group_name = var.resource_group_name

  app_settings                       = try(var.app_settings, null)
  configuration_file_changes_enabled = try(var.configuration_file_changes_enabled, null)
  preview_environments_enabled       = try(var.preview_environments_enabled, null)
  public_network_access_enabled      = try(var.public_network_access_enabled, null)
  repository_branch                  = try(var.repository_branch, null)
  repository_token                   = try(var.repository_token, null)
  repository_url                     = try(var.repository_url, null)
  sku_size                           = try(var.sku_size, null)
  sku_tier                           = try(var.sku_tier, null)
  tags                               = local.tags

  dynamic "basic_auth" {
    for_each = var.basic_auth != null ? [var.basic_auth] : []
    content {
      environments = basic_auth.value.environments
      password     = basic_auth.value.password
    }
  }
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      identity_ids = identity.value.identity_ids
      type         = identity.value.type
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

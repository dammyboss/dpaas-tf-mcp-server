# outputs.tf
output "id" {
  description = "The ID of the Static Web App"
  value       = azurerm_static_web_app.this
}

output "api_key" {
  description = "The api key of the Static Web App"
  value       = azurerm_static_web_app.this[*].api_key
}

output "default_host_name" {
  description = "The default host name of the Static Web App"
  value       = azurerm_static_web_app.this[*].default_host_name
}

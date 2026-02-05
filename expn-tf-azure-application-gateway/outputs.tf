# outputs.tf
output "id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.this
}

output "private_endpoint_connection" {
  description = "The private endpoint connection of the Application Gateway"
  value       = azurerm_application_gateway.this[*].private_endpoint_connection
}

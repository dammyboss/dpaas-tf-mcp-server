# outputs.tf
output "id" {
  description = "The ID of the Mssql Server"
  value       = azurerm_mssql_server.this
}

output "fully_qualified_domain_name" {
  description = "The fully qualified domain name of the Mssql Server"
  value       = azurerm_mssql_server.this[*].fully_qualified_domain_name
}

output "restorable_dropped_database_ids" {
  description = "The restorable dropped database ids of the Mssql Server"
  value       = azurerm_mssql_server.this[*].restorable_dropped_database_ids
}

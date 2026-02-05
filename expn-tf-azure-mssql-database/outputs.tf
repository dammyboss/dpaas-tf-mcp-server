# outputs.tf
output "id" {
  description = "The ID of the Mssql Database"
  value       = azurerm_mssql_database.this
}

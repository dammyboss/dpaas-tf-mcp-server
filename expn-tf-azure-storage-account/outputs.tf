# outputs.tf
output "id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.this
}

output "primary_access_key" {
  description = "The primary access key of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_access_key
}

output "primary_blob_connection_string" {
  description = "The primary blob connection string of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_blob_connection_string
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The primary blob host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_blob_host
}

output "primary_blob_internet_endpoint" {
  description = "The primary blob internet endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_blob_internet_endpoint
}

output "primary_blob_internet_host" {
  description = "The primary blob internet host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_blob_internet_host
}

output "primary_blob_microsoft_endpoint" {
  description = "The primary blob microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_blob_microsoft_endpoint
}

output "primary_blob_microsoft_host" {
  description = "The primary blob microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_blob_microsoft_host
}

output "primary_connection_string" {
  description = "The primary connection string of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_connection_string
}

output "primary_dfs_endpoint" {
  description = "The primary dfs endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_dfs_endpoint
}

output "primary_dfs_host" {
  description = "The primary dfs host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_dfs_host
}

output "primary_dfs_internet_endpoint" {
  description = "The primary dfs internet endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_dfs_internet_endpoint
}

output "primary_dfs_internet_host" {
  description = "The primary dfs internet host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_dfs_internet_host
}

output "primary_dfs_microsoft_endpoint" {
  description = "The primary dfs microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_dfs_microsoft_endpoint
}

output "primary_dfs_microsoft_host" {
  description = "The primary dfs microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_dfs_microsoft_host
}

output "primary_file_endpoint" {
  description = "The primary file endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_file_endpoint
}

output "primary_file_host" {
  description = "The primary file host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_file_host
}

output "primary_file_internet_endpoint" {
  description = "The primary file internet endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_file_internet_endpoint
}

output "primary_file_internet_host" {
  description = "The primary file internet host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_file_internet_host
}

output "primary_file_microsoft_endpoint" {
  description = "The primary file microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_file_microsoft_endpoint
}

output "primary_file_microsoft_host" {
  description = "The primary file microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_file_microsoft_host
}

output "primary_location" {
  description = "The primary location of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_location
}

output "primary_queue_endpoint" {
  description = "The primary queue endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_queue_endpoint
}

output "primary_queue_host" {
  description = "The primary queue host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_queue_host
}

output "primary_queue_microsoft_endpoint" {
  description = "The primary queue microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_queue_microsoft_endpoint
}

output "primary_queue_microsoft_host" {
  description = "The primary queue microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_queue_microsoft_host
}

output "primary_table_endpoint" {
  description = "The primary table endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_table_endpoint
}

output "primary_table_host" {
  description = "The primary table host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_table_host
}

output "primary_table_microsoft_endpoint" {
  description = "The primary table microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_table_microsoft_endpoint
}

output "primary_table_microsoft_host" {
  description = "The primary table microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_table_microsoft_host
}

output "primary_web_endpoint" {
  description = "The primary web endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_web_endpoint
}

output "primary_web_host" {
  description = "The primary web host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_web_host
}

output "primary_web_internet_endpoint" {
  description = "The primary web internet endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_web_internet_endpoint
}

output "primary_web_internet_host" {
  description = "The primary web internet host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_web_internet_host
}

output "primary_web_microsoft_endpoint" {
  description = "The primary web microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_web_microsoft_endpoint
}

output "primary_web_microsoft_host" {
  description = "The primary web microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].primary_web_microsoft_host
}

output "secondary_access_key" {
  description = "The secondary access key of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_access_key
}

output "secondary_blob_connection_string" {
  description = "The secondary blob connection string of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_blob_connection_string
}

output "secondary_blob_endpoint" {
  description = "The secondary blob endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_blob_endpoint
}

output "secondary_blob_host" {
  description = "The secondary blob host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_blob_host
}

output "secondary_blob_internet_endpoint" {
  description = "The secondary blob internet endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_blob_internet_endpoint
}

output "secondary_blob_internet_host" {
  description = "The secondary blob internet host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_blob_internet_host
}

output "secondary_blob_microsoft_endpoint" {
  description = "The secondary blob microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_blob_microsoft_endpoint
}

output "secondary_blob_microsoft_host" {
  description = "The secondary blob microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_blob_microsoft_host
}

output "secondary_connection_string" {
  description = "The secondary connection string of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_connection_string
}

output "secondary_dfs_endpoint" {
  description = "The secondary dfs endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_dfs_endpoint
}

output "secondary_dfs_host" {
  description = "The secondary dfs host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_dfs_host
}

output "secondary_dfs_internet_endpoint" {
  description = "The secondary dfs internet endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_dfs_internet_endpoint
}

output "secondary_dfs_internet_host" {
  description = "The secondary dfs internet host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_dfs_internet_host
}

output "secondary_dfs_microsoft_endpoint" {
  description = "The secondary dfs microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_dfs_microsoft_endpoint
}

output "secondary_dfs_microsoft_host" {
  description = "The secondary dfs microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_dfs_microsoft_host
}

output "secondary_file_endpoint" {
  description = "The secondary file endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_file_endpoint
}

output "secondary_file_host" {
  description = "The secondary file host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_file_host
}

output "secondary_file_internet_endpoint" {
  description = "The secondary file internet endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_file_internet_endpoint
}

output "secondary_file_internet_host" {
  description = "The secondary file internet host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_file_internet_host
}

output "secondary_file_microsoft_endpoint" {
  description = "The secondary file microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_file_microsoft_endpoint
}

output "secondary_file_microsoft_host" {
  description = "The secondary file microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_file_microsoft_host
}

output "secondary_location" {
  description = "The secondary location of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_location
}

output "secondary_queue_endpoint" {
  description = "The secondary queue endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_queue_endpoint
}

output "secondary_queue_host" {
  description = "The secondary queue host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_queue_host
}

output "secondary_queue_microsoft_endpoint" {
  description = "The secondary queue microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_queue_microsoft_endpoint
}

output "secondary_queue_microsoft_host" {
  description = "The secondary queue microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_queue_microsoft_host
}

output "secondary_table_endpoint" {
  description = "The secondary table endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_table_endpoint
}

output "secondary_table_host" {
  description = "The secondary table host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_table_host
}

output "secondary_table_microsoft_endpoint" {
  description = "The secondary table microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_table_microsoft_endpoint
}

output "secondary_table_microsoft_host" {
  description = "The secondary table microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_table_microsoft_host
}

output "secondary_web_endpoint" {
  description = "The secondary web endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_web_endpoint
}

output "secondary_web_host" {
  description = "The secondary web host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_web_host
}

output "secondary_web_internet_endpoint" {
  description = "The secondary web internet endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_web_internet_endpoint
}

output "secondary_web_internet_host" {
  description = "The secondary web internet host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_web_internet_host
}

output "secondary_web_microsoft_endpoint" {
  description = "The secondary web microsoft endpoint of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_web_microsoft_endpoint
}

output "secondary_web_microsoft_host" {
  description = "The secondary web microsoft host of the Storage Account"
  value       = azurerm_storage_account.this[*].secondary_web_microsoft_host
}

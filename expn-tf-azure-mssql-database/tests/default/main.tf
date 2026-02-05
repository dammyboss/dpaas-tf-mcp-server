resource "azurerm_resource_group" "this" {
  name     = "expn-msp-sbx-mssql-rg"
  location = "uksouth"
}

resource "azurerm_mssql_server" "this" {
  name                         = "expn-msp-sbx-mssql-server"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "adminUser"
  administrator_login_password = "P@ssw0rd1234!"
}

module "mssql_database" {

  source = "../.."

  enabled = true

  namespace   = "expn"
  tenant      = "msp"
  environment = "sbx"
  name        = "sample"

  # Required attributes
  server_id = azurerm_mssql_server.this.id

  tags = {
    "CostString"  = "0000.111.11.22"
    "AppID"       = "0"
    "Environment" = "sbx"
  }
  depends_on = [ azurerm_mssql_server.this ]
}

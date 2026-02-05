module "storage_account" {

  source = "../.."

  enabled = true

  namespace   = "expn"
  tenant      = "msp"
  environment = "sbx"
  name        = "sample"

  storage_account_name = "expnmspsbxstorage"
  location             = "East US 2"
  resource_group_name  = "eits-Sandbox-mspsandbox-BU-07959a-rg"

  # Required attributes
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    "CostString"  = "0000.111.11.22"
    "AppID"       = "0"
    "Environment" = "sbx"
  }
}

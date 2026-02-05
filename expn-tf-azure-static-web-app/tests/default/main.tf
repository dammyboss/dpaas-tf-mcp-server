module "static_web_app" {

  source = "../.."

  enabled = false

  namespace   = "expn"
  tenant      = "msp"
  environment = "sbx"
  name        = "sample"

  # static_web_app_name       = "example-static-web-app"
  location            = "East US 2"
  resource_group_name = "eits-Sandbox-mspsandbox-BU-07959a-rg"

  tags = {
    "CostString"  = "0000.111.11.22"
    "AppID"       = "0"
    "Environment" = "sbx"
  }
}

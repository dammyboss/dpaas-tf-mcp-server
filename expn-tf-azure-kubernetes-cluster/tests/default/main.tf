module "kubernetes_cluster" {

  source = "../.."

  enabled = true

  namespace   = "expn"
  tenant      = "msp"
  environment = "sbx"
  name        = "sample"

  # kubernetes_cluster_name   = "example-kubernetes-cluster"
  location            = "East US 2"
  resource_group_name = "eits-Sandbox-mspsandbox-BU-07959a-rg"

  # One of dns_prefix or dns_prefix_private_cluster required
  dns_prefix = "expnaks"

  # Required blocks
  default_node_pool = {
    name = "default"
  }

  # One of identity or service_principal required
  identity = {
    type = "SystemAssigned"
  }

  tags = {
    "CostString"  = "0000.111.11.22"
    "AppID"       = "0"
    "Environment" = "sbx"
  }
}

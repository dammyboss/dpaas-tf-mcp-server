module "application_gateway" {

  source = "../.."

  enabled = true

  namespace   = "expn"
  tenant      = "msp"
  environment = "sbx"
  name        = "sample"

  # application_gateway_name  = "example-application-gateway"
  location            = "East US 2"
  resource_group_name = "eits-Sandbox-mspsandbox-BU-07959a-rg"

  # Required blocks
  backend_address_pool = {
    backend_address_pool-1 = {
      name = "example-name"
    }
  }
  backend_http_settings = {
    backend_http_settings-1 = {
      cookie_based_affinity = "example-value"
      name                  = "example-name"
      port                  = 1
      protocol              = "example-value"
    }
  }
  frontend_ip_configuration = {
    frontend_ip_configuration-1 = {
      name = "example-name"
    }
  }
  frontend_port = {
    frontend_port-1 = {
      name = "example-name"
      port = 1
    }
  }
  gateway_ip_configuration = {
    gateway_ip_configuration-1 = {
      name      = "example-name"
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Example.Provider/resources/example-subnet"
    }
  }
  http_listener = {
    http_listener-1 = {
      frontend_ip_configuration_name = "example-frontend-ip-configuration-name"
      frontend_port_name             = "example-frontend-port-name"
      name                           = "example-name"
      protocol                       = "example-value"
    }
  }
  request_routing_rule = {
    request_routing_rule-1 = {
      http_listener_name = "example-http-listener-name"
      name               = "example-name"
      rule_type          = "example-value"
    }
  }
  sku = {
    name = "example-name"
    tier = "example-value"
  }

  tags = {
    "CostString"  = "0000.111.11.22"
    "AppID"       = "0"
    "Environment" = "sbx"
  }
}

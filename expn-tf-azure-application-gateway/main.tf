resource "azurerm_application_gateway" "this" {
  count = local.enabled ? 1 : 0

  name                = var.application_gateway_name != null ? var.application_gateway_name : module.this.id
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_http2                      = try(var.enable_http2, null)
  fips_enabled                      = try(var.fips_enabled, null)
  firewall_policy_id                = try(var.firewall_policy_id, null)
  force_firewall_policy_association = try(var.force_firewall_policy_association, null)
  zones                             = try(var.zones, null)
  tags                              = local.tags

  dynamic "authentication_certificate" {
    for_each = var.authentication_certificate != null ? var.authentication_certificate : {}
    content {
      data = authentication_certificate.value.data
      name = authentication_certificate.value.name
    }
  }
  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [var.autoscale_configuration] : []
    content {
      max_capacity = autoscale_configuration.value.max_capacity
      min_capacity = autoscale_configuration.value.min_capacity
    }
  }
  dynamic "backend_address_pool" {
    for_each = var.backend_address_pool != null ? var.backend_address_pool : {}
    content {
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
      name         = backend_address_pool.value.name
    }
  }
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings != null ? var.backend_http_settings : {}
    content {
      affinity_cookie_name                 = backend_http_settings.value.affinity_cookie_name
      cookie_based_affinity                = backend_http_settings.value.cookie_based_affinity
      dedicated_backend_connection_enabled = backend_http_settings.value.dedicated_backend_connection_enabled
      host_name                            = backend_http_settings.value.host_name
      name                                 = backend_http_settings.value.name
      path                                 = backend_http_settings.value.path
      pick_host_name_from_backend_address  = backend_http_settings.value.pick_host_name_from_backend_address
      port                                 = backend_http_settings.value.port
      probe_name                           = backend_http_settings.value.probe_name
      protocol                             = backend_http_settings.value.protocol
      request_timeout                      = backend_http_settings.value.request_timeout
      trusted_root_certificate_names       = backend_http_settings.value.trusted_root_certificate_names

      dynamic "authentication_certificate" {
        for_each = backend_http_settings.value.authentication_certificate != null ? backend_http_settings.value.authentication_certificate : {}
        content {
          name = authentication_certificate.value.name
        }
      }

      dynamic "connection_draining" {
        for_each = backend_http_settings.value.connection_draining != null ? [backend_http_settings.value.connection_draining] : []
        content {
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
          enabled           = connection_draining.value.enabled
        }
      }
    }
  }
  dynamic "custom_error_configuration" {
    for_each = var.custom_error_configuration != null ? var.custom_error_configuration : {}
    content {
      custom_error_page_url = custom_error_configuration.value.custom_error_page_url
      status_code           = custom_error_configuration.value.status_code
    }
  }
  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configuration != null ? var.frontend_ip_configuration : {}
    content {
      name                            = frontend_ip_configuration.value.name
      private_ip_address              = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation   = frontend_ip_configuration.value.private_ip_address_allocation
      private_link_configuration_name = frontend_ip_configuration.value.private_link_configuration_name
      public_ip_address_id            = frontend_ip_configuration.value.public_ip_address_id
      subnet_id                       = frontend_ip_configuration.value.subnet_id
    }
  }
  dynamic "frontend_port" {
    for_each = var.frontend_port != null ? var.frontend_port : {}
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }
  dynamic "gateway_ip_configuration" {
    for_each = var.gateway_ip_configuration != null ? var.gateway_ip_configuration : {}
    content {
      name      = gateway_ip_configuration.value.name
      subnet_id = gateway_ip_configuration.value.subnet_id
    }
  }
  dynamic "global" {
    for_each = var.global != null ? [var.global] : []
    content {
      request_buffering_enabled  = global.value.request_buffering_enabled
      response_buffering_enabled = global.value.response_buffering_enabled
    }
  }
  dynamic "http_listener" {
    for_each = var.http_listener != null ? var.http_listener : {}
    content {
      firewall_policy_id             = http_listener.value.firewall_policy_id
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      host_name                      = http_listener.value.host_name
      host_names                     = http_listener.value.host_names
      name                           = http_listener.value.name
      protocol                       = http_listener.value.protocol
      require_sni                    = http_listener.value.require_sni
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      ssl_profile_name               = http_listener.value.ssl_profile_name

      dynamic "custom_error_configuration" {
        for_each = http_listener.value.custom_error_configuration != null ? http_listener.value.custom_error_configuration : {}
        content {
          custom_error_page_url = custom_error_configuration.value.custom_error_page_url
          status_code           = custom_error_configuration.value.status_code
        }
      }
    }
  }
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      identity_ids = identity.value.identity_ids
      type         = identity.value.type
    }
  }
  dynamic "private_link_configuration" {
    for_each = var.private_link_configuration != null ? var.private_link_configuration : {}
    content {
      name = private_link_configuration.value.name

      dynamic "ip_configuration" {
        for_each = private_link_configuration.value.ip_configuration != null ? private_link_configuration.value.ip_configuration : {}
        content {
          name                          = ip_configuration.value.name
          primary                       = ip_configuration.value.primary
          private_ip_address            = ip_configuration.value.private_ip_address
          private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
          subnet_id                     = ip_configuration.value.subnet_id
        }
      }
    }
  }
  dynamic "probe" {
    for_each = var.probe != null ? var.probe : {}
    content {
      host                                      = probe.value.host
      interval                                  = probe.value.interval
      minimum_servers                           = probe.value.minimum_servers
      name                                      = probe.value.name
      path                                      = probe.value.path
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      port                                      = probe.value.port
      protocol                                  = probe.value.protocol
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold

      dynamic "match" {
        for_each = probe.value.match != null ? [probe.value.match] : []
        content {
          body        = match.value.body
          status_code = match.value.status_code
        }
      }
    }
  }
  dynamic "redirect_configuration" {
    for_each = var.redirect_configuration != null ? var.redirect_configuration : {}
    content {
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
      name                 = redirect_configuration.value.name
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      target_url           = redirect_configuration.value.target_url
    }
  }
  dynamic "request_routing_rule" {
    for_each = var.request_routing_rule != null ? var.request_routing_rule : {}
    content {
      backend_address_pool_name   = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name  = request_routing_rule.value.backend_http_settings_name
      http_listener_name          = request_routing_rule.value.http_listener_name
      name                        = request_routing_rule.value.name
      priority                    = request_routing_rule.value.priority
      redirect_configuration_name = request_routing_rule.value.redirect_configuration_name
      rewrite_rule_set_name       = request_routing_rule.value.rewrite_rule_set_name
      rule_type                   = request_routing_rule.value.rule_type
      url_path_map_name           = request_routing_rule.value.url_path_map_name
    }
  }
  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_set != null ? var.rewrite_rule_set : {}
    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value.rewrite_rule != null ? rewrite_rule_set.value.rewrite_rule : {}
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = rewrite_rule.value.condition != null ? rewrite_rule.value.condition : {}
            content {
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
              pattern     = condition.value.pattern
              variable    = condition.value.variable
            }
          }

          dynamic "request_header_configuration" {
            for_each = rewrite_rule.value.request_header_configuration != null ? rewrite_rule.value.request_header_configuration : {}
            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = rewrite_rule.value.response_header_configuration != null ? rewrite_rule.value.response_header_configuration : {}
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

          dynamic "url" {
            for_each = rewrite_rule.value.url != null ? [rewrite_rule.value.url] : []
            content {
              components   = url.value.components
              path         = url.value.path
              query_string = url.value.query_string
              reroute      = url.value.reroute
            }
          }
        }
      }
    }
  }
  dynamic "sku" {
    for_each = var.sku != null ? [var.sku] : []
    content {
      capacity = sku.value.capacity
      name     = sku.value.name
      tier     = sku.value.tier
    }
  }
  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate != null ? var.ssl_certificate : {}
    content {
      data                = ssl_certificate.value.data
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
      name                = ssl_certificate.value.name
      password            = ssl_certificate.value.password
    }
  }
  dynamic "ssl_policy" {
    for_each = var.ssl_policy != null ? [var.ssl_policy] : []
    content {
      cipher_suites        = ssl_policy.value.cipher_suites
      disabled_protocols   = ssl_policy.value.disabled_protocols
      min_protocol_version = ssl_policy.value.min_protocol_version
      policy_name          = ssl_policy.value.policy_name
      policy_type          = ssl_policy.value.policy_type
    }
  }
  dynamic "ssl_profile" {
    for_each = var.ssl_profile != null ? var.ssl_profile : {}
    content {
      name                                 = ssl_profile.value.name
      trusted_client_certificate_names     = ssl_profile.value.trusted_client_certificate_names
      verify_client_cert_issuer_dn         = ssl_profile.value.verify_client_cert_issuer_dn
      verify_client_certificate_revocation = ssl_profile.value.verify_client_certificate_revocation

      dynamic "ssl_policy" {
        for_each = ssl_profile.value.ssl_policy != null ? [ssl_profile.value.ssl_policy] : []
        content {
          cipher_suites        = ssl_policy.value.cipher_suites
          disabled_protocols   = ssl_policy.value.disabled_protocols
          min_protocol_version = ssl_policy.value.min_protocol_version
          policy_name          = ssl_policy.value.policy_name
          policy_type          = ssl_policy.value.policy_type
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
  dynamic "trusted_client_certificate" {
    for_each = var.trusted_client_certificate != null ? var.trusted_client_certificate : {}
    content {
      data = trusted_client_certificate.value.data
      name = trusted_client_certificate.value.name
    }
  }
  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificate != null ? var.trusted_root_certificate : {}
    content {
      data                = trusted_root_certificate.value.data
      key_vault_secret_id = trusted_root_certificate.value.key_vault_secret_id
      name                = trusted_root_certificate.value.name
    }
  }
  dynamic "url_path_map" {
    for_each = var.url_path_map != null ? var.url_path_map : {}
    content {
      default_backend_address_pool_name   = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name  = url_path_map.value.default_backend_http_settings_name
      default_redirect_configuration_name = url_path_map.value.default_redirect_configuration_name
      default_rewrite_rule_set_name       = url_path_map.value.default_rewrite_rule_set_name
      name                                = url_path_map.value.name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rule != null ? url_path_map.value.path_rule : {}
        content {
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          firewall_policy_id          = path_rule.value.firewall_policy_id
          name                        = path_rule.value.name
          paths                       = path_rule.value.paths
          redirect_configuration_name = path_rule.value.redirect_configuration_name
          rewrite_rule_set_name       = path_rule.value.rewrite_rule_set_name
        }
      }
    }
  }
  dynamic "waf_configuration" {
    for_each = var.waf_configuration != null ? [var.waf_configuration] : []
    content {
      enabled                  = waf_configuration.value.enabled
      file_upload_limit_mb     = waf_configuration.value.file_upload_limit_mb
      firewall_mode            = waf_configuration.value.firewall_mode
      max_request_body_size_kb = waf_configuration.value.max_request_body_size_kb
      request_body_check       = waf_configuration.value.request_body_check
      rule_set_type            = waf_configuration.value.rule_set_type
      rule_set_version         = waf_configuration.value.rule_set_version

      dynamic "disabled_rule_group" {
        for_each = waf_configuration.value.disabled_rule_group != null ? waf_configuration.value.disabled_rule_group : {}
        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = disabled_rule_group.value.rules
        }
      }

      dynamic "exclusion" {
        for_each = waf_configuration.value.exclusion != null ? waf_configuration.value.exclusion : {}
        content {
          match_variable          = exclusion.value.match_variable
          selector                = exclusion.value.selector
          selector_match_operator = exclusion.value.selector_match_operator
        }
      }
    }
  }
}

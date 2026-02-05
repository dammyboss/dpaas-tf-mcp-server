resource "azurerm_kubernetes_cluster" "this" {
  count = local.enabled ? 1 : 0

  name                = var.kubernetes_cluster_name != null ? var.kubernetes_cluster_name : module.this.id
  location            = var.location
  resource_group_name = var.resource_group_name

  ai_toolchain_operator_enabled       = try(var.ai_toolchain_operator_enabled, null)
  automatic_upgrade_channel           = try(var.automatic_upgrade_channel, null)
  azure_policy_enabled                = try(var.azure_policy_enabled, null)
  cost_analysis_enabled               = try(var.cost_analysis_enabled, null)
  custom_ca_trust_certificates_base64 = try(var.custom_ca_trust_certificates_base64, null)
  disk_encryption_set_id              = try(var.disk_encryption_set_id, null)
  dns_prefix                          = try(var.dns_prefix, null)
  dns_prefix_private_cluster          = try(var.dns_prefix_private_cluster, null)
  edge_zone                           = try(var.edge_zone, null)
  http_application_routing_enabled    = try(var.http_application_routing_enabled, null)
  image_cleaner_enabled               = try(var.image_cleaner_enabled, null)
  image_cleaner_interval_hours        = try(var.image_cleaner_interval_hours, null)
  kubernetes_version                  = try(var.kubernetes_version, null)
  local_account_disabled              = try(var.local_account_disabled, null)
  node_os_upgrade_channel             = try(var.node_os_upgrade_channel, null)
  node_resource_group                 = try(var.node_resource_group, null)
  oidc_issuer_enabled                 = try(var.oidc_issuer_enabled, null)
  open_service_mesh_enabled           = try(var.open_service_mesh_enabled, null)
  private_cluster_enabled             = try(var.private_cluster_enabled, null)
  private_cluster_public_fqdn_enabled = try(var.private_cluster_public_fqdn_enabled, null)
  private_dns_zone_id                 = try(var.private_dns_zone_id, null)
  role_based_access_control_enabled   = try(var.role_based_access_control_enabled, null)
  run_command_enabled                 = try(var.run_command_enabled, null)
  sku_tier                            = try(var.sku_tier, null)
  support_plan                        = try(var.support_plan, null)
  workload_identity_enabled           = try(var.workload_identity_enabled, null)
  tags                                = local.tags

  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux != null ? [var.aci_connector_linux] : []
    content {
      subnet_name = aci_connector_linux.value.subnet_name
    }
  }
  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null ? [var.api_server_access_profile] : []
    content {
      authorized_ip_ranges                = api_server_access_profile.value.authorized_ip_ranges
      subnet_id                           = api_server_access_profile.value.subnet_id
      virtual_network_integration_enabled = api_server_access_profile.value.virtual_network_integration_enabled
    }
  }
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups                   = auto_scaler_profile.value.balance_similar_node_groups
      daemonset_eviction_for_empty_nodes_enabled    = auto_scaler_profile.value.daemonset_eviction_for_empty_nodes_enabled
      daemonset_eviction_for_occupied_nodes_enabled = auto_scaler_profile.value.daemonset_eviction_for_occupied_nodes_enabled
      empty_bulk_delete_max                         = auto_scaler_profile.value.empty_bulk_delete_max
      expander                                      = auto_scaler_profile.value.expander
      ignore_daemonsets_utilization_enabled         = auto_scaler_profile.value.ignore_daemonsets_utilization_enabled
      max_graceful_termination_sec                  = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time                    = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                             = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage                        = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay                        = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add                    = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete                 = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure                = auto_scaler_profile.value.scale_down_delay_after_failure
      scale_down_unneeded                           = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready                            = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold              = auto_scaler_profile.value.scale_down_utilization_threshold
      scan_interval                                 = auto_scaler_profile.value.scan_interval
      skip_nodes_with_local_storage                 = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods                   = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_active_directory_role_based_access_control != null ? [var.azure_active_directory_role_based_access_control] : []
    content {
      admin_group_object_ids = azure_active_directory_role_based_access_control.value.admin_group_object_ids
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
    }
  }
  dynamic "bootstrap_profile" {
    for_each = var.bootstrap_profile != null ? [var.bootstrap_profile] : []
    content {
      artifact_source       = bootstrap_profile.value.artifact_source
      container_registry_id = bootstrap_profile.value.container_registry_id
    }
  }
  dynamic "confidential_computing" {
    for_each = var.confidential_computing != null ? [var.confidential_computing] : []
    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
    }
  }
  dynamic "default_node_pool" {
    for_each = var.default_node_pool != null ? [var.default_node_pool] : []
    content {
      auto_scaling_enabled          = default_node_pool.value.auto_scaling_enabled
      capacity_reservation_group_id = default_node_pool.value.capacity_reservation_group_id
      fips_enabled                  = default_node_pool.value.fips_enabled
      gpu_driver                    = default_node_pool.value.gpu_driver
      gpu_instance                  = default_node_pool.value.gpu_instance
      host_encryption_enabled       = default_node_pool.value.host_encryption_enabled
      host_group_id                 = default_node_pool.value.host_group_id
      kubelet_disk_type             = default_node_pool.value.kubelet_disk_type
      max_count                     = default_node_pool.value.max_count
      max_pods                      = default_node_pool.value.max_pods
      min_count                     = default_node_pool.value.min_count
      name                          = default_node_pool.value.name
      node_count                    = default_node_pool.value.node_count
      node_labels                   = default_node_pool.value.node_labels
      node_public_ip_enabled        = default_node_pool.value.node_public_ip_enabled
      node_public_ip_prefix_id      = default_node_pool.value.node_public_ip_prefix_id
      only_critical_addons_enabled  = default_node_pool.value.only_critical_addons_enabled
      orchestrator_version          = default_node_pool.value.orchestrator_version
      os_disk_size_gb               = default_node_pool.value.os_disk_size_gb
      os_disk_type                  = default_node_pool.value.os_disk_type
      os_sku                        = default_node_pool.value.os_sku
      pod_subnet_id                 = default_node_pool.value.pod_subnet_id
      proximity_placement_group_id  = default_node_pool.value.proximity_placement_group_id
      scale_down_mode               = default_node_pool.value.scale_down_mode
      snapshot_id                   = default_node_pool.value.snapshot_id
      tags                          = default_node_pool.value.tags
      temporary_name_for_rotation   = default_node_pool.value.temporary_name_for_rotation
      type                          = default_node_pool.value.type
      ultra_ssd_enabled             = default_node_pool.value.ultra_ssd_enabled
      vm_size                       = default_node_pool.value.vm_size
      vnet_subnet_id                = default_node_pool.value.vnet_subnet_id
      workload_runtime              = default_node_pool.value.workload_runtime
      zones                         = default_node_pool.value.zones

      dynamic "kubelet_config" {
        for_each = default_node_pool.value.kubelet_config != null ? [default_node_pool.value.kubelet_config] : []
        content {
          allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
          container_log_max_line    = kubelet_config.value.container_log_max_line
          container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
          cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
          cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
          cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
          image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
          image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
          pod_max_pid               = kubelet_config.value.pod_max_pid
          topology_manager_policy   = kubelet_config.value.topology_manager_policy
        }
      }

      dynamic "linux_os_config" {
        for_each = default_node_pool.value.linux_os_config != null ? [default_node_pool.value.linux_os_config] : []
        content {
          swap_file_size_mb            = linux_os_config.value.swap_file_size_mb
          transparent_huge_page        = linux_os_config.value.transparent_huge_page
          transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag

          dynamic "sysctl_config" {
            for_each = linux_os_config.value.sysctl_config != null ? [linux_os_config.value.sysctl_config] : []
            content {
              fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
              fs_file_max                        = sysctl_config.value.fs_file_max
              fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
              fs_nr_open                         = sysctl_config.value.fs_nr_open
              kernel_threads_max                 = sysctl_config.value.kernel_threads_max
              net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
              net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
              net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
              net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
              net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
              net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
              net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
              net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
              net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
              net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
              net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
              net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
              net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
              net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
              net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
              net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
              net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
              net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
              net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
              net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
              net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
              vm_max_map_count                   = sysctl_config.value.vm_max_map_count
              vm_swappiness                      = sysctl_config.value.vm_swappiness
              vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
            }
          }
        }
      }

      dynamic "node_network_profile" {
        for_each = default_node_pool.value.node_network_profile != null ? [default_node_pool.value.node_network_profile] : []
        content {
          application_security_group_ids = node_network_profile.value.application_security_group_ids
          node_public_ip_tags            = node_network_profile.value.node_public_ip_tags

          dynamic "allowed_host_ports" {
            for_each = node_network_profile.value.allowed_host_ports != null ? node_network_profile.value.allowed_host_ports : {}
            content {
              port_end   = allowed_host_ports.value.port_end
              port_start = allowed_host_ports.value.port_start
              protocol   = allowed_host_ports.value.protocol
            }
          }
        }
      }

      dynamic "upgrade_settings" {
        for_each = default_node_pool.value.upgrade_settings != null ? [default_node_pool.value.upgrade_settings] : []
        content {
          drain_timeout_in_minutes      = upgrade_settings.value.drain_timeout_in_minutes
          max_surge                     = upgrade_settings.value.max_surge
          node_soak_duration_in_minutes = upgrade_settings.value.node_soak_duration_in_minutes
          undrainable_node_behavior     = upgrade_settings.value.undrainable_node_behavior
        }
      }
    }
  }
  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config != null ? [var.http_proxy_config] : []
    content {
      http_proxy  = http_proxy_config.value.http_proxy
      https_proxy = http_proxy_config.value.https_proxy
      no_proxy    = http_proxy_config.value.no_proxy
      trusted_ca  = http_proxy_config.value.trusted_ca
    }
  }
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      identity_ids = identity.value.identity_ids
      type         = identity.value.type
    }
  }
  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway != null ? [var.ingress_application_gateway] : []
    content {
      gateway_id   = ingress_application_gateway.value.gateway_id
      gateway_name = ingress_application_gateway.value.gateway_name
      subnet_cidr  = ingress_application_gateway.value.subnet_cidr
      subnet_id    = ingress_application_gateway.value.subnet_id
    }
  }
  dynamic "key_management_service" {
    for_each = var.key_management_service != null ? [var.key_management_service] : []
    content {
      key_vault_key_id         = key_management_service.value.key_vault_key_id
      key_vault_network_access = key_management_service.value.key_vault_network_access
    }
  }
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider != null ? [var.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }
  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity != null ? [var.kubelet_identity] : []
    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }
  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [var.linux_profile] : []
    content {
      admin_username = linux_profile.value.admin_username

      dynamic "ssh_key" {
        for_each = linux_profile.value.ssh_key != null ? [linux_profile.value.ssh_key] : []
        content {
          key_data = ssh_key.value.key_data
        }
      }
    }
  }
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {

      dynamic "allowed" {
        for_each = maintenance_window.value.allowed != null ? maintenance_window.value.allowed : {}
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }

      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed != null ? maintenance_window.value.not_allowed : {}
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade != null ? [var.maintenance_window_auto_upgrade] : []
    content {
      day_of_month = maintenance_window_auto_upgrade.value.day_of_month
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      duration     = maintenance_window_auto_upgrade.value.duration
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      start_date   = maintenance_window_auto_upgrade.value.start_date
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      week_index   = maintenance_window_auto_upgrade.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed != null ? maintenance_window_auto_upgrade.value.not_allowed : {}
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os != null ? [var.maintenance_window_node_os] : []
    content {
      day_of_month = maintenance_window_node_os.value.day_of_month
      day_of_week  = maintenance_window_node_os.value.day_of_week
      duration     = maintenance_window_node_os.value.duration
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      start_date   = maintenance_window_node_os.value.start_date
      start_time   = maintenance_window_node_os.value.start_time
      utc_offset   = maintenance_window_node_os.value.utc_offset
      week_index   = maintenance_window_node_os.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed != null ? maintenance_window_node_os.value.not_allowed : {}
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender != null ? [var.microsoft_defender] : []
    content {
      log_analytics_workspace_id = microsoft_defender.value.log_analytics_workspace_id
    }
  }
  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics != null ? [var.monitor_metrics] : []
    content {
      annotations_allowed = monitor_metrics.value.annotations_allowed
      labels_allowed      = monitor_metrics.value.labels_allowed
    }
  }
  dynamic "network_profile" {
    for_each = var.network_profile != null ? [var.network_profile] : []
    content {
      dns_service_ip      = network_profile.value.dns_service_ip
      ip_versions         = network_profile.value.ip_versions
      load_balancer_sku   = network_profile.value.load_balancer_sku
      network_data_plane  = network_profile.value.network_data_plane
      network_mode        = network_profile.value.network_mode
      network_plugin      = network_profile.value.network_plugin
      network_plugin_mode = network_profile.value.network_plugin_mode
      network_policy      = network_profile.value.network_policy
      outbound_type       = network_profile.value.outbound_type
      pod_cidr            = network_profile.value.pod_cidr
      pod_cidrs           = network_profile.value.pod_cidrs
      service_cidr        = network_profile.value.service_cidr
      service_cidrs       = network_profile.value.service_cidrs

      dynamic "advanced_networking" {
        for_each = network_profile.value.advanced_networking != null ? [network_profile.value.advanced_networking] : []
        content {
          observability_enabled = advanced_networking.value.observability_enabled
          security_enabled      = advanced_networking.value.security_enabled
        }
      }

      dynamic "load_balancer_profile" {
        for_each = network_profile.value.load_balancer_profile != null ? [network_profile.value.load_balancer_profile] : []
        content {
          backend_pool_type           = load_balancer_profile.value.backend_pool_type
          idle_timeout_in_minutes     = load_balancer_profile.value.idle_timeout_in_minutes
          managed_outbound_ip_count   = load_balancer_profile.value.managed_outbound_ip_count
          managed_outbound_ipv6_count = load_balancer_profile.value.managed_outbound_ipv6_count
          outbound_ip_address_ids     = load_balancer_profile.value.outbound_ip_address_ids
          outbound_ip_prefix_ids      = load_balancer_profile.value.outbound_ip_prefix_ids
          outbound_ports_allocated    = load_balancer_profile.value.outbound_ports_allocated
        }
      }

      dynamic "nat_gateway_profile" {
        for_each = network_profile.value.nat_gateway_profile != null ? [network_profile.value.nat_gateway_profile] : []
        content {
          idle_timeout_in_minutes   = nat_gateway_profile.value.idle_timeout_in_minutes
          managed_outbound_ip_count = nat_gateway_profile.value.managed_outbound_ip_count
        }
      }
    }
  }
  dynamic "node_provisioning_profile" {
    for_each = var.node_provisioning_profile != null ? [var.node_provisioning_profile] : []
    content {
      default_node_pools = node_provisioning_profile.value.default_node_pools
      mode               = node_provisioning_profile.value.mode
    }
  }
  dynamic "oms_agent" {
    for_each = var.oms_agent != null ? [var.oms_agent] : []
    content {
      log_analytics_workspace_id      = oms_agent.value.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = oms_agent.value.msi_auth_for_monitoring_enabled
    }
  }
  dynamic "service_mesh_profile" {
    for_each = var.service_mesh_profile != null ? [var.service_mesh_profile] : []
    content {
      external_ingress_gateway_enabled = service_mesh_profile.value.external_ingress_gateway_enabled
      internal_ingress_gateway_enabled = service_mesh_profile.value.internal_ingress_gateway_enabled
      mode                             = service_mesh_profile.value.mode
      revisions                        = service_mesh_profile.value.revisions

      dynamic "certificate_authority" {
        for_each = service_mesh_profile.value.certificate_authority != null ? [service_mesh_profile.value.certificate_authority] : []
        content {
          cert_chain_object_name = certificate_authority.value.cert_chain_object_name
          cert_object_name       = certificate_authority.value.cert_object_name
          key_object_name        = certificate_authority.value.key_object_name
          key_vault_id           = certificate_authority.value.key_vault_id
          root_cert_object_name  = certificate_authority.value.root_cert_object_name
        }
      }
    }
  }
  dynamic "service_principal" {
    for_each = var.service_principal != null ? [var.service_principal] : []
    content {
      client_id     = service_principal.value.client_id
      client_secret = service_principal.value.client_secret
    }
  }
  dynamic "storage_profile" {
    for_each = var.storage_profile != null ? [var.storage_profile] : []
    content {
      blob_driver_enabled         = storage_profile.value.blob_driver_enabled
      disk_driver_enabled         = storage_profile.value.disk_driver_enabled
      file_driver_enabled         = storage_profile.value.file_driver_enabled
      snapshot_controller_enabled = storage_profile.value.snapshot_controller_enabled
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
  dynamic "upgrade_override" {
    for_each = var.upgrade_override != null ? [var.upgrade_override] : []
    content {
      effective_until       = upgrade_override.value.effective_until
      force_upgrade_enabled = upgrade_override.value.force_upgrade_enabled
    }
  }
  dynamic "web_app_routing" {
    for_each = var.web_app_routing != null ? [var.web_app_routing] : []
    content {
      default_nginx_controller = web_app_routing.value.default_nginx_controller
      dns_zone_ids             = web_app_routing.value.dns_zone_ids
    }
  }
  dynamic "windows_profile" {
    for_each = var.windows_profile != null ? [var.windows_profile] : []
    content {
      admin_password = windows_profile.value.admin_password
      admin_username = windows_profile.value.admin_username
      license        = windows_profile.value.license

      dynamic "gmsa" {
        for_each = windows_profile.value.gmsa != null ? [windows_profile.value.gmsa] : []
        content {
          dns_server  = gmsa.value.dns_server
          root_domain = gmsa.value.root_domain
        }
      }
    }
  }
  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile != null ? [var.workload_autoscaler_profile] : []
    content {
      keda_enabled                    = workload_autoscaler_profile.value.keda_enabled
      vertical_pod_autoscaler_enabled = workload_autoscaler_profile.value.vertical_pod_autoscaler_enabled
    }
  }
}

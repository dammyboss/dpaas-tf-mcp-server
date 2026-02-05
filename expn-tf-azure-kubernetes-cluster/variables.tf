############################# Start of null-label Variables #############################
variable "context" {
  type        = any
  description = <<-EOT
    Single object for setting entire context at once.
    See description of individual variables for details.
    Leave string and numeric variables as `null` to use default value.
    Individual variable settings (non-null) override settings in context object,
    except for attributes, tags, and additional_tag_map, which are merged.
  EOT
  default = {
    enabled             = true
    namespace           = null
    tenant              = null
    environment         = null
    stage               = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = ["namespace", "stage", "tenant", "environment", "name", "attributes"]
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    # Note: we have to use [] instead of null for unset lists due to
    # https://github.com/hashicorp/terraform/issues/28137
    # which was not fixed until Terraform 1.0.0,
    # but we want the default to be all the labels in `label_order`
    # and we want users to be able to prevent all tag generation
    # by setting `labels_as_tags` to `[]`, so we need
    # a different sentinel to indicate "default"
    labels_as_tags = ["unset"]
  }
  validation {
    condition     = lookup(var.context, "label_key_case", null) == null ? true : contains(["lower", "title", "upper"], var.context["label_key_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }

  validation {
    condition     = lookup(var.context, "label_value_case", null) == null ? true : contains(["lower", "title", "upper", "none"], var.context["label_value_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources"
  default     = null
}

variable "namespace" {
  type        = string
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'expn', to help ensure generated IDs are globally unique"
  default     = null
}

variable "create_kubernetes_cluster" {
  type        = bool
  description = "Whether to create the Kubernetes Cluster."
  default     = true
}

variable "tenant" {
  type        = string
  description = "A customer identifier to which tenant and application, the resource belongs to, <business-unit>-<application>-<subtenant> eg: cs-bis-sbfe "
  default     = null
}

variable "environment" {
  type        = string
  description = "ID element. Usually used for environment e.g.  'prd', 'sbx', 'dev', 'UAT'"
  default     = null
}

variable "stage" {
  type        = string
  description = "ID element. Usually used to indicate role."
  default     = null
}

variable "name" {
  type        = string
  description = <<-EOT
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.
    This is the only ID element not also included as a `tag`.
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.
    EOT
  default     = null
}

variable "delimiter" {
  type        = string
  description = <<-EOT
    Delimiter to be used between ID elements.
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.
  EOT
  default     = null
}

variable "attributes" {
  type        = list(string)
  description = <<-EOT
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,
    in the order they appear in the list. New attributes are appended to the
    end of the list. The elements of the list are joined by the `delimiter`
    and treated as a single ID element.
    EOT
  default     = []
}

variable "labels_as_tags" {
  type        = set(string)
  description = <<-EOT
    Set of labels (ID elements) to include as tags in the `tags` output.
    Default is to include all labels.
    Tags with empty values will not be included in the `tags` output.
    Set to `[]` to suppress all generated tags.
    **Notes:**
      The value of the `name` tag, if included, will be the `id`, not the `name`.
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be
      changed in later chained modules. Attempts to change it will be silently ignored.
    EOT
  default     = []
}

variable "additional_tag_map" {
  type        = map(string)
  description = <<-EOT
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.
    This is for some rare cases where resources want additional configuration of tags
    and therefore take a list of maps with tag key, value, and additional configuration.
    EOT
  default     = {}
}

variable "label_order" {
  type        = list(string)
  description = <<-EOT
    The order in which the labels (ID elements) appear in the `id`.
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.
    EOT
  default     = ["namespace", "stage", "tenant", "environment", "name", "attributes"]
}

variable "regex_replace_chars" {
  type        = string
  description = <<-EOT
    Terraform regular expression (regex) string.
    Characters matching the regex will be removed from the ID elements.
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.
  EOT
  default     = null
}

variable "id_length_limit" {
  type        = number
  description = <<-EOT
    Limit `id` to this many characters (minimum 6).
    Set to `0` for unlimited length.
    Set to `null` for keep the existing setting, which defaults to `0`.
    Does not affect `id_full`.
  EOT
  default     = null
  validation {
    condition     = var.id_length_limit == null ? true : var.id_length_limit >= 6 || var.id_length_limit == 0
    error_message = "The id_length_limit must be >= 6 if supplied (not null), or 0 for unlimited length."
  }
}

variable "label_key_case" {
  type        = string
  description = <<-EOT
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.
    Does not affect keys of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper`.
    Default value: `title`.
  EOT
  default     = null

  validation {
    condition     = var.label_key_case == null ? true : contains(["lower", "title", "upper"], var.label_key_case)
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }
}

variable "label_value_case" {
  type        = string
  description = <<-EOT
    Controls the letter case of ID elements (labels) as included in `id`,
    set as tag values, and output by this module individually.
    Does not affect values of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.
    Default value: `lower`.
  EOT
  default     = null

  validation {
    condition     = var.label_value_case == null ? true : contains(["lower", "title", "upper", "none"], var.label_value_case)
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "descriptor_formats" {
  type        = any
  description = <<-EOT
    Describe additional descriptors to be output in the `descriptors` output map.
    Map of maps. Keys are names of descriptors. Values are maps of the form
    `{
       format = string
       labels = list(string)
    }`
    (Type is `any` so the map values can later be enhanced to provide additional options.)
    `format` is a Terraform format string to be passed to the `format()` function.
    `labels` is a list of labels, in order, to pass to `format()` function.
    Label values will be normalized before being passed to `format()` so they will be
    identical to how they appear in `id`.
    Default is `{}` (`descriptors` output will be empty).
    EOT
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = <<-EOT
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).
    Neither the tag keys nor the tag values will be modified by this module.
    EOT
  default     = {}
  validation {
    condition = alltrue([
      contains(keys(var.tags), "AppID"),
      contains(keys(var.tags), "CostString"),
      contains(keys(var.tags), "Environment") && contains(["prd", "stg", "tst", "uat", "dev", "sbx"], var.tags["Environment"])
    ])
    error_message = "Mandatory tags are not passed correctly, check the variable condition"
  }
}
############################# End of null-label Variables #############################

variable "kubernetes_cluster_name" {
  description = "Specifies the name of the Kubernetes Cluster"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Kubernetes Cluster"
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists"
  type        = string
}

variable "ai_toolchain_operator_enabled" {
  description = "(Optional) Specifies whether the AI Toolchain Operator should be enabled for the Cluster. Defaults to `false`."
  type        = bool
  default     = null
}

variable "automatic_upgrade_channel" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. Omitting this field sets this value to `none`."
  type        = string
  default     = null
  validation {
    condition     = var.automatic_upgrade_channel == null || contains(["patch", "rapid", "node-image", "stable"], var.automatic_upgrade_channel)
    error_message = "automatic_upgrade_channel must be one of: patch, rapid, node-image, stable."
  }
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled? For more details please visit Understand Azure Policy for Azure Kubernetes Service"
  type        = bool
  default     = null
}

variable "cost_analysis_enabled" {
  description = "(Optional) Should cost analysis be enabled for this Kubernetes Cluster? Defaults to `false`. The `sku_tier` must be set to `Standard` or `Premium` to enable this feature. Enabling this will add Kub..."
  type        = bool
  default     = null
}

variable "custom_ca_trust_certificates_base64" {
  description = "(Optional) A list of up to 10 base64 encoded CA certificates that will be added to the trust store on nodes."
  type        = list(string)
  default     = null
}

variable "disk_encryption_set_id" {
  description = "(Optional) The ID of the Disk Encryption Set which should be used for the Nodes and Volumes. More information can be found in the documentation. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "dns_prefix" {
  description = "(Optional) DNS prefix specified when creating the managed cluster. Possible values must begin and end with a letter or number, contain only letters, numbers, and hyphens and be between 1 and 54 cha..."
  type        = string
  default     = null
}

variable "dns_prefix_private_cluster" {
  description = "(Optional) Specifies the DNS prefix to use with private clusters. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "edge_zone" {
  description = "(Optional) Specifies the Extended Zone (formerly called Edge Zone) within the Azure Region where this Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = null
}

variable "image_cleaner_enabled" {
  description = "(Optional) Specifies whether Image Cleaner is enabled."
  type        = bool
  default     = null
}

variable "image_cleaner_interval_hours" {
  description = "(Optional) Specifies the interval in hours when images should be cleaned up."
  type        = number
  default     = null
}

variable "kubernetes_version" {
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). AKS do..."
  type        = string
  default     = null
}

variable "local_account_disabled" {
  description = "(Optional) If `true` local accounts will be disabled. See the documentation for more information."
  type        = bool
  default     = null
}

variable "node_os_upgrade_channel" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`. Defaults to `NodeImage`."
  type        = string
  default     = null
  validation {
    condition     = var.node_os_upgrade_channel == null || contains(["Unmanaged", "SecurityPatch", "NodeImage", "None"], var.node_os_upgrade_channel)
    error_message = "node_os_upgrade_channel must be one of: Unmanaged, SecurityPatch, NodeImage, None."
  }
}

variable "node_resource_group" {
  description = "(Optional) The name of the Resource Group where the Kubernetes Nodes should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL"
  type        = bool
  default     = null
}

variable "open_service_mesh_enabled" {
  description = "(Optional) Is Open Service Mesh enabled? For more details, please visit Open Service Mesh for AKS."
  type        = bool
  default     = null
}

variable "private_cluster_enabled" {
  description = "(Optional) Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kuber..."
  type        = bool
  default     = null
}

variable "private_cluster_public_fqdn_enabled" {
  description = "(Optional) Specifies whether a Public FQDN for this Private Cluster should be added. Defaults to `false`."
  type        = bool
  default     = null
}

variable "private_dns_zone_id" {
  description = "(Optional) Either the ID of Private DNS Zone which should be delegated to this Cluster, `System` to have AKS manage this or `None`. In case of `None` you will need to bring your own DNS server and ..."
  type        = string
  default     = null
}

variable "role_based_access_control_enabled" {
  description = "(Optional) Whether Role Based Access Control for the Kubernetes Cluster should be enabled. Defaults to `true`. Changing this forces a new resource to be created."
  type        = bool
  default     = null
}

variable "run_command_enabled" {
  description = "(Optional) Whether to enable run command for the cluster or not. Defaults to `true`."
  type        = bool
  default     = null
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are `Free`, `Standard` (which includes the Uptime SLA) and `Premium`. Defaults to `Free`."
  type        = string
  default     = null
  validation {
    condition     = var.sku_tier == null || contains(["Free", "Premium"], var.sku_tier)
    error_message = "sku_tier must be one of: Free, Premium."
  }
}

variable "support_plan" {
  description = "(Optional) Specifies the support plan which should be used for this Kubernetes Cluster. Possible values are `KubernetesOfficial` and `AKSLongTermSupport`. Defaults to `KubernetesOfficial`."
  type        = string
  default     = null
  validation {
    condition     = var.support_plan == null || contains(["KubernetesOfficial", "AKSLongTermSupport"], var.support_plan)
    error_message = "support_plan must be one of: KubernetesOfficial, AKSLongTermSupport."
  }
}

variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to `false`."
  type        = bool
  default     = null
}

variable "aci_connector_linux" {
  type = object({
    subnet_name = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `subnet_name` - (Required) The subnet name for the virtual nodes to run.
  DESCRIPTION
}

variable "api_server_access_profile" {
  type = object({
    authorized_ip_ranges                = optional(set(string))
    subnet_id                           = optional(string)
    virtual_network_integration_enabled = optional(bool)
  })
  default     = null
  description = <<-DESCRIPTION
  - `authorized_ip_ranges` - (Optional) Set of authorized IP ranges to allow access to API server, e.g. ["198.51.100.0/24"].
  - `subnet_id` - (Optional) The ID of the Subnet where the API server endpoint is delegated to.
  - `virtual_network_integration_enabled` - (Optional) Whether to enable virtual network integration for the API Server. Defaults to `false`.
  DESCRIPTION
}

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups                   = optional(bool)
    daemonset_eviction_for_empty_nodes_enabled    = optional(bool)
    daemonset_eviction_for_occupied_nodes_enabled = optional(bool)
    empty_bulk_delete_max                         = optional(string)
    expander                                      = optional(string)
    ignore_daemonsets_utilization_enabled         = optional(bool)
    max_graceful_termination_sec                  = optional(string)
    max_node_provisioning_time                    = optional(string)
    max_unready_nodes                             = optional(number)
    max_unready_percentage                        = optional(number)
    new_pod_scale_up_delay                        = optional(string)
    scale_down_delay_after_add                    = optional(string)
    scale_down_delay_after_delete                 = optional(string)
    scale_down_delay_after_failure                = optional(string)
    scale_down_unneeded                           = optional(string)
    scale_down_unready                            = optional(string)
    scale_down_utilization_threshold              = optional(string)
    scan_interval                                 = optional(string)
    skip_nodes_with_local_storage                 = optional(bool)
    skip_nodes_with_system_pods                   = optional(bool)
  })
  default     = null
  description = <<-DESCRIPTION
  - `balance_similar_node_groups` - (Optional) Detect similar node groups and balance the number of nodes between them. Defaults to `false`.
  - `daemonset_eviction_for_empty_nodes_enabled` - (Optional) Whether DaemonSet pods will be gracefully terminated from empty nodes. Defaults to `false`.
  - `daemonset_eviction_for_occupied_nodes_enabled` - (Optional) Whether DaemonSet pods will be gracefully terminated from non-empty nodes. Defaults to `true`.
  - `empty_bulk_delete_max` - (Optional) Maximum number of empty nodes that can be deleted at the same time. Defaults to `10`.
  - `expander` - (Optional) Expander to use. Possible values are `least-waste`, `priority`, `most-pods` and `random`. Defaults to `random`.
  - `ignore_daemonsets_utilization_enabled` - (Optional) Whether DaemonSet pods will be ignored when calculating resource utilization for scale down. Defaults to `false`.
  - `max_graceful_termination_sec` - (Optional) Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. Defaults to `600`.
  - `max_node_provisioning_time` - (Optional) Maximum time the autoscaler waits for a node to be provisioned. Defaults to `15m`.
  - `max_unready_nodes` - (Optional) Maximum Number of allowed unready nodes. Defaults to `3`.
  - `max_unready_percentage` - (Optional) Maximum percentage of unready nodes the cluster autoscaler will stop if the percentage is exceeded. Defaults to `45`.
  - `new_pod_scale_up_delay` - (Optional) For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. Defaults to `10s`.
  - `scale_down_delay_after_add` - (Optional) How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to `10m`.
  - `scale_down_delay_after_delete` - (Optional) How long after node deletion that scale down evaluation resumes. Defaults to the value used for `scan_interval`.
  - `scale_down_delay_after_failure` - (Optional) How long after scale down failure that scale down evaluation resumes. Defaults to `3m`.
  - `scale_down_unneeded` - (Optional) How long a node should be unneeded before it is eligible for scale down. Defaults to `10m`.
  - `scale_down_unready` - (Optional) How long an unready node should be unneeded before it is eligible for scale down. Defaults to `20m`.
  - `scale_down_utilization_threshold` - (Optional) Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to `0.5`.
  - `scan_interval` - (Optional) How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to `10s`.
  - `skip_nodes_with_local_storage` - (Optional) If `true` cluster autoscaler will never delete nodes with pods with local storage, for example, EmptyDir or HostPath. Defaults to `false`.
  - `skip_nodes_with_system_pods` - (Optional) If `true` cluster autoscaler will never delete nodes with pods from kube-system (except for DaemonSet or mirror pods). Defaults to `true`.
  DESCRIPTION
  validation {
    condition     = var.auto_scaler_profile == null || contains(["least-waste", "priority", "most-pods", "random"], var.auto_scaler_profile.expander)
    error_message = "auto_scaler_profile.expander must be one of: least-waste, priority, most-pods, random."
  }
}

variable "azure_active_directory_role_based_access_control" {
  type = object({
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool)
    tenant_id              = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `admin_group_object_ids` - (Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster.
  - `azure_rbac_enabled` - (Optional) Is Role Based Access Control based on Azure AD enabled?
  - `tenant_id` - (Optional) The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used.
  DESCRIPTION
}

variable "bootstrap_profile" {
  type = object({
    artifact_source       = optional(string)
    container_registry_id = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `artifact_source` - (Optional) The artifact source. The source where the artifacts are downloaded from. Possible values are `Cache` and `Direct`. Defaults to `Direct`.
  - `container_registry_id` - (Optional) The resource Id of Azure Container Registry.
  DESCRIPTION
  validation {
    condition     = var.bootstrap_profile == null || contains(["Cache", "Direct"], var.bootstrap_profile.artifact_source)
    error_message = "bootstrap_profile.artifact_source must be one of: Cache, Direct."
  }
}

variable "confidential_computing" {
  type = object({
    sgx_quote_helper_enabled = bool
  })
  default     = null
  description = <<-DESCRIPTION
  - `sgx_quote_helper_enabled` - (Required) Should the SGX quote helper be enabled?
  DESCRIPTION
}

variable "default_node_pool" {
  type = object({
    auto_scaling_enabled          = optional(bool)
    capacity_reservation_group_id = optional(string)
    fips_enabled                  = optional(bool)
    gpu_driver                    = optional(string)
    gpu_instance                  = optional(string)
    host_encryption_enabled       = optional(bool)
    host_group_id                 = optional(string)
    kubelet_disk_type             = optional(string)
    max_count                     = optional(number)
    max_pods                      = optional(number)
    min_count                     = optional(number)
    name                          = string
    node_count                    = optional(number)
    node_labels                   = optional(map(string))
    node_public_ip_enabled        = optional(bool)
    node_public_ip_prefix_id      = optional(string)
    only_critical_addons_enabled  = optional(bool)
    orchestrator_version          = optional(string)
    os_disk_size_gb               = optional(number)
    os_disk_type                  = optional(string)
    os_sku                        = optional(string)
    pod_subnet_id                 = optional(string)
    proximity_placement_group_id  = optional(string)
    scale_down_mode               = optional(string)
    snapshot_id                   = optional(string)
    tags                          = optional(map(string))
    temporary_name_for_rotation   = optional(string)
    type                          = optional(string)
    ultra_ssd_enabled             = optional(bool)
    vm_size                       = optional(string)
    vnet_subnet_id                = optional(string)
    workload_runtime              = optional(string)
    zones                         = optional(set(string))
    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(set(string))
      container_log_max_line    = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      cpu_manager_policy        = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pid               = optional(number)
      topology_manager_policy   = optional(string)
    }))
    linux_os_config = optional(object({
      swap_file_size_mb            = optional(number)
      transparent_huge_page        = optional(string)
      transparent_huge_page_defrag = optional(string)
      sysctl_config = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range_max   = optional(number)
        net_ipv4_ip_local_port_range_min   = optional(number)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout           = optional(number)
        net_ipv4_tcp_keepalive_intvl       = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(bool)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }))
    }))
    node_network_profile = optional(object({
      application_security_group_ids = optional(list(string))
      node_public_ip_tags            = optional(map(string))
      allowed_host_ports = optional(map(object({
        port_end   = optional(number)
        port_start = optional(number)
        protocol   = optional(string)
      })))
    }))
    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = optional(number)
      max_surge                     = string
      node_soak_duration_in_minutes = optional(number)
      undrainable_node_behavior     = optional(string)
    }))
  })
  description = <<-DESCRIPTION
  - `auto_scaling_enabled` - (Optional) Should the Kubernetes Auto Scaler be enabled for this Node Pool?
  - `capacity_reservation_group_id` - (Optional) Specifies the ID of the Capacity Reservation Group within which this AKS Cluster should be created. Changing this forces a new resource to be created.
  - `fips_enabled` - (Optional) Should the nodes in this Node Pool have Federal Information Processing Standard enabled? `temporary_name_for_rotation` must be specified when changing this block.
  - `gpu_driver` - (Optional) Specifies the driver type for GPU nodes. Possible values are `Install` and `None`. Changing this forces a new resource to be created.
  - `gpu_instance` - (Optional) Specifies the GPU MIG instance profile for supported GPU VM SKU. The allowed values are `MIG1g`, `MIG2g`, `MIG3g`, `MIG4g` and `MIG7g`. Changing this forces a new resource to be created.
  - `host_encryption_enabled` - (Optional) Should the nodes in the Default Node Pool have host encryption enabled? `temporary_name_for_rotation` must be specified when changing this property.
  - `host_group_id` - (Optional) Specifies the ID of the Host Group within which this AKS Cluster should be created. Changing this forces a new resource to be created.
  - `kubelet_disk_type` - (Optional) The type of disk used by kubelet. Possible values are `OS` and `Temporary`. `temporary_name_for_rotation` must be specified when changing this block.
  - `max_count` - (Optional) The maximum number of nodes which should exist in this Node Pool. If specified this must be between `1` and `1000`.
  - `max_pods` - (Optional) The maximum number of pods that can run on each agent. `temporary_name_for_rotation` must be specified when changing this property.
  - `min_count` - (Optional) The minimum number of nodes which should exist in this Node Pool. If specified this must be between `1` and `1000`.
  - `name` - (Required) The name which should be used for the default Kubernetes Node Pool.
  - `node_count` - (Optional) The initial number of nodes which should exist in this Node Pool. If specified this must be between `1` and `1000` and between `min_count` and `max_count`.
  - `node_labels` - (Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool.
  - `node_public_ip_enabled` - (Optional) Should nodes in this Node Pool have a Public IP Address? `temporary_name_for_rotation` must be specified when changing this property.
  - `node_public_ip_prefix_id` - (Optional) Resource ID for the Public IP Addresses Prefix for the nodes in this Node Pool. `node_public_ip_enabled` should be `true`. Changing this forces a new resource to be created.
  - `only_critical_addons_enabled` - (Optional) Enabling this option will taint default node pool with `CriticalAddonsOnly=true:NoSchedule` taint. `temporary_name_for_rotation` must be specified when changing this property.
  - `orchestrator_version` - (Optional) Version of Kubernetes used for the Agents. If not specified, the default node pool will be created with the version specified by `kubernetes_version`. If both are unspecified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). AKS does not require an exact patch version to be specified, minor version aliases such as `1.22` are also supported. - The minor version's latest GA patch is automatically chosen in that case. More details can be found in the documentation.
  - `os_disk_size_gb` - (Optional) The size of the OS Disk which should be used for each agent in the Node Pool. `temporary_name_for_rotation` must be specified when attempting a change.
  - `os_disk_type` - (Optional) The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. `temporary_name_for_rotation` must be specified when attempting a change.
  - `os_sku` - (Optional) Specifies the OS SKU used by the agent pool. Possible values are `AzureLinux`, `AzureLinux3`, `Ubuntu`, `Ubuntu2204`, `Windows2019` and `Windows2022`. If not specified, the default is `Ubuntu` when os_type=Linux or `Windows2019` if os_type=Windows (`Windows2022` Kubernetes ≥1.33). Changing between `AzureLinux` and `Ubuntu` does not replace the resource; otherwise `temporary_name_for_rotation` must be specified when attempting a change.
  - `pod_subnet_id` - (Optional) The ID of the Subnet where the pods in the default Node Pool should exist.
  - `proximity_placement_group_id` - (Optional) The ID of the Proximity Placement Group. Changing this forces a new resource to be created.
  - `scale_down_mode` - (Optional) Specifies the autoscaling behaviour of the Kubernetes Cluster. Allowed values are `Delete` and `Deallocate`. Defaults to `Delete`.
  - `snapshot_id` - (Optional) The ID of the Snapshot which should be used to create this default Node Pool. `temporary_name_for_rotation` must be specified when changing this property.
  - `tags` - (Optional) A mapping of tags to assign to the Node Pool.
  - `temporary_name_for_rotation` - (Optional) Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing.
  - `type` - (Optional) The type of Node Pool which should be created. Possible values are `VirtualMachineScaleSets`. Defaults to `VirtualMachineScaleSets`. Changing this forces a new resource to be created.
  - `ultra_ssd_enabled` - (Optional) Used to specify whether the UltraSSD is enabled in the Default Node Pool. Defaults to `false`. See the documentation for more information. `temporary_name_for_rotation` must be specified when attempting a change.
  - `vm_size` - (Optional) The size of the Virtual Machine, such as `Standard_DS2_v2`. `temporary_name_for_rotation` must be specified when attempting a resize.
  - `vnet_subnet_id` - (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist.
  - `workload_runtime` - (Optional) Specifies the workload runtime used by the node pool. Possible value is `OCIContainer`.
  - `zones` - (Optional) Specifies a list of Availability Zones in which this Kubernetes Cluster should be located. `temporary_name_for_rotation` must be specified when changing this property.

  ---
  `kubelet_config` block supports the following:
    - `allowed_unsafe_sysctls` - (Optional) The allowed unsafe sysctls value.
    - `container_log_max_line` - (Optional) The container log max line value.
    - `container_log_max_size_mb` - (Optional) The container log max size mb value.
    - `cpu_cfs_quota_enabled` - (Optional) The cpu cfs quota enabled value.
    - `cpu_cfs_quota_period` - (Optional) The cpu cfs quota period value.
    - `cpu_manager_policy` - (Optional) The cpu manager policy value.
    - `image_gc_high_threshold` - (Optional) The image gc high threshold value.
    - `image_gc_low_threshold` - (Optional) The image gc low threshold value.
    - `pod_max_pid` - (Optional) The pod max pid value.
    - `topology_manager_policy` - (Optional) The topology manager policy value.

  ---
  `linux_os_config` block supports the following:
    - `swap_file_size_mb` - (Optional) The swap file size mb value.
    - `transparent_huge_page` - (Optional) The transparent huge page value.
    - `transparent_huge_page_defrag` - (Optional) The transparent huge page defrag value.

    ---
    `sysctl_config` block supports the following:
      - `fs_aio_max_nr` - (Optional) The fs aio max nr value.
      - `fs_file_max` - (Optional) The fs file max value.
      - `fs_inotify_max_user_watches` - (Optional) The fs inotify max user watches value.
      - `fs_nr_open` - (Optional) The fs nr open value.
      - `kernel_threads_max` - (Optional) The kernel threads max value.
      - `net_core_netdev_max_backlog` - (Optional) The net core netdev max backlog value.
      - `net_core_optmem_max` - (Optional) The net core optmem max value.
      - `net_core_rmem_default` - (Optional) The net core rmem default value.
      - `net_core_rmem_max` - (Optional) The net core rmem max value.
      - `net_core_somaxconn` - (Optional) The net core somaxconn value.
      - `net_core_wmem_default` - (Optional) The net core wmem default value.
      - `net_core_wmem_max` - (Optional) The net core wmem max value.
      - `net_ipv4_ip_local_port_range_max` - (Optional) The net ipv4 ip local port range max value.
      - `net_ipv4_ip_local_port_range_min` - (Optional) The net ipv4 ip local port range min value.
      - `net_ipv4_neigh_default_gc_thresh1` - (Optional) The net ipv4 neigh default gc thresh1 value.
      - `net_ipv4_neigh_default_gc_thresh2` - (Optional) The net ipv4 neigh default gc thresh2 value.
      - `net_ipv4_neigh_default_gc_thresh3` - (Optional) The net ipv4 neigh default gc thresh3 value.
      - `net_ipv4_tcp_fin_timeout` - (Optional) The net ipv4 tcp fin timeout value.
      - `net_ipv4_tcp_keepalive_intvl` - (Optional) The net ipv4 tcp keepalive intvl value.
      - `net_ipv4_tcp_keepalive_probes` - (Optional) The net ipv4 tcp keepalive probes value.
      - `net_ipv4_tcp_keepalive_time` - (Optional) The net ipv4 tcp keepalive time value.
      - `net_ipv4_tcp_max_syn_backlog` - (Optional) The net ipv4 tcp max syn backlog value.
      - `net_ipv4_tcp_max_tw_buckets` - (Optional) The net ipv4 tcp max tw buckets value.
      - `net_ipv4_tcp_tw_reuse` - (Optional) The net ipv4 tcp tw reuse value.
      - `net_netfilter_nf_conntrack_buckets` - (Optional) The net netfilter nf conntrack buckets value.
      - `net_netfilter_nf_conntrack_max` - (Optional) The net netfilter nf conntrack max value.
      - `vm_max_map_count` - (Optional) The vm max map count value.
      - `vm_swappiness` - (Optional) The vm swappiness value.
      - `vm_vfs_cache_pressure` - (Optional) The vm vfs cache pressure value.

  ---
  `node_network_profile` block supports the following:
    - `application_security_group_ids` - (Optional) The application security group ids value.
    - `node_public_ip_tags` - (Optional) The node public ip tags value.

    ---
    `allowed_host_ports` block supports the following:
      - `port_end` - (Optional) The port end value.
      - `port_start` - (Optional) The port start value.
      - `protocol` - (Optional) The protocol value.

  ---
  `upgrade_settings` block supports the following:
    - `drain_timeout_in_minutes` - (Optional) The drain timeout in minutes value.
    - `max_surge` - (Required) The max surge value.
    - `node_soak_duration_in_minutes` - (Optional) The node soak duration in minutes value.
    - `undrainable_node_behavior` - (Optional) The undrainable node behavior value.
  DESCRIPTION
  validation {
    condition     = var.default_node_pool.gpu_driver == null || contains(["Install", "None"], var.default_node_pool.gpu_driver)
    error_message = "default_node_pool.gpu_driver must be one of: Install, None."
  }
  validation {
    condition     = var.default_node_pool.gpu_instance == null || contains(["MIG1g", "MIG2g", "MIG3g", "MIG4g", "MIG7g"], var.default_node_pool.gpu_instance)
    error_message = "default_node_pool.gpu_instance must be one of: MIG1g, MIG2g, MIG3g, MIG4g, MIG7g."
  }
  validation {
    condition     = var.default_node_pool.kubelet_disk_type == null || contains(["OS", "Temporary"], var.default_node_pool.kubelet_disk_type)
    error_message = "default_node_pool.kubelet_disk_type must be one of: OS, Temporary."
  }
  validation {
    condition     = var.default_node_pool.os_disk_type == null || contains(["Ephemeral", "Managed"], var.default_node_pool.os_disk_type)
    error_message = "default_node_pool.os_disk_type must be one of: Ephemeral, Managed."
  }
  validation {
    condition     = var.default_node_pool.os_sku == null || contains(["AzureLinux", "AzureLinux3", "Ubuntu", "Ubuntu2204", "Windows2019", "Windows2022"], var.default_node_pool.os_sku)
    error_message = "default_node_pool.os_sku must be one of: AzureLinux, AzureLinux3, Ubuntu, Ubuntu2204, Windows2019, Windows2022."
  }
  validation {
    condition     = var.default_node_pool.scale_down_mode == null || contains(["Delete", "Deallocate"], var.default_node_pool.scale_down_mode)
    error_message = "default_node_pool.scale_down_mode must be one of: Delete, Deallocate."
  }
}

variable "http_proxy_config" {
  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(set(string))
    trusted_ca  = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `http_proxy` - (Optional) The proxy address to be used when communicating over HTTP.
  - `https_proxy` - (Optional) The proxy address to be used when communicating over HTTPS.
  - `no_proxy` - (Optional) The list of domains that will not use the proxy for communication.
  - `trusted_ca` - (Optional) The base64 encoded alternative CA certificate content in PEM format.
  DESCRIPTION
}

variable "identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `identity_ids` - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster.
  - `type` - (Required) Specifies the type of Managed Service Identity that should be configured on this Kubernetes Cluster. Possible values are `SystemAssigned` or `UserAssigned`.
  DESCRIPTION
}

variable "ingress_application_gateway" {
  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `gateway_id` - (Optional) The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster. See this page for further details.
  - `gateway_name` - (Optional) The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  - `subnet_cidr` - (Optional) The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  - `subnet_id` - (Optional) The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  DESCRIPTION
}

variable "key_management_service" {
  type = object({
    key_vault_key_id         = string
    key_vault_network_access = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `key_vault_key_id` - (Required) Identifier of Azure Key Vault key. See key identifier format for more details.
  - `key_vault_network_access` - (Optional) Network access of the key vault Network access of key vault. The possible values are `Public` and `Private`. `Public` means the key vault allows public access from all networks. `Private` means the key vault disables public access and enables private link. Defaults to `Public`.
  DESCRIPTION
  validation {
    condition     = var.key_management_service == null || contains(["Public", "Private"], var.key_management_service.key_vault_network_access)
    error_message = "key_management_service.key_vault_network_access must be one of: Public, Private."
  }
}

variable "key_vault_secrets_provider" {
  type = object({
    secret_rotation_enabled  = optional(bool)
    secret_rotation_interval = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `secret_rotation_enabled` - (Optional) Should the secret store CSI driver on the AKS cluster be enabled?
  - `secret_rotation_interval` - (Optional) The interval to poll for secret rotation. This attribute is only set when `secret_rotation_enabled` is true. Defaults to `2m`.
  DESCRIPTION
}

variable "kubelet_identity" {
  type = object({
    client_id                 = optional(string)
    object_id                 = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `client_id` - (Optional) The client id value.
  - `object_id` - (Optional) The object id value.
  - `user_assigned_identity_id` - (Optional) The user assigned identity id value.
  DESCRIPTION
}

variable "linux_profile" {
  type = object({
    admin_username = string
    ssh_key = object({
      key_data = string
    })
  })
  default     = null
  description = <<-DESCRIPTION
  - `admin_username` - (Required) The Admin Username for the Cluster. Changing this forces a new resource to be created.

  ---
  `ssh_key` block supports the following:
    - `key_data` - (Required) The key data value.
  DESCRIPTION
}

variable "maintenance_window" {
  type = object({
    allowed = optional(map(object({
      day   = string
      hours = set(number)
    })))
    not_allowed = optional(map(object({
      end   = string
      start = string
    })))
  })
  default     = null
  description = <<-DESCRIPTION

  ---
  `allowed` block supports the following:
    - `day` - (Required) The day value.
    - `hours` - (Required) The hours value.

  ---
  `not_allowed` block supports the following:
    - `end` - (Required) The end value.
    - `start` - (Required) The start value.
  DESCRIPTION
}

variable "maintenance_window_auto_upgrade" {
  type = object({
    day_of_month = optional(number)
    day_of_week  = optional(string)
    duration     = number
    frequency    = string
    interval     = number
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(map(object({
      end   = string
      start = string
    })))
  })
  default     = null
  description = <<-DESCRIPTION
  - `day_of_month` - (Optional) The day of the month for the maintenance run. Required in combination with AbsoluteMonthly frequency. Value between 0 and 31 (inclusive).
  - `day_of_week` - (Optional) The day of the week for the maintenance run. Required in combination with weekly frequency. Possible values are `Friday`, `Monday`, `Saturday`, `Sunday`, `Thursday`, `Tuesday` and `Wednesday`.
  - `duration` - (Required) The duration of the window for maintenance to run in hours. Possible options are between `4` to `24`.
  - `frequency` - (Required) Frequency of maintenance. Possible options are `Daily`, `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`.
  - `interval` - (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.
  - `start_date` - (Optional) The date on which the maintenance window begins to take effect.
  - `start_time` - (Optional) The time for maintenance to begin, based on the timezone determined by `utc_offset`. Format is `HH:mm`.
  - `utc_offset` - (Optional) Used to determine the timezone for cluster maintenance.
  - `week_index` - (Optional) Specifies on which instance of the allowed days specified in `day_of_week` the maintenance occurs. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`.

  ---
  `not_allowed` block supports the following:
    - `end` - (Required) The end value.
    - `start` - (Required) The start value.
  DESCRIPTION
  validation {
    condition     = var.maintenance_window_auto_upgrade == null || contains(["Friday", "Monday", "Saturday", "Sunday", "Thursday", "Tuesday", "Wednesday"], var.maintenance_window_auto_upgrade.day_of_week)
    error_message = "maintenance_window_auto_upgrade.day_of_week must be one of: Friday, Monday, Saturday, Sunday, Thursday, Tuesday, Wednesday."
  }
}

variable "maintenance_window_node_os" {
  type = object({
    day_of_month = optional(number)
    day_of_week  = optional(string)
    duration     = number
    frequency    = string
    interval     = number
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(map(object({
      end   = string
      start = string
    })))
  })
  default     = null
  description = <<-DESCRIPTION
  - `day_of_month` - (Optional) The day of the month for the maintenance run. Required in combination with AbsoluteMonthly frequency. Value between 0 and 31 (inclusive).
  - `day_of_week` - (Optional) The day of the week for the maintenance run. Required in combination with weekly frequency. Possible values are `Friday`, `Monday`, `Saturday`, `Sunday`, `Thursday`, `Tuesday` and `Wednesday`.
  - `duration` - (Required) The duration of the window for maintenance to run in hours. Possible options are between `4` to `24`.
  - `frequency` - (Required) Frequency of maintenance. Possible options are `Daily`, `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`.
  - `interval` - (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.
  - `start_date` - (Optional) The date on which the maintenance window begins to take effect.
  - `start_time` - (Optional) The time for maintenance to begin, based on the timezone determined by `utc_offset`. Format is `HH:mm`.
  - `utc_offset` - (Optional) Used to determine the timezone for cluster maintenance.
  - `week_index` - (Optional) The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`.

  ---
  `not_allowed` block supports the following:
    - `end` - (Required) The end value.
    - `start` - (Required) The start value.
  DESCRIPTION
  validation {
    condition     = var.maintenance_window_node_os == null || contains(["Friday", "Monday", "Saturday", "Sunday", "Thursday", "Tuesday", "Wednesday"], var.maintenance_window_node_os.day_of_week)
    error_message = "maintenance_window_node_os.day_of_week must be one of: Friday, Monday, Saturday, Sunday, Thursday, Tuesday, Wednesday."
  }
}

variable "microsoft_defender" {
  type = object({
    log_analytics_workspace_id = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `log_analytics_workspace_id` - (Required) Specifies the ID of the Log Analytics Workspace where the audit logs collected by Microsoft Defender should be sent to.
  DESCRIPTION
}

variable "monitor_metrics" {
  type = object({
    annotations_allowed = optional(string)
    labels_allowed      = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `annotations_allowed` - (Optional) Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric.
  - `labels_allowed` - (Optional) Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric.
  DESCRIPTION
}

variable "network_profile" {
  type = object({
    dns_service_ip      = optional(string)
    ip_versions         = optional(list(string))
    load_balancer_sku   = optional(string)
    network_data_plane  = optional(string)
    network_mode        = optional(string)
    network_plugin      = string
    network_plugin_mode = optional(string)
    network_policy      = optional(string)
    outbound_type       = optional(string)
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    service_cidr        = optional(string)
    service_cidrs       = optional(list(string))
    advanced_networking = optional(object({
      observability_enabled = optional(bool)
      security_enabled      = optional(bool)
    }))
    load_balancer_profile = optional(object({
      backend_pool_type           = optional(string)
      idle_timeout_in_minutes     = optional(number)
      managed_outbound_ip_count   = optional(number)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_address_ids     = optional(set(string))
      outbound_ip_prefix_ids      = optional(set(string))
      outbound_ports_allocated    = optional(number)
    }))
    nat_gateway_profile = optional(object({
      idle_timeout_in_minutes   = optional(number)
      managed_outbound_ip_count = optional(number)
    }))
  })
  default     = null
  description = <<-DESCRIPTION
  - `dns_service_ip` - (Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created.
  - `ip_versions` - (Optional) Specifies a list of IP versions the Kubernetes Cluster will use to assign IP addresses to its nodes and pods. Possible values are `IPv4` and/or `IPv6`. `IPv4` must always be specified. Changing this forces a new resource to be created.
  - `load_balancer_sku` - (Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`. Defaults to `standard`. Changing this forces a new resource to be created.
  - `network_data_plane` - (Optional) Specifies the data plane used for building the Kubernetes network. Possible values are `azure` and `cilium`. Defaults to `azure`. Disabling this forces a new resource to be created.
  - `network_mode` - (Optional) Network mode to be used with Azure CNI. Possible values are `bridge` and `transparent`. Changing this forces a new resource to be created.
  - `network_plugin` - (Required) Network plugin to use for networking. Currently supported values are `azure`, `kubenet` and `none`. Changing this forces a new resource to be created.
  - `network_plugin_mode` - (Optional) Specifies the network plugin mode used for building the Kubernetes network. Possible value is `overlay`.
  - `network_policy` - (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are `calico`, `azure` and `cilium`.
  - `outbound_type` - (Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer`, `userDefinedRouting`, `managedNATGateway`, `userAssignedNATGateway` and `none`. Defaults to `loadBalancer`.
  - `pod_cidr` - (Optional) The CIDR to use for pod IP addresses. This field can only be set when `network_plugin` is set to `kubenet` or `network_plugin_mode` is set to `overlay`. Changing this forces a new resource to be created.
  - `pod_cidrs` - (Optional) A list of CIDRs to use for pod IP addresses. For single-stack networking a single IPv4 CIDR is expected. For dual-stack networking an IPv4 and IPv6 CIDR are expected. Changing this forces a new resource to be created.
  - `service_cidr` - (Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created.
  - `service_cidrs` - (Optional) A list of CIDRs to use for Kubernetes services. For single-stack networking a single IPv4 CIDR is expected. For dual-stack networking an IPv4 and IPv6 CIDR are expected. Changing this forces a new resource to be created.

  ---
  `advanced_networking` block supports the following:
    - `observability_enabled` - (Optional) The observability enabled value.
    - `security_enabled` - (Optional) The security enabled value.

  ---
  `load_balancer_profile` block supports the following:
    - `backend_pool_type` - (Optional) The backend pool type value.
    - `idle_timeout_in_minutes` - (Optional) The idle timeout in minutes value.
    - `managed_outbound_ip_count` - (Optional) The managed outbound ip count value.
    - `managed_outbound_ipv6_count` - (Optional) The managed outbound ipv6 count value.
    - `outbound_ip_address_ids` - (Optional) The outbound ip address ids value.
    - `outbound_ip_prefix_ids` - (Optional) The outbound ip prefix ids value.
    - `outbound_ports_allocated` - (Optional) The outbound ports allocated value.

  ---
  `nat_gateway_profile` block supports the following:
    - `idle_timeout_in_minutes` - (Optional) The idle timeout in minutes value.
    - `managed_outbound_ip_count` - (Optional) The managed outbound ip count value.
  DESCRIPTION
  validation {
    condition     = var.network_profile == null || contains(["basic", "standard"], var.network_profile.load_balancer_sku)
    error_message = "network_profile.load_balancer_sku must be one of: basic, standard."
  }
  validation {
    condition     = var.network_profile == null || contains(["azure", "cilium"], var.network_profile.network_data_plane)
    error_message = "network_profile.network_data_plane must be one of: azure, cilium."
  }
  validation {
    condition     = var.network_profile == null || contains(["bridge", "transparent"], var.network_profile.network_mode)
    error_message = "network_profile.network_mode must be one of: bridge, transparent."
  }
  validation {
    condition     = var.network_profile == null || contains(["loadBalancer", "userDefinedRouting", "managedNATGateway", "userAssignedNATGateway", "none"], var.network_profile.outbound_type)
    error_message = "network_profile.outbound_type must be one of: loadBalancer, userDefinedRouting, managedNATGateway, userAssignedNATGateway, none."
  }
}

variable "node_provisioning_profile" {
  type = object({
    default_node_pools = optional(string)
    mode               = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `default_node_pools` - (Optional) The default node pools value.
  - `mode` - (Optional) The mode value.
  DESCRIPTION
}

variable "oms_agent" {
  type = object({
    log_analytics_workspace_id      = string
    msi_auth_for_monitoring_enabled = optional(bool)
  })
  default     = null
  description = <<-DESCRIPTION
  - `log_analytics_workspace_id` - (Required) The ID of the Log Analytics Workspace which the OMS Agent should send data to.
  - `msi_auth_for_monitoring_enabled` - (Optional) Is managed identity authentication for monitoring enabled?
  DESCRIPTION
}

variable "service_mesh_profile" {
  type = object({
    external_ingress_gateway_enabled = optional(bool)
    internal_ingress_gateway_enabled = optional(bool)
    mode                             = string
    revisions                        = list(string)
    certificate_authority = optional(object({
      cert_chain_object_name = string
      cert_object_name       = string
      key_object_name        = string
      key_vault_id           = string
      root_cert_object_name  = string
    }))
  })
  default     = null
  description = <<-DESCRIPTION
  - `external_ingress_gateway_enabled` - (Optional) Is Istio External Ingress Gateway enabled?
  - `internal_ingress_gateway_enabled` - (Optional) Is Istio Internal Ingress Gateway enabled?
  - `mode` - (Required) The mode of the service mesh. Possible value is `Istio`.
  - `revisions` - (Required) Specify 1 or 2 Istio control plane revisions for managing minor upgrades using the canary upgrade process. For example, create the resource with `revisions` set to `["asm-1-25"]`, or leave it empty (the `revisions` will only be known after apply). To start the canary upgrade, change `revisions` to `["asm-1-25", "asm-1-26"]`. To roll back the canary upgrade, revert to `["asm-1-25"]`. To confirm the upgrade, change to `["asm-1-26"]`.

  ---
  `certificate_authority` block supports the following:
    - `cert_chain_object_name` - (Required) The cert chain object name value.
    - `cert_object_name` - (Required) The cert object name value.
    - `key_object_name` - (Required) The key object name value.
    - `key_vault_id` - (Required) The key vault id value.
    - `root_cert_object_name` - (Required) The root cert object name value.
  DESCRIPTION
}

variable "service_principal" {
  type = object({
    client_id     = string
    client_secret = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `client_id` - (Required) The Client ID for the Service Principal.
  - `client_secret` - (Required) The Client Secret for the Service Principal.
  DESCRIPTION
}

variable "storage_profile" {
  type = object({
    blob_driver_enabled         = optional(bool)
    disk_driver_enabled         = optional(bool)
    file_driver_enabled         = optional(bool)
    snapshot_controller_enabled = optional(bool)
  })
  default     = null
  description = <<-DESCRIPTION
  - `blob_driver_enabled` - (Optional) Is the Blob CSI driver enabled? Defaults to `false`.
  - `disk_driver_enabled` - (Optional) Is the Disk CSI driver enabled? Defaults to `true`.
  - `file_driver_enabled` - (Optional) Is the File CSI driver enabled? Defaults to `true`.
  - `snapshot_controller_enabled` - (Optional) Is the Snapshot Controller enabled? Defaults to `true`.
  DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `create` - (Optional) The create value.
  - `delete` - (Optional) The delete value.
  - `read` - (Optional) The read value.
  - `update` - (Optional) The update value.
  DESCRIPTION
}

variable "upgrade_override" {
  type = object({
    effective_until       = optional(string)
    force_upgrade_enabled = bool
  })
  default     = null
  description = <<-DESCRIPTION
  - `effective_until` - (Optional) The effective until value.
  - `force_upgrade_enabled` - (Required) The force upgrade enabled value.
  DESCRIPTION
}

variable "web_app_routing" {
  type = object({
    default_nginx_controller = optional(string)
    dns_zone_ids             = list(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `default_nginx_controller` - (Optional) Specifies the ingress type for the default `NginxIngressController` custom resource. The allowed values are `None`, `Internal`, `External` and `AnnotationControlled`. Defaults to `AnnotationControlled`.
  - `dns_zone_ids` - (Required) Specifies the list of the DNS Zone IDs in which DNS entries are created for applications deployed to the cluster when Web App Routing is enabled. If not using Bring-Your-Own DNS zones this property should be set to an empty list.
  DESCRIPTION
  validation {
    condition     = var.web_app_routing == null || contains(["None", "Internal", "External", "AnnotationControlled"], var.web_app_routing.default_nginx_controller)
    error_message = "web_app_routing.default_nginx_controller must be one of: None, Internal, External, AnnotationControlled."
  }
}

variable "windows_profile" {
  type = object({
    admin_password = string
    admin_username = string
    license        = optional(string)
    gmsa = optional(object({
      dns_server  = string
      root_domain = string
    }))
  })
  default     = null
  description = <<-DESCRIPTION
  - `admin_password` - (Required) The Admin Password for Windows VMs. Length must be between 14 and 123 characters.
  - `admin_username` - (Required) The Admin Username for Windows VMs. Changing this forces a new resource to be created.
  - `license` - (Optional) Specifies the type of on-premise license which should be used for Node Pool Windows Virtual Machine. At this time the only possible value is `Windows_Server`.

  ---
  `gmsa` block supports the following:
    - `dns_server` - (Required) The dns server value.
    - `root_domain` - (Required) The root domain value.
  DESCRIPTION
}

variable "workload_autoscaler_profile" {
  type = object({
    keda_enabled                    = optional(bool)
    vertical_pod_autoscaler_enabled = optional(bool)
  })
  default     = null
  description = <<-DESCRIPTION
  - `keda_enabled` - (Optional) Specifies whether KEDA Autoscaler can be used for workloads.
  - `vertical_pod_autoscaler_enabled` - (Optional) Specifies whether Vertical Pod Autoscaler should be enabled.
  DESCRIPTION
}


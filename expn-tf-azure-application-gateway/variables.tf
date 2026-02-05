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

variable "create_application_gateway" {
  type        = bool
  description = "Whether to create the Application Gateway."
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

variable "application_gateway_name" {
  description = "Specifies the name of the Application Gateway"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Application Gateway"
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists"
  type        = string
}

variable "enable_http2" {
  description = "The enable http2 attribute"
  type        = bool
  default     = null
}

variable "fips_enabled" {
  description = "The fips enabled attribute"
  type        = bool
  default     = null
}

variable "firewall_policy_id" {
  description = "The firewall policy id attribute"
  type        = string
  default     = null
}

variable "force_firewall_policy_association" {
  description = "The force firewall policy association attribute"
  type        = bool
  default     = null
}

variable "zones" {
  description = "The zones attribute"
  type        = set(string)
  default     = null
}

variable "authentication_certificate" {
  description = "authentication certificate block configuration"
  type = map(object({
    data = string
    name = string
  }))
  default = {}
}

variable "autoscale_configuration" {
  description = "autoscale configuration block configuration"
  type = object({
    max_capacity = optional(number)
    min_capacity = number
  })
  default = null
}

variable "backend_address_pool" {
  description = "backend address pool block configuration"
  type = map(object({
    fqdns        = optional(set(string))
    ip_addresses = optional(set(string))
    name         = string
  }))
}

variable "backend_http_settings" {
  description = "backend http settings block configuration"
  type = map(object({
    affinity_cookie_name                 = optional(string)
    cookie_based_affinity                = string
    dedicated_backend_connection_enabled = optional(bool)
    host_name                            = optional(string)
    name                                 = string
    path                                 = optional(string)
    pick_host_name_from_backend_address  = optional(bool)
    port                                 = number
    probe_name                           = optional(string)
    protocol                             = string
    request_timeout                      = optional(number)
    trusted_root_certificate_names       = optional(list(string))
    authentication_certificate = optional(map(object({
      name = string
    })))
    connection_draining = optional(object({
      drain_timeout_sec = number
      enabled           = bool
    }))
  }))
}

variable "custom_error_configuration" {
  description = "custom error configuration block configuration"
  type = map(object({
    custom_error_page_url = string
    status_code           = string
  }))
  default = {}
}

variable "frontend_ip_configuration" {
  description = "frontend ip configuration block configuration"
  type = map(object({
    name                            = string
    private_ip_address              = optional(string)
    private_ip_address_allocation   = optional(string)
    private_link_configuration_name = optional(string)
    public_ip_address_id            = optional(string)
    subnet_id                       = optional(string)
  }))
}

variable "frontend_port" {
  description = "frontend port block configuration"
  type = map(object({
    name = string
    port = number
  }))
}

variable "gateway_ip_configuration" {
  description = "gateway ip configuration block configuration"
  type = map(object({
    name      = string
    subnet_id = string
  }))
}

variable "global" {
  description = "global block configuration"
  type = object({
    request_buffering_enabled  = bool
    response_buffering_enabled = bool
  })
  default = null
}

variable "http_listener" {
  description = "http listener block configuration"
  type = map(object({
    firewall_policy_id             = optional(string)
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    host_name                      = optional(string)
    host_names                     = optional(set(string))
    name                           = string
    protocol                       = string
    require_sni                    = optional(bool)
    ssl_certificate_name           = optional(string)
    ssl_profile_name               = optional(string)
    custom_error_configuration = optional(map(object({
      custom_error_page_url = string
      status_code           = string
    })))
  }))
}

variable "identity" {
  description = "identity block configuration"
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default = null
}

variable "private_link_configuration" {
  description = "private link configuration block configuration"
  type = map(object({
    name = string
    ip_configuration = map(object({
      name                          = string
      primary                       = bool
      private_ip_address            = optional(string)
      private_ip_address_allocation = string
      subnet_id                     = string
    }))
  }))
  default = {}
}

variable "probe" {
  description = "probe block configuration"
  type = map(object({
    host                                      = optional(string)
    interval                                  = number
    minimum_servers                           = optional(number)
    name                                      = string
    path                                      = string
    pick_host_name_from_backend_http_settings = optional(bool)
    port                                      = optional(number)
    protocol                                  = string
    timeout                                   = number
    unhealthy_threshold                       = number
    match = optional(object({
      body        = optional(string)
      status_code = list(string)
    }))
  }))
  default = {}
}

variable "redirect_configuration" {
  description = "redirect configuration block configuration"
  type = map(object({
    include_path         = optional(bool)
    include_query_string = optional(bool)
    name                 = string
    redirect_type        = string
    target_listener_name = optional(string)
    target_url           = optional(string)
  }))
  default = {}
}

variable "request_routing_rule" {
  description = "request routing rule block configuration"
  type = map(object({
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    http_listener_name          = string
    name                        = string
    priority                    = optional(number)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    rule_type                   = string
    url_path_map_name           = optional(string)
  }))
}

variable "rewrite_rule_set" {
  description = "rewrite rule set block configuration"
  type = map(object({
    name = string
    rewrite_rule = optional(map(object({
      name          = string
      rule_sequence = number
      condition = optional(map(object({
        ignore_case = optional(bool)
        negate      = optional(bool)
        pattern     = string
        variable    = string
      })))
      request_header_configuration = optional(map(object({
        header_name  = string
        header_value = string
      })))
      response_header_configuration = optional(map(object({
        header_name  = string
        header_value = string
      })))
      url = optional(object({
        components   = optional(string)
        path         = optional(string)
        query_string = optional(string)
        reroute      = optional(bool)
      }))
    })))
  }))
  default = {}
}

variable "sku" {
  description = "sku block configuration"
  type = object({
    capacity = optional(number)
    name     = string
    tier     = string
  })
}

variable "ssl_certificate" {
  description = "ssl certificate block configuration"
  type = map(object({
    data                = optional(string)
    key_vault_secret_id = optional(string)
    name                = string
    password            = optional(string)
  }))
  default = {}
}

variable "ssl_policy" {
  description = "ssl policy block configuration"
  type = object({
    cipher_suites        = optional(list(string))
    disabled_protocols   = optional(list(string))
    min_protocol_version = optional(string)
    policy_name          = optional(string)
    policy_type          = optional(string)
  })
  default = null
}

variable "ssl_profile" {
  description = "ssl profile block configuration"
  type = map(object({
    name                                 = string
    trusted_client_certificate_names     = optional(list(string))
    verify_client_cert_issuer_dn         = optional(bool)
    verify_client_certificate_revocation = optional(string)
    ssl_policy = optional(object({
      cipher_suites        = optional(list(string))
      disabled_protocols   = optional(list(string))
      min_protocol_version = optional(string)
      policy_name          = optional(string)
      policy_type          = optional(string)
    }))
  }))
  default = {}
}

variable "timeouts" {
  description = "timeouts block configuration"
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default = null
}

variable "trusted_client_certificate" {
  description = "trusted client certificate block configuration"
  type = map(object({
    data = string
    name = string
  }))
  default = {}
}

variable "trusted_root_certificate" {
  description = "trusted root certificate block configuration"
  type = map(object({
    data                = optional(string)
    key_vault_secret_id = optional(string)
    name                = string
  }))
  default = {}
}

variable "url_path_map" {
  description = "url path map block configuration"
  type = map(object({
    default_backend_address_pool_name   = optional(string)
    default_backend_http_settings_name  = optional(string)
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    name                                = string
    path_rule = map(object({
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      firewall_policy_id          = optional(string)
      name                        = string
      paths                       = list(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
    }))
  }))
  default = {}
}

variable "waf_configuration" {
  description = "waf configuration block configuration"
  type = object({
    enabled                  = bool
    file_upload_limit_mb     = optional(number)
    firewall_mode            = string
    max_request_body_size_kb = optional(number)
    request_body_check       = optional(bool)
    rule_set_type            = optional(string)
    rule_set_version         = string
    disabled_rule_group = optional(map(object({
      rule_group_name = string
      rules           = optional(list(number))
    })))
    exclusion = optional(map(object({
      match_variable          = string
      selector                = optional(string)
      selector_match_operator = optional(string)
    })))
  })
  default = null
}


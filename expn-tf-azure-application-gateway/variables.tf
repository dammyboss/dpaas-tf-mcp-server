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
  description = "(Optional) Is HTTP2 enabled on the application gateway resource? Defaults to `false`."
  type        = bool
  default     = null
}

variable "fips_enabled" {
  description = "(Optional) Is FIPS enabled on the Application Gateway?"
  type        = bool
  default     = null
}

variable "firewall_policy_id" {
  description = "(Optional) The ID of the Web Application Firewall Policy."
  type        = string
  default     = null
}

variable "force_firewall_policy_association" {
  description = "(Optional) Is the Firewall Policy associated with the Application Gateway?"
  type        = bool
  default     = null
}

variable "zones" {
  description = "(Optional) Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created."
  type        = set(string)
  default     = null
}

variable "authentication_certificate" {
  type        = map(object({
    data = string
    name = string
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `data` - (Required) The contents of the Authentication Certificate which should be used.
  - `name` - (Required) The Name of the Authentication Certificate to use.
  DESCRIPTION
}

variable "autoscale_configuration" {
  type        = object({
    max_capacity = optional(number)
    min_capacity = number
  })
  default     = null
  description = <<-DESCRIPTION
  - `max_capacity` - (Optional) Maximum capacity for autoscaling. Accepted values are in the range `2` to `125`.
  - `min_capacity` - (Required) Minimum capacity for autoscaling. Accepted values are in the range `0` to `100`.
  DESCRIPTION
}

variable "backend_address_pool" {
  type        = map(object({
    fqdns = optional(set(string))
    ip_addresses = optional(set(string))
    name = string
  }))
  description = <<-DESCRIPTION
  - `fqdns` - (Optional) A list of FQDN's which should be part of the Backend Address Pool.
  - `ip_addresses` - (Optional) A list of IP Addresses which should be part of the Backend Address Pool.
  - `name` - (Required) The name of the Backend Address Pool.
  DESCRIPTION
}

variable "backend_http_settings" {
  type        = map(object({
    affinity_cookie_name = optional(string)
    cookie_based_affinity = string
    dedicated_backend_connection_enabled = optional(bool)
    host_name = optional(string)
    name = string
    path = optional(string)
    pick_host_name_from_backend_address = optional(bool)
    port = number
    probe_name = optional(string)
    protocol = string
    request_timeout = optional(number)
    trusted_root_certificate_names = optional(list(string))
    authentication_certificate = optional(map(object({
      name = string
    })))
    connection_draining = optional(object({
      drain_timeout_sec = number
      enabled = bool
    }))
  }))
  description = <<-DESCRIPTION
  - `affinity_cookie_name` - (Optional) The name of the affinity cookie.
  - `cookie_based_affinity` - (Required) Is Cookie-Based Affinity enabled? Possible values are `Enabled` and `Disabled`.
  - `dedicated_backend_connection_enabled` - (Optional) Whether to use a dedicated backend connection. Defaults to `false`.
  - `host_name` - (Optional) Host header to be sent to the backend servers. Cannot be set if `pick_host_name_from_backend_address` is set to `true`.
  - `name` - (Required) The name of the Authentication Certificate.
  - `path` - (Optional) The Path which should be used as a prefix for all HTTP requests.
  - `pick_host_name_from_backend_address` - (Optional) Whether host header should be picked from the host name of the backend server. Defaults to `false`.
  - `port` - (Required) The port which should be used for this Backend HTTP Settings Collection.
  - `probe_name` - (Optional) The name of an associated HTTP Probe.
  - `protocol` - (Required) The Protocol which should be used. Possible values are `Http` and `Https`.
  - `request_timeout` - (Optional) The request timeout in seconds, which must be between 1 and 86400 seconds. Defaults to `30`.
  - `trusted_root_certificate_names` - (Optional) A list of `trusted_root_certificate` names.

  ---
  `authentication_certificate` block supports the following:
    - `name` - (Required) The name of the Application Gateway. Changing this forces a new resource to be created.

  ---
  `connection_draining` block supports the following:
    - `drain_timeout_sec` - (Required) The drain timeout sec value.
    - `enabled` - (Required) The enabled value.
  DESCRIPTION
  validation {
    condition     = alltrue([for k, v in var.backend_http_settings : contains(["Enabled", "Disabled"], v.cookie_based_affinity)])
    error_message = "backend_http_settings.cookie_based_affinity must be one of: Enabled, Disabled."
  }
  validation {
    condition     = alltrue([for k, v in var.backend_http_settings : contains(["Http", "Https"], v.protocol)])
    error_message = "backend_http_settings.protocol must be one of: Http, Https."
  }
}

variable "custom_error_configuration" {
  type        = map(object({
    custom_error_page_url = string
    status_code = string
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `custom_error_page_url` - (Required) Error page URL of the application gateway customer error.
  - `status_code` - (Required) Status code of the application gateway customer error. Possible values are `HttpStatus400`, `HttpStatus403`, `HttpStatus404`, `HttpStatus405`, `HttpStatus408`, `HttpStatus500`, `HttpStatus502`, `HttpStatus503` and `HttpStatus504`
  DESCRIPTION
  validation {
    condition     = alltrue([for k, v in var.custom_error_configuration : contains(["HttpStatus400", "HttpStatus403", "HttpStatus404", "HttpStatus405", "HttpStatus408", "HttpStatus500", "HttpStatus502", "HttpStatus503", "HttpStatus504"], v.status_code)])
    error_message = "custom_error_configuration.status_code must be one of: HttpStatus400, HttpStatus403, HttpStatus404, HttpStatus405, HttpStatus408, HttpStatus500, HttpStatus502, HttpStatus503, HttpStatus504."
  }
}

variable "frontend_ip_configuration" {
  type        = map(object({
    name = string
    private_ip_address = optional(string)
    private_ip_address_allocation = optional(string)
    private_link_configuration_name = optional(string)
    public_ip_address_id = optional(string)
    subnet_id = optional(string)
  }))
  description = <<-DESCRIPTION
  - `name` - (Required) The name of the Frontend IP Configuration.
  - `private_ip_address` - (Optional) The Private IP Address to use for the Application Gateway.
  - `private_ip_address_allocation` - (Optional) The Allocation Method for the Private IP Address. Possible values are `Dynamic` and `Static`. Defaults to `Dynamic`.
  - `private_link_configuration_name` - (Optional) The name of the private link configuration to use for this frontend IP configuration.
  - `public_ip_address_id` - (Optional) The ID of a Public IP Address which the Application Gateway should use. The allocation method for the Public IP Address depends on the `sku` of this Application Gateway. Please refer to the Azure documentation for public IP addresses for details.
  - `subnet_id` - (Optional) The ID of the Subnet.
  DESCRIPTION
  validation {
    condition     = alltrue([for k, v in var.frontend_ip_configuration : v.private_ip_address_allocation == null || contains(["Dynamic", "Static"], v.private_ip_address_allocation)])
    error_message = "frontend_ip_configuration.private_ip_address_allocation must be one of: Dynamic, Static."
  }
}

variable "frontend_port" {
  type        = map(object({
    name = string
    port = number
  }))
  description = <<-DESCRIPTION
  - `name` - (Required) The name of the Frontend Port.
  - `port` - (Required) The port used for this Frontend Port.
  DESCRIPTION
}

variable "gateway_ip_configuration" {
  type        = map(object({
    name = string
    subnet_id = string
  }))
  description = <<-DESCRIPTION
  - `name` - (Required) The Name of this Gateway IP Configuration.
  - `subnet_id` - (Required) The ID of the Subnet which the Application Gateway should be connected to.
  DESCRIPTION
}

variable "global" {
  type        = object({
    request_buffering_enabled = bool
    response_buffering_enabled = bool
  })
  default     = null
  description = <<-DESCRIPTION
  - `request_buffering_enabled` - (Required) Whether Application Gateway's Request buffer is enabled.
  - `response_buffering_enabled` - (Required) Whether Application Gateway's Response buffer is enabled.
  DESCRIPTION
}

variable "http_listener" {
  type        = map(object({
    firewall_policy_id = optional(string)
    frontend_ip_configuration_name = string
    frontend_port_name = string
    host_name = optional(string)
    host_names = optional(set(string))
    name = string
    protocol = string
    require_sni = optional(bool)
    ssl_certificate_name = optional(string)
    ssl_profile_name = optional(string)
    custom_error_configuration = optional(map(object({
      custom_error_page_url = string
      status_code = string
    })))
  }))
  description = <<-DESCRIPTION
  - `firewall_policy_id` - (Optional) The ID of the Web Application Firewall Policy which should be used for this HTTP Listener.
  - `frontend_ip_configuration_name` - (Required) The Name of the Frontend IP Configuration used for this HTTP Listener.
  - `frontend_port_name` - (Required) The Name of the Frontend Port use for this HTTP Listener.
  - `host_name` - (Optional) The Hostname which should be used for this HTTP Listener. Setting this value changes Listener Type to 'Multi site'.
  - `host_names` - (Optional) A list of Hostname(s) should be used for this HTTP Listener. It allows special wildcard characters.
  - `name` - (Required) The Name of the HTTP Listener.
  - `protocol` - (Required) The Protocol to use for this HTTP Listener. Possible values are `Http` and `Https`.
  - `require_sni` - (Optional) Should Server Name Indication be Required? Defaults to `false`.
  - `ssl_certificate_name` - (Optional) The name of the associated SSL Certificate which should be used for this HTTP Listener.
  - `ssl_profile_name` - (Optional) The name of the associated SSL Profile which should be used for this HTTP Listener.

  ---
  `custom_error_configuration` block supports the following:
    - `custom_error_page_url` - (Required) The custom error page url value.
    - `status_code` - (Required) The status code value.
  DESCRIPTION
  validation {
    condition     = alltrue([for k, v in var.http_listener : contains(["Http", "Https"], v.protocol)])
    error_message = "http_listener.protocol must be one of: Http, Https."
  }
}

variable "identity" {
  type        = object({
    identity_ids = optional(set(string))
    type = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `identity_ids` - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Application Gateway.
  - `type` - (Required) Specifies the type of Managed Service Identity that should be configured on this Application Gateway. Only possible value is `UserAssigned`.
  DESCRIPTION
}

variable "private_link_configuration" {
  type        = map(object({
    name = string
    ip_configuration = map(object({
      name = string
      primary = bool
      private_ip_address = optional(string)
      private_ip_address_allocation = string
      subnet_id = string
    }))
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `name` - (Required) The name of the private link configuration.

  ---
  `ip_configuration` block supports the following:
    - `name` - (Required) The name of the Application Gateway. Changing this forces a new resource to be created.
    - `primary` - (Required) The primary value.
    - `private_ip_address` - (Optional) The private ip address value.
    - `private_ip_address_allocation` - (Required) The private ip address allocation value.
    - `subnet_id` - (Required) The subnet id value.
  DESCRIPTION
}

variable "probe" {
  type        = map(object({
    host = optional(string)
    interval = number
    minimum_servers = optional(number)
    name = string
    path = string
    pick_host_name_from_backend_http_settings = optional(bool)
    port = optional(number)
    protocol = string
    timeout = number
    unhealthy_threshold = number
    match = optional(object({
      body = optional(string)
      status_code = list(string)
    }))
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `host` - (Optional) The Hostname used for this Probe. If the Application Gateway is configured for a single site, by default the Host name should be specified as `127.0.0.1`, unless otherwise configured in custom probe. Cannot be set if `pick_host_name_from_backend_http_settings` is set to `true`.
  - `interval` - (Required) The Interval between two consecutive probes in seconds. Possible values range from 1 second to a maximum of 86,400 seconds.
  - `minimum_servers` - (Optional) The minimum number of servers that are always marked as healthy. Defaults to `0`.
  - `name` - (Required) The Name of the Probe.
  - `path` - (Required) The Path used for this Probe.
  - `pick_host_name_from_backend_http_settings` - (Optional) Whether the host header should be picked from the backend HTTP settings. Defaults to `false`.
  - `port` - (Optional) Custom port which will be used for probing the backend servers. The valid value ranges from 1 to 65535. In case not set, port from HTTP settings will be used. This property is valid for Basic, Standard_v2 and WAF_v2 only.
  - `protocol` - (Required) The Protocol used for this Probe. Possible values are `Http` and `Https`.
  - `timeout` - (Required) The Timeout used for this Probe, which indicates when a probe becomes unhealthy. Possible values range from 1 second to a maximum of 86,400 seconds.
  - `unhealthy_threshold` - (Required) The Unhealthy Threshold for this Probe, which indicates the amount of retries which should be attempted before a node is deemed unhealthy. Possible values are from 1 to 20.

  ---
  `match` block supports the following:
    - `body` - (Optional) The body value.
    - `status_code` - (Required) The status code value.
  DESCRIPTION
  validation {
    condition     = alltrue([for k, v in var.probe : contains(["Http", "Https"], v.protocol)])
    error_message = "probe.protocol must be one of: Http, Https."
  }
}

variable "redirect_configuration" {
  type        = map(object({
    include_path = optional(bool)
    include_query_string = optional(bool)
    name = string
    redirect_type = string
    target_listener_name = optional(string)
    target_url = optional(string)
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `include_path` - (Optional) Whether to include the path in the redirected URL. Defaults to `false`
  - `include_query_string` - (Optional) Whether to include the query string in the redirected URL. Default to `false`
  - `name` - (Required) Unique name of the redirect configuration block
  - `redirect_type` - (Required) The type of redirect. Possible values are `Permanent`, `Temporary`, `Found` and `SeeOther`
  - `target_listener_name` - (Optional) The name of the listener to redirect to. Cannot be set if `target_url` is set.
  - `target_url` - (Optional) The URL to redirect the request to. Cannot be set if `target_listener_name` is set.
  DESCRIPTION
  validation {
    condition     = alltrue([for k, v in var.redirect_configuration : contains(["Permanent", "Temporary", "Found", "SeeOther"], v.redirect_type)])
    error_message = "redirect_configuration.redirect_type must be one of: Permanent, Temporary, Found, SeeOther."
  }
}

variable "request_routing_rule" {
  type        = map(object({
    backend_address_pool_name = optional(string)
    backend_http_settings_name = optional(string)
    http_listener_name = string
    name = string
    priority = optional(number)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name = optional(string)
    rule_type = string
    url_path_map_name = optional(string)
  }))
  description = <<-DESCRIPTION
  - `backend_address_pool_name` - (Optional) The Name of the Backend Address Pool which should be used for this Routing Rule. Cannot be set if `redirect_configuration_name` is set.
  - `backend_http_settings_name` - (Optional) The Name of the Backend HTTP Settings Collection which should be used for this Routing Rule. Cannot be set if `redirect_configuration_name` is set.
  - `http_listener_name` - (Required) The Name of the HTTP Listener which should be used for this Routing Rule.
  - `name` - (Required) The Name of this Request Routing Rule.
  - `priority` - (Optional) Rule evaluation order can be dictated by specifying an integer value from `1` to `20000` with `1` being the highest priority and `20000` being the lowest priority.
  - `redirect_configuration_name` - (Optional) The Name of the Redirect Configuration which should be used for this Routing Rule. Cannot be set if either `backend_address_pool_name` or `backend_http_settings_name` is set.
  - `rewrite_rule_set_name` - (Optional) The Name of the Rewrite Rule Set which should be used for this Routing Rule. Only valid for v2 SKUs.
  - `rule_type` - (Required) The Type of Routing that should be used for this Rule. Possible values are `Basic` and `PathBasedRouting`.
  - `url_path_map_name` - (Optional) The Name of the URL Path Map which should be associated with this Routing Rule.
  DESCRIPTION
  validation {
    condition     = alltrue([for k, v in var.request_routing_rule : contains(["Basic", "PathBasedRouting"], v.rule_type)])
    error_message = "request_routing_rule.rule_type must be one of: Basic, PathBasedRouting."
  }
}

variable "rewrite_rule_set" {
  type        = map(object({
    name = string
    rewrite_rule = optional(map(object({
      name = string
      rule_sequence = number
      condition = optional(map(object({
        ignore_case = optional(bool)
        negate = optional(bool)
        pattern = string
        variable = string
      })))
      request_header_configuration = optional(map(object({
        header_name = string
        header_value = string
      })))
      response_header_configuration = optional(map(object({
        header_name = string
        header_value = string
      })))
      url = optional(object({
        components = optional(string)
        path = optional(string)
        query_string = optional(string)
        reroute = optional(bool)
      }))
    })))
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `name` - (Required) Unique name of the rewrite rule set block

  ---
  `rewrite_rule` block supports the following:
    - `name` - (Required) The name of the Application Gateway. Changing this forces a new resource to be created.
    - `rule_sequence` - (Required) The rule sequence value.

    ---
    `condition` block supports the following:
      - `ignore_case` - (Optional) The ignore case value.
      - `negate` - (Optional) The negate value.
      - `pattern` - (Required) The pattern value.
      - `variable` - (Required) The variable value.

    ---
    `request_header_configuration` block supports the following:
      - `header_name` - (Required) The header name value.
      - `header_value` - (Required) The header value value.

    ---
    `response_header_configuration` block supports the following:
      - `header_name` - (Required) The header name value.
      - `header_value` - (Required) The header value value.

    ---
    `url` block supports the following:
      - `components` - (Optional) The components value.
      - `path` - (Optional) The path value.
      - `query_string` - (Optional) The query string value.
      - `reroute` - (Optional) The reroute value.
  DESCRIPTION
}

variable "sku" {
  type        = object({
    capacity = optional(number)
    name = string
    tier = string
  })
  description = <<-DESCRIPTION
  - `capacity` - (Optional) The Capacity of the SKU to use for this Application Gateway. When using a V1 SKU this value must be between `1` and `32`, and `1` to `125` for a V2 SKU. When using a `Basic` SKU this property must be between `1` and `2`. This property is optional if `autoscale_configuration` is set.
  - `name` - (Required) The Name of the SKU to use for this Application Gateway. Possible values are `Basic`, `Standard_Small`, `Standard_Medium`, `Standard_Large`, `Standard_v2`, `WAF_Large`, `WAF_Medium` and `WAF_v2`.
  - `tier` - (Required) The Tier of the SKU to use for this Application Gateway. Possible values are `Basic`, `Standard`, `Standard_v2`, `WAF`, and `WAF_v2`.
  DESCRIPTION
  validation {
    condition     = contains(["Basic", "Standard_Small", "Standard_Medium", "Standard_Large", "Standard_v2", "WAF_Large", "WAF_Medium", "WAF_v2"], var.sku.name)
    error_message = "sku.name must be one of: Basic, Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Large, WAF_Medium, WAF_v2."
  }
  validation {
    condition     = contains(["Basic", "Standard", "Standard_v2", "WAF", "WAF_v2"], var.sku.tier)
    error_message = "sku.tier must be one of: Basic, Standard, Standard_v2, WAF, WAF_v2."
  }
}

variable "ssl_certificate" {
  type        = map(object({
    data = optional(string)
    key_vault_secret_id = optional(string)
    name = string
    password = optional(string)
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `data` - (Optional) The base64-encoded PFX certificate data. Required if `key_vault_secret_id` is not set.
  - `key_vault_secret_id` - (Optional) The Secret ID of the (base-64 encoded unencrypted pfx) `Secret` or `Certificate` object stored in Azure KeyVault. You need to enable soft delete for Key Vault to use this feature. Required if `data` is not set.
  - `name` - (Required) The Name of the SSL certificate that is unique within this Application Gateway
  - `password` - (Optional) Password for the pfx file specified in data. Required if `data` is set.
  DESCRIPTION
}

variable "ssl_policy" {
  type        = object({
    cipher_suites = optional(list(string))
    disabled_protocols = optional(list(string))
    min_protocol_version = optional(string)
    policy_name = optional(string)
    policy_type = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `cipher_suites` - (Optional) A List of accepted cipher suites. Possible values are: `TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA`, `TLS_DHE_DSS_WITH_AES_128_CBC_SHA`, `TLS_DHE_DSS_WITH_AES_128_CBC_SHA256`, `TLS_DHE_DSS_WITH_AES_256_CBC_SHA`, `TLS_DHE_DSS_WITH_AES_256_CBC_SHA256`, `TLS_DHE_RSA_WITH_AES_128_CBC_SHA`, `TLS_DHE_RSA_WITH_AES_128_GCM_SHA256`, `TLS_DHE_RSA_WITH_AES_256_CBC_SHA`, `TLS_DHE_RSA_WITH_AES_256_GCM_SHA384`, `TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA`, `TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256`, `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256`, `TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA`, `TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384`, `TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384`, `TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA`, `TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256`, `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`, `TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA`, `TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384`, `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`, `TLS_RSA_WITH_3DES_EDE_CBC_SHA`, `TLS_RSA_WITH_AES_128_CBC_SHA`, `TLS_RSA_WITH_AES_128_CBC_SHA256`, `TLS_RSA_WITH_AES_128_GCM_SHA256`, `TLS_RSA_WITH_AES_256_CBC_SHA`, `TLS_RSA_WITH_AES_256_CBC_SHA256` and `TLS_RSA_WITH_AES_256_GCM_SHA384`.
  - `disabled_protocols` - (Optional) A list of SSL Protocols which should be disabled on this Application Gateway. Possible values are `TLSv1_0`, `TLSv1_1`, `TLSv1_2` and `TLSv1_3`.
  - `min_protocol_version` - (Optional) The minimal TLS version. Possible values are `TLSv1_0`, `TLSv1_1`, `TLSv1_2` and `TLSv1_3`.
  - `policy_name` - (Optional) The Name of the Policy e.g. AppGwSslPolicy20170401S. Required if `policy_type` is set to `Predefined`. Possible values can change over time and are published here <https://docs.microsoft.com/azure/application-gateway/application-gateway-ssl-policy-overview>. Not compatible with `disabled_protocols`.
  - `policy_type` - (Optional) The Type of the Policy. Possible values are `Predefined`, `Custom` and `CustomV2`.
  DESCRIPTION
  validation {
    condition     = var.ssl_policy == null || contains(["TLSv1_0", "TLSv1_1", "TLSv1_2", "TLSv1_3"], var.ssl_policy.min_protocol_version)
    error_message = "ssl_policy.min_protocol_version must be one of: TLSv1_0, TLSv1_1, TLSv1_2, TLSv1_3."
  }
  validation {
    condition     = var.ssl_policy == null || contains(["Predefined", "Custom", "CustomV2"], var.ssl_policy.policy_type)
    error_message = "ssl_policy.policy_type must be one of: Predefined, Custom, CustomV2."
  }
}

variable "ssl_profile" {
  type        = map(object({
    name = string
    trusted_client_certificate_names = optional(list(string))
    verify_client_cert_issuer_dn = optional(bool)
    verify_client_certificate_revocation = optional(string)
    ssl_policy = optional(object({
      cipher_suites = optional(list(string))
      disabled_protocols = optional(list(string))
      min_protocol_version = optional(string)
      policy_name = optional(string)
      policy_type = optional(string)
    }))
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `name` - (Required) The name of the SSL Profile that is unique within this Application Gateway.
  - `trusted_client_certificate_names` - (Optional) The name of the Trusted Client Certificate that will be used to authenticate requests from clients.
  - `verify_client_cert_issuer_dn` - (Optional) Should client certificate issuer DN be verified? Defaults to `false`.
  - `verify_client_certificate_revocation` - (Optional) Specify the method to check client certificate revocation status. Possible value is `OCSP`.

  ---
  `ssl_policy` block supports the following:
    - `cipher_suites` - (Optional) The cipher suites value.
    - `disabled_protocols` - (Optional) The disabled protocols value.
    - `min_protocol_version` - (Optional) The min protocol version value.
    - `policy_name` - (Optional) The policy name value.
    - `policy_type` - (Optional) The policy type value.
  DESCRIPTION
}

variable "timeouts" {
  type        = object({
    create = optional(string)
    delete = optional(string)
    read = optional(string)
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

variable "trusted_client_certificate" {
  type        = map(object({
    data = string
    name = string
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `data` - (Required) The base-64 encoded certificate.
  - `name` - (Required) The name of the Trusted Client Certificate that is unique within this Application Gateway.
  DESCRIPTION
}

variable "trusted_root_certificate" {
  type        = map(object({
    data = optional(string)
    key_vault_secret_id = optional(string)
    name = string
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `data` - (Optional) The contents of the Trusted Root Certificate which should be used. Required if `key_vault_secret_id` is not set.
  - `key_vault_secret_id` - (Optional) The Secret ID of the (base-64 encoded unencrypted pfx) `Secret` or `Certificate` object stored in Azure KeyVault. You need to enable soft delete for the Key Vault to use this feature. Required if `data` is not set.
  - `name` - (Required) The Name of the Trusted Root Certificate to use.
  DESCRIPTION
}

variable "url_path_map" {
  type        = map(object({
    default_backend_address_pool_name = optional(string)
    default_backend_http_settings_name = optional(string)
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name = optional(string)
    name = string
    path_rule = map(object({
      backend_address_pool_name = optional(string)
      backend_http_settings_name = optional(string)
      firewall_policy_id = optional(string)
      name = string
      paths = list(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name = optional(string)
    }))
  }))
  default     = {}
  description = <<-DESCRIPTION
  - `default_backend_address_pool_name` - (Optional) The Name of the Default Backend Address Pool which should be used for this URL Path Map. Cannot be set if `default_redirect_configuration_name` is set.
  - `default_backend_http_settings_name` - (Optional) The Name of the Default Backend HTTP Settings Collection which should be used for this URL Path Map. Cannot be set if `default_redirect_configuration_name` is set.
  - `default_redirect_configuration_name` - (Optional) The Name of the Default Redirect Configuration which should be used for this URL Path Map. Cannot be set if either `default_backend_address_pool_name` or `default_backend_http_settings_name` is set.
  - `default_rewrite_rule_set_name` - (Optional) The Name of the Default Rewrite Rule Set which should be used for this URL Path Map. Only valid for v2 SKUs.
  - `name` - (Required) The Name of the URL Path Map.

  ---
  `path_rule` block supports the following:
    - `backend_address_pool_name` - (Optional) The backend address pool name value.
    - `backend_http_settings_name` - (Optional) The backend http settings name value.
    - `firewall_policy_id` - (Optional) The ID of the Web Application Firewall Policy.
    - `name` - (Required) The name of the Application Gateway. Changing this forces a new resource to be created.
    - `paths` - (Required) The paths value.
    - `redirect_configuration_name` - (Optional) The redirect configuration name value.
    - `rewrite_rule_set_name` - (Optional) The rewrite rule set name value.
  DESCRIPTION
}

variable "waf_configuration" {
  type        = object({
    enabled = bool
    file_upload_limit_mb = optional(number)
    firewall_mode = string
    max_request_body_size_kb = optional(number)
    request_body_check = optional(bool)
    rule_set_type = optional(string)
    rule_set_version = string
    disabled_rule_group = optional(map(object({
      rule_group_name = string
      rules = optional(list(number))
    })))
    exclusion = optional(map(object({
      match_variable = string
      selector = optional(string)
      selector_match_operator = optional(string)
    })))
  })
  default     = null
  description = <<-DESCRIPTION
  - `enabled` - (Required) Is the Web Application Firewall enabled?
  - `file_upload_limit_mb` - (Optional) The File Upload Limit in MB. Accepted values are in the range `1`MB to `750`MB for the `WAF_v2` SKU, and `1`MB to `500`MB for all other SKUs. Defaults to `100`MB.
  - `firewall_mode` - (Required) The Web Application Firewall Mode. Possible values are `Detection` and `Prevention`.
  - `max_request_body_size_kb` - (Optional) The Maximum Request Body Size in KB. Accepted values are in the range `1`KB to `128`KB. Defaults to `128`KB.
  - `request_body_check` - (Optional) Is Request Body Inspection enabled? Defaults to `true`.
  - `rule_set_type` - (Optional) The Type of the Rule Set used for this Web Application Firewall. Possible values are `OWASP`, `Microsoft_BotManagerRuleSet` and `Microsoft_DefaultRuleSet`. Defaults to `OWASP`.
  - `rule_set_version` - (Required) The Version of the Rule Set used for this Web Application Firewall. Possible values are `0.1`, `1.0`, `1.1`, `2.1`, `2.2.9`, `3.0`, `3.1` and `3.2`.

  ---
  `disabled_rule_group` block supports the following:
    - `rule_group_name` - (Required) The rule group name value.
    - `rules` - (Optional) The rules value.

  ---
  `exclusion` block supports the following:
    - `match_variable` - (Required) The match variable value.
    - `selector` - (Optional) The selector value.
    - `selector_match_operator` - (Optional) The selector match operator value.
  DESCRIPTION
  validation {
    condition     = var.waf_configuration == null || contains(["Detection", "Prevention"], var.waf_configuration.firewall_mode)
    error_message = "waf_configuration.firewall_mode must be one of: Detection, Prevention."
  }
  validation {
    condition     = var.waf_configuration == null || contains(["OWASP", "Microsoft_BotManagerRuleSet", "Microsoft_DefaultRuleSet"], var.waf_configuration.rule_set_type)
    error_message = "waf_configuration.rule_set_type must be one of: OWASP, Microsoft_BotManagerRuleSet, Microsoft_DefaultRuleSet."
  }
}


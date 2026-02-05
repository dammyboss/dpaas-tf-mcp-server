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

variable "create_static_web_app" {
  type        = bool
  description = "Whether to create the Static Web App."
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

variable "static_web_app_name" {
  description = "Specifies the name of the Static Web App"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Static Web App"
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists"
  type        = string
}

variable "app_settings" {
  description = "(Optional) A key-value pair of App Settings."
  type        = map(string)
  default     = null
}

variable "configuration_file_changes_enabled" {
  description = "(Optional) Should changes to the configuration file be permitted. Defaults to `true`."
  type        = bool
  default     = null
}

variable "preview_environments_enabled" {
  description = "(Optional) Are Preview (Staging) environments enabled. Defaults to `true`."
  type        = bool
  default     = null
}

variable "public_network_access_enabled" {
  description = "(Optional) Should public network access be enabled for the Static Web App. Defaults to `true`."
  type        = bool
  default     = null
}

variable "repository_branch" {
  description = "(Optional) Repository branch to use for the Static Web App. `repository_url` and `repository_token` must also be set."
  type        = string
  default     = null
}

variable "repository_token" {
  description = "(Optional) Repository Token with `admin` privileges to use for the Static Web App. `repository_branch` and `repository_url` must also be set."
  type        = string
  default     = null
  sensitive   = true
}

variable "repository_url" {
  description = "(Optional) Repository URL to use for the Static Web App. `repository_branch` and `repository_token` must also be set."
  type        = string
  default     = null
}

variable "sku_size" {
  description = "(Optional) Specifies the SKU size of the Static Web App. Possible values are `Free` or `Standard`. Defaults to `Free`."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "(Optional) Specifies the SKU tier of the Static Web App. Possible values are `Free` or `Standard`. Defaults to `Free`."
  type        = string
  default     = null
}

variable "basic_auth" {
  type = object({
    environments = string
    password     = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `environments` - (Required) The Environment types to use the Basic Auth for access. Possible values include `AllEnvironments` and `StagingEnvironments`.
  - `password` - (Required) The password for the basic authentication access.
  DESCRIPTION
  validation {
    condition     = var.basic_auth == null || contains(["AllEnvironments", "StagingEnvironments"], var.basic_auth.environments)
    error_message = "basic_auth.environments must be one of: AllEnvironments, StagingEnvironments."
  }
}

variable "identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `identity_ids` - (Optional) A list of Managed Identity IDs which should be assigned to this Static Web App resource.
  - `type` - (Required) The Type of Managed Identity assigned to this Static Web App resource. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`.
  DESCRIPTION
  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned", "UserAssigned"], var.identity.type)
    error_message = "identity.type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
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


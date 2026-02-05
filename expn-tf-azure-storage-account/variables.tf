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

variable "create_storage_account" {
  type        = bool
  description = "Whether to create the Storage Account."
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

variable "storage_account_name" {
  description = "Specifies the name of the Storage Account"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Storage Account"
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists"
  type        = string
}

variable "account_replication_type" {
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. Changing this forces a new resource to be created wh..."
  type        = string
}

variable "account_tier" {
  description = "(Required) Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this for..."
  type        = string
}

variable "access_tier" {
  description = "(Optional) Defines the access tier for `BlobStorage`, `FileStorage` and `StorageV2` accounts. Valid options are `Hot`, `Cool`, `Cold` and `Premium`. Defaults to `Hot`."
  type        = string
  default     = null
}

variable "account_kind" {
  description = "(Optional) Defines the Kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. Defaults to `StorageV2`."
  type        = string
  default     = null
}

variable "allow_nested_items_to_be_public" {
  description = "(Optional) Allow or disallow nested items within this Account to opt into being public. Defaults to `true`."
  type        = bool
  default     = null
}

variable "allowed_copy_scope" {
  description = "(Optional) Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are `AAD` and `PrivateLink`."
  type        = string
  default     = null
  validation {
    condition     = var.allowed_copy_scope == null || contains(["AAD", "PrivateLink"], var.allowed_copy_scope)
    error_message = "allowed_copy_scope must be one of: AAD, PrivateLink."
  }
}

variable "cross_tenant_replication_enabled" {
  description = "(Optional) Should cross Tenant replication be enabled? Defaults to `false`."
  type        = bool
  default     = null
}

variable "default_to_oauth_authentication" {
  description = "(Optional) Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is `false`"
  type        = bool
  default     = null
}

variable "dns_endpoint_type" {
  description = "(Optional) Specifies which DNS endpoint type to use. Possible values are `Standard` and `AzureDnsZone`. Defaults to `Standard`. Changing this forces a new resource to be created."
  type        = string
  default     = null
  validation {
    condition     = var.dns_endpoint_type == null || contains(["Standard", "AzureDnsZone"], var.dns_endpoint_type)
    error_message = "dns_endpoint_type must be one of: Standard, AzureDnsZone."
  }
}

variable "edge_zone" {
  description = "(Optional) Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Changing this forces a new Storage Account to be created."
  type        = string
  default     = null
}

variable "https_traffic_only_enabled" {
  description = "(Optional) Boolean flag which forces HTTPS if enabled, see here for more information. Defaults to `true`."
  type        = bool
  default     = null
}

variable "infrastructure_encryption_enabled" {
  description = "(Optional) Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to `false`."
  type        = bool
  default     = null
}

variable "is_hns_enabled" {
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 (see here for more information). Changing this forces a new resource to be created."
  type        = bool
  default     = null
}

variable "large_file_share_enabled" {
  description = "(Optional) Are Large File Shares Enabled? Defaults to `false`."
  type        = bool
  default     = null
}

variable "local_user_enabled" {
  description = "(Optional) Is Local User Enabled? Defaults to `true`."
  type        = bool
  default     = null
}

variable "min_tls_version" {
  description = "(Optional) The minimum supported TLS version for the storage account. Possible values are `TLS1_0`, `TLS1_1`, `TLS1_2` and `TLS1_3`. Defaults to `TLS1_2` for new storage accounts."
  type        = string
  default     = null
  validation {
    condition     = var.min_tls_version == null || contains(["TLS1_0", "TLS1_1", "TLS1_2", "TLS1_3"], var.min_tls_version)
    error_message = "min_tls_version must be one of: TLS1_0, TLS1_1, TLS1_2, TLS1_3."
  }
}

variable "nfsv3_enabled" {
  description = "(Optional) Is NFSv3 protocol enabled? Changing this forces a new resource to be created. Defaults to `false`."
  type        = bool
  default     = null
}

variable "provisioned_billing_model_version" {
  description = "(Optional) Specifies the version of the **provisioned** billing model (e.g. when `account_kind = \"FileStorage\"` for Storage File). Possible value is `V2`. Changing this forces a new resource to b..."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether the public network access is enabled? Defaults to `true`."
  type        = bool
  default     = null
}

variable "queue_encryption_key_type" {
  description = "(Optional) The encryption type of the queue service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created. Default value is `Service`."
  type        = string
  default     = null
  validation {
    condition     = var.queue_encryption_key_type == null || contains(["Service", "Account"], var.queue_encryption_key_type)
    error_message = "queue_encryption_key_type must be one of: Service, Account."
  }
}

variable "sftp_enabled" {
  description = "(Optional) Boolean, enable SFTP for the storage account"
  type        = bool
  default     = null
}

variable "shared_access_key_enabled" {
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must ..."
  type        = bool
  default     = null
}

variable "table_encryption_key_type" {
  description = "(Optional) The encryption type of the table service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created. Default value is `Service`."
  type        = string
  default     = null
  validation {
    condition     = var.table_encryption_key_type == null || contains(["Service", "Account"], var.table_encryption_key_type)
    error_message = "table_encryption_key_type must be one of: Service, Account."
  }
}

variable "azure_files_authentication" {
  type = object({
    default_share_level_permission = optional(string)
    directory_type                 = string
    active_directory = optional(object({
      domain_guid         = string
      domain_name         = string
      domain_sid          = optional(string)
      forest_name         = optional(string)
      netbios_domain_name = optional(string)
      storage_sid         = optional(string)
    }))
  })
  default     = null
  description = <<-DESCRIPTION
  - `default_share_level_permission` - (Optional) Specifies the default share level permissions applied to all users. Possible values are `StorageFileDataSmbShareReader`, `StorageFileDataSmbShareContributor`, `StorageFileDataSmbShareElevatedContributor`, or `None`. Defaults to `None`.
  - `directory_type` - (Required) Specifies the directory service used. Possible values are `AADDS`, `AD` and `AADKERB`.

  ---
  `active_directory` block supports the following:
    - `domain_guid` - (Required) The domain guid value.
    - `domain_name` - (Required) The domain name value.
    - `domain_sid` - (Optional) The domain sid value.
    - `forest_name` - (Optional) The forest name value.
    - `netbios_domain_name` - (Optional) The netbios domain name value.
    - `storage_sid` - (Optional) The storage sid value.
  DESCRIPTION
  validation {
    condition     = var.azure_files_authentication == null || contains(["StorageFileDataSmbShareReader", "StorageFileDataSmbShareContributor", "StorageFileDataSmbShareElevatedContributor"], var.azure_files_authentication.default_share_level_permission)
    error_message = "azure_files_authentication.default_share_level_permission must be one of: StorageFileDataSmbShareReader, StorageFileDataSmbShareContributor, StorageFileDataSmbShareElevatedContributor."
  }
  validation {
    condition     = var.azure_files_authentication == null || contains(["AADDS", "AD", "AADKERB"], var.azure_files_authentication.directory_type)
    error_message = "azure_files_authentication.directory_type must be one of: AADDS, AD, AADKERB."
  }
}

variable "blob_properties" {
  type = object({
    change_feed_enabled           = optional(bool)
    change_feed_retention_in_days = optional(number)
    default_service_version       = optional(string)
    last_access_time_enabled      = optional(bool)
    versioning_enabled            = optional(bool)
    container_delete_retention_policy = optional(object({
      days = optional(number)
    }))
    cors_rule = optional(map(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    delete_retention_policy = optional(object({
      days                     = optional(number)
      permanent_delete_enabled = optional(bool)
    }))
    restore_policy = optional(object({
      days = number
    }))
  })
  default     = null
  description = <<-DESCRIPTION
  - `change_feed_enabled` - (Optional) Is the blob service properties for change feed events enabled? Default to `false`.
  - `change_feed_retention_in_days` - (Optional) The duration of change feed events retention in days. The possible values are between 1 and 146000 days (400 years). Setting this to null (or omit this in the configuration file) indicates an infinite retention of the change feed.
  - `default_service_version` - (Optional) The API Version which should be used by default for requests to the Data Plane API if an incoming request doesn't specify an API Version.
  - `last_access_time_enabled` - (Optional) Is the last access time based tracking enabled? Default to `false`.
  - `versioning_enabled` - (Optional) Is versioning enabled? Default to `false`.

  ---
  `container_delete_retention_policy` block supports the following:
    - `days` - (Optional) The days value.

  ---
  `cors_rule` block supports the following:
    - `allowed_headers` - (Required) The allowed headers value.
    - `allowed_methods` - (Required) The allowed methods value.
    - `allowed_origins` - (Required) The allowed origins value.
    - `exposed_headers` - (Required) The exposed headers value.
    - `max_age_in_seconds` - (Required) The max age in seconds value.

  ---
  `delete_retention_policy` block supports the following:
    - `days` - (Optional) The days value.
    - `permanent_delete_enabled` - (Optional) The permanent delete enabled value.

  ---
  `restore_policy` block supports the following:
    - `days` - (Required) The days value.
  DESCRIPTION
}

variable "custom_domain" {
  type = object({
    name          = string
    use_subdomain = optional(bool)
  })
  default     = null
  description = <<-DESCRIPTION
  - `name` - (Required) The Custom Domain Name to use for the Storage Account, which will be validated by Azure.
  - `use_subdomain` - (Optional) Should the Custom Domain Name be validated by using indirect CNAME validation?
  DESCRIPTION
}

variable "customer_managed_key" {
  type = object({
    key_vault_key_id          = optional(string)
    user_assigned_identity_id = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `key_vault_key_id` - (Optional) The ID of the Key Vault Key, supplying a version-less key ID will enable auto-rotation of this key.
  - `user_assigned_identity_id` - (Required) The ID of a user assigned identity.
  DESCRIPTION
}

variable "identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `identity_ids` - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account.
  - `type` - (Required) Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both).
  DESCRIPTION
  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned"], var.identity.type)
    error_message = "identity.type must be one of: SystemAssigned, UserAssigned, SystemAssigned."
  }
}

variable "immutability_policy" {
  type = object({
    allow_protected_append_writes = bool
    period_since_creation_in_days = number
    state                         = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `allow_protected_append_writes` - (Required) When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted.
  - `period_since_creation_in_days` - (Required) The immutability period for the blobs in the container since the policy creation, in days.
  - `state` - (Required) Defines the mode of the policy. `Disabled` state disables the policy, `Unlocked` state allows increase and decrease of immutability retention time and also allows toggling allowProtectedAppendWrites property, `Locked` state only allows the increase of the immutability retention time. A policy can only be created in a Disabled or Unlocked state and can be toggled between the two states. Only a policy in an Unlocked state can transition to a Locked state which cannot be reverted.
  DESCRIPTION
}

variable "network_rules" {
  type = object({
    bypass                     = optional(set(string))
    default_action             = string
    ip_rules                   = optional(set(string))
    virtual_network_subnet_ids = optional(set(string))
    private_link_access = optional(map(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string)
    })))
  })
  default     = null
  description = <<-DESCRIPTION
  - `bypass` - (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of `Logging`, `Metrics`, `AzureServices`, or `None`.
  - `default_action` - (Required) Specifies the default action of allow or deny when no other rules match. Valid options are `Deny` or `Allow`.
  - `ip_rules` - (Optional) List of public IP or IP ranges in CIDR Format. Only IPv4 addresses are allowed. /31 CIDRs, /32 CIDRs, and Private IP address ranges (as defined in RFC 1918), are not allowed.
  - `virtual_network_subnet_ids` - (Optional) A list of resource ids for subnets.

  ---
  `private_link_access` block supports the following:
    - `endpoint_resource_id` - (Required) The endpoint resource id value.
    - `endpoint_tenant_id` - (Optional) The endpoint tenant id value.
  DESCRIPTION
}

variable "queue_properties" {
  type = object({
    cors_rule = optional(map(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    hour_metrics = optional(object({
      enabled               = bool
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
      version               = string
    }))
    logging = optional(object({
      delete                = bool
      read                  = bool
      retention_policy_days = optional(number)
      version               = string
      write                 = bool
    }))
    minute_metrics = optional(object({
      enabled               = bool
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
      version               = string
    }))
  })
  default     = null
  description = <<-DESCRIPTION

  ---
  `cors_rule` block supports the following:
    - `allowed_headers` - (Required) The allowed headers value.
    - `allowed_methods` - (Required) The allowed methods value.
    - `allowed_origins` - (Required) The allowed origins value.
    - `exposed_headers` - (Required) The exposed headers value.
    - `max_age_in_seconds` - (Required) The max age in seconds value.

  ---
  `hour_metrics` block supports the following:
    - `enabled` - (Required) The enabled value.
    - `include_apis` - (Optional) The include apis value.
    - `retention_policy_days` - (Optional) The retention policy days value.
    - `version` - (Required) The version value.

  ---
  `logging` block supports the following:
    - `delete` - (Required) The delete value.
    - `read` - (Required) The read value.
    - `retention_policy_days` - (Optional) The retention policy days value.
    - `version` - (Required) The version value.
    - `write` - (Required) The write value.

  ---
  `minute_metrics` block supports the following:
    - `enabled` - (Required) The enabled value.
    - `include_apis` - (Optional) The include apis value.
    - `retention_policy_days` - (Optional) The retention policy days value.
    - `version` - (Required) The version value.
  DESCRIPTION
}

variable "routing" {
  type = object({
    choice                      = optional(string)
    publish_internet_endpoints  = optional(bool)
    publish_microsoft_endpoints = optional(bool)
  })
  default     = null
  description = <<-DESCRIPTION
  - `choice` - (Optional) Specifies the kind of network routing opted by the user. Possible values are `InternetRouting` and `MicrosoftRouting`. Defaults to `MicrosoftRouting`.
  - `publish_internet_endpoints` - (Optional) Should internet routing storage endpoints be published? Defaults to `false`.
  - `publish_microsoft_endpoints` - (Optional) Should Microsoft routing storage endpoints be published? Defaults to `false`.
  DESCRIPTION
  validation {
    condition     = var.routing == null || contains(["InternetRouting", "MicrosoftRouting"], var.routing.choice)
    error_message = "routing.choice must be one of: InternetRouting, MicrosoftRouting."
  }
}

variable "sas_policy" {
  type = object({
    expiration_action = optional(string)
    expiration_period = string
  })
  default     = null
  description = <<-DESCRIPTION
  - `expiration_action` - (Optional) The SAS expiration action. Possible values are `Log` and `Block`. Defaults to `Log`.
  - `expiration_period` - (Required) The SAS expiration period in format of `DD.HH:MM:SS`.
  DESCRIPTION
  validation {
    condition     = var.sas_policy == null || contains(["Log", "Block"], var.sas_policy.expiration_action)
    error_message = "sas_policy.expiration_action must be one of: Log, Block."
  }
}

variable "share_properties" {
  type = object({
    cors_rule = optional(map(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    retention_policy = optional(object({
      days = optional(number)
    }))
    smb = optional(object({
      authentication_types            = optional(set(string))
      channel_encryption_type         = optional(set(string))
      kerberos_ticket_encryption_type = optional(set(string))
      multichannel_enabled            = optional(bool)
      versions                        = optional(set(string))
    }))
  })
  default     = null
  description = <<-DESCRIPTION

  ---
  `cors_rule` block supports the following:
    - `allowed_headers` - (Required) The allowed headers value.
    - `allowed_methods` - (Required) The allowed methods value.
    - `allowed_origins` - (Required) The allowed origins value.
    - `exposed_headers` - (Required) The exposed headers value.
    - `max_age_in_seconds` - (Required) The max age in seconds value.

  ---
  `retention_policy` block supports the following:
    - `days` - (Optional) The days value.

  ---
  `smb` block supports the following:
    - `authentication_types` - (Optional) The authentication types value.
    - `channel_encryption_type` - (Optional) The channel encryption type value.
    - `kerberos_ticket_encryption_type` - (Optional) The kerberos ticket encryption type value.
    - `multichannel_enabled` - (Optional) The multichannel enabled value.
    - `versions` - (Optional) The versions value.
  DESCRIPTION
}

variable "static_website" {
  type = object({
    error_404_document = optional(string)
    index_document     = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  - `error_404_document` - (Optional) The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file.
  - `index_document` - (Optional) The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, index.html. The value is case-sensitive.
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


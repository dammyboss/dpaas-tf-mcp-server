package generators

// NamingRule defines Azure resource naming restrictions for resources
// that only allow lowercase letters and numbers (no hyphens, underscores, etc.).
// Reference: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
type NamingRule struct {
	MaxLength      int
	StartWithAlpha bool // must start with a letter (not a number)
}

// restrictedNamingResources maps azurerm resource types to their naming restrictions.
// Only resources whose valid characters are "lowercase letters and numbers" are included.
// Resources that allow hyphens (like key vault, most network resources) are NOT included.
var restrictedNamingResources = map[string]NamingRule{
	"azurerm_storage_account":              {MaxLength: 24, StartWithAlpha: false},
	"azurerm_batch_account":                {MaxLength: 24, StartWithAlpha: false},
	"azurerm_data_lake_analytics_account":  {MaxLength: 24, StartWithAlpha: false},
	"azurerm_data_lake_store":              {MaxLength: 24, StartWithAlpha: false},
	"azurerm_media_services_account":       {MaxLength: 24, StartWithAlpha: false},
	"azurerm_kusto_cluster":                {MaxLength: 22, StartWithAlpha: true},
	"azurerm_synapse_private_link_hub":     {MaxLength: 45, StartWithAlpha: false},
	"azurerm_container_registry":           {MaxLength: 50, StartWithAlpha: false},
	"azurerm_blockchain_member":            {MaxLength: 20, StartWithAlpha: true},
	"azurerm_analysis_services_server":     {MaxLength: 63, StartWithAlpha: true},
}

// GetNamingRule returns the naming rule for a resource type, or nil if no restriction applies.
func GetNamingRule(resourceType string) *NamingRule {
	if rule, ok := restrictedNamingResources[resourceType]; ok {
		return &rule
	}
	return nil
}

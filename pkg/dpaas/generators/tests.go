package generators

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/templates"
)

func GenerateTests(info *schema.ResourceInfo) map[string]string {
	files := map[string]string{}

	// Default test
	files["tests/default/main.tf"] = generateDefaultTest(info)
	files["tests/default/versions.tf"] = templates.VersionsTestTf

	return files
}

func generateDefaultTest(info *schema.ResourceInfo) string {
	var b strings.Builder

	moduleName := strings.ReplaceAll(info.ShortName, "_", "_")

	b.WriteString(fmt.Sprintf("module \"%s\" {\n\n", moduleName))
	b.WriteString("  source = \"../..\"\n\n")
	b.WriteString("  enabled = true\n\n")
	b.WriteString("  namespace   = \"expn\"\n")
	b.WriteString("  tenant      = \"msp\"\n")
	b.WriteString("  environment = \"sbx\"\n")
	b.WriteString("  name        = \"sample\"\n\n")

	// Add the {resource}_name as a commented example (it's optional in the module)
	resourceNameVar := info.ShortName + "_name"
	exampleName := strings.ReplaceAll(info.ShortName, "_", "-")
	b.WriteString(fmt.Sprintf("  # %-25s = \"example-%s\"\n", resourceNameVar, exampleName))

	// Only add location and resource_group_name if they exist in the schema
	hasLocation := false
	hasResourceGroupName := false
	for _, attr := range info.Attributes {
		if attr.Name == "location" {
			hasLocation = true
		}
		if attr.Name == "resource_group_name" {
			hasResourceGroupName = true
		}
	}

	if hasLocation {
		b.WriteString(fmt.Sprintf("  %-27s = %s\n", "location", "\"East US 2\""))
	}
	if hasResourceGroupName {
		b.WriteString(fmt.Sprintf("  %-27s = %s\n", "resource_group_name", "\"eits-Sandbox-mspsandbox-BU-07959a-rg\""))
	}

	// Collect required attributes (excluding standard ones)
	var requiredAttrs []schema.ParsedAttribute
	for _, attr := range info.Attributes {
		if attr.Required && !isStandardTestVar(attr.Name) {
			requiredAttrs = append(requiredAttrs, attr)
		}
	}

	// Add required attributes section if any exist
	if len(requiredAttrs) > 0 {
		b.WriteString("\n  # Required attributes\n")
		for _, attr := range requiredAttrs {
			exampleValue := generateExampleValue(attr)
			b.WriteString(fmt.Sprintf("  %-27s = %s\n", attr.Name, exampleValue))
		}
	}

	// Add required blocks section
	var requiredBlocks []schema.ParsedBlock
	for _, block := range info.Blocks {
		if block.Required {
			requiredBlocks = append(requiredBlocks, block)
		}
	}

	if len(requiredBlocks) > 0 {
		b.WriteString("\n  # Required blocks\n")
		for _, block := range requiredBlocks {
			exampleBlock := generateExampleBlock(block)
			b.WriteString(exampleBlock)
		}
	}

	// Tags
	b.WriteString("\n  tags = {\n")
	b.WriteString("    \"CostString\"  = \"0000.111.11.22\"\n")
	b.WriteString("    \"AppID\"       = \"0\"\n")
	b.WriteString("    \"Environment\" = \"sbx\"\n")
	b.WriteString("  }\n")
	b.WriteString("}\n")

	return b.String()
}

// isStandardTestVar identifies variables that are handled specially in the module
// and should not be included from the schema's required attributes list
func isStandardTestVar(name string) bool {
	// These variables are handled specially:
	// - name: renamed to {resource}_name and made optional (default = null)
	// - location: always created as required, but we add it manually
	// - resource_group_name: always created as required, but we add it manually
	// - tags: comes from null-label, not a direct input
	// - id: computed output, not an input
	return name == "name" || name == "location" || name == "resource_group_name" || name == "tags" || name == "id"
}

// generateExampleValue creates a sensible example value for a required attribute
func generateExampleValue(attr schema.ParsedAttribute) string {
	// Use enum values if available
	if len(attr.EnumValues) > 0 {
		return fmt.Sprintf("\"%s\"", attr.EnumValues[0])
	}

	// Common Azure attribute patterns with smart formatting
	switch attr.Name {
	case "location":
		return "\"East US 2\""
	case "resource_group_name":
		return "\"eits-Sandbox-mspsandbox-BU-07959a-rg\""
	case "account_tier":
		return "\"Standard\""
	case "account_replication_type":
		return "\"LRS\""
	case "sku_name", "sku":
		return "\"Standard\""
	case "os_type":
		return "\"Linux\""
	case "address_space":
		return "[\"10.0.0.0/16\"]"
	case "address_prefixes":
		return "[\"10.0.1.0/24\"]"

	// Azure-specific resource references (no quotes)
	case "tenant_id":
		return "data.azurerm_client_config.current.tenant_id"
	case "service_plan_id":
		return "azurerm_service_plan.example.id"
	case "app_service_plan_id":
		return "azurerm_app_service_plan.example.id"
	case "subnet_id":
		return "azurerm_subnet.example.id"
	case "virtual_network_id":
		return "azurerm_virtual_network.example.id"
	case "network_security_group_id":
		return "azurerm_network_security_group.example.id"
	case "public_ip_address_id":
		return "azurerm_public_ip.example.id"
	case "key_vault_id":
		return "azurerm_key_vault.example.id"
	case "storage_account_id":
		return "azurerm_storage_account.example.id"
	case "log_analytics_workspace_id":
		return "azurerm_log_analytics_workspace.example.id"

	// Common attribute patterns
	case "administrator_login":
		return "\"sqladmin\""
	case "administrator_login_password":
		return "\"P@ssw0rd1234!\""
	case "version":
		return "\"12.0\""
	case "enable_https_traffic_only":
		return "true"
	case "min_tls_version":
		return "\"TLS1_2\""
	case "https_only":
		return "true"
	case "client_affinity_enabled":
		return "false"
	case "purge_protection_enabled":
		return "false"
	case "soft_delete_retention_days":
		return "7"
	case "enabled_for_deployment":
		return "false"
	case "enabled_for_disk_encryption":
		return "false"
	case "enabled_for_template_deployment":
		return "false"
	case "enable_rbac_authorization":
		return "true"
	}

	// Check if attribute looks like a resource ID reference
	if strings.HasSuffix(attr.Name, "_id") && !strings.Contains(attr.Name, "tenant") {
		// Generate a resource reference without quotes
		resourceType := strings.TrimSuffix(attr.Name, "_id")
		return fmt.Sprintf("azurerm_%s.example.id", resourceType)
	}

	// Type-based defaults
	switch attr.TFType {
	case "string":
		// Check if it looks like a name field
		if strings.Contains(attr.Name, "name") {
			return fmt.Sprintf("\"example-%s\"", strings.ReplaceAll(attr.Name, "_", "-"))
		}
		// Check for version fields
		if strings.Contains(attr.Name, "version") {
			return "\"1.0\""
		}
		return "\"example-value\""
	case "bool":
		return "true"
	case "number":
		return "1"
	default:
		// List or complex types
		if strings.HasPrefix(attr.TFType, "list(") {
			return "[]"
		}
		if strings.HasPrefix(attr.TFType, "map(") {
			return "{}"
		}
		if strings.HasPrefix(attr.TFType, "set(") {
			return "[]"
		}
		return "null"
	}
}

// generateExampleBlock creates an example configuration for a required block
// Single blocks use object syntax, multi-value blocks use map of objects with named keys
func generateExampleBlock(block schema.ParsedBlock) string {
	var b strings.Builder

	// Check if this is a single block or multi-value block
	isSingle := isSingleBlock(block)

	// Create a map key for multi-value blocks
	mapKey := fmt.Sprintf("%s-1", block.Name)

	// Special handling for known Azure block patterns
	switch block.Name {
	case "monitor_config":
		b.WriteString("  monitor_config = {\n")
		b.WriteString("    monitor-config-1 = {\n")
		b.WriteString("      protocol                     = \"HTTP\"\n")
		b.WriteString("      port                         = 80\n")
		b.WriteString("      path                         = \"/\"\n")
		b.WriteString("      interval_in_seconds          = 30\n")
		b.WriteString("      timeout_in_seconds           = 10\n")
		b.WriteString("      tolerated_number_of_failures = 3\n")
		b.WriteString("    }\n")
		b.WriteString("  }\n")
		return b.String()

	case "dns_config":
		b.WriteString("  dns_config = {\n")
		b.WriteString("    dns-config-1 = {\n")
		b.WriteString("      relative_name = \"example-traffic-manager\"\n")
		b.WriteString("      ttl           = 60\n")
		b.WriteString("    }\n")
		b.WriteString("  }\n")
		return b.String()

	case "ip_configuration":
		b.WriteString("  ip_configuration = {\n")
		b.WriteString("    ip-configuration-1 = {\n")
		b.WriteString("      name                 = \"example-ip-config\"\n")
		b.WriteString("      subnet_id            = azurerm_subnet.example.id\n")
		b.WriteString("      public_ip_address_id = azurerm_public_ip.example.id\n")
		b.WriteString("    }\n")
		b.WriteString("  }\n")
		return b.String()

	case "identity":
		b.WriteString("  identity = {\n")
		b.WriteString("    identity-1 = {\n")
		b.WriteString("      type = \"SystemAssigned\"\n")
		b.WriteString("    }\n")
		b.WriteString("  }\n")
		return b.String()

	case "site_config":
		b.WriteString("  site_config = {\n")
		b.WriteString("    site-config-1 = {\n")
		b.WriteString("      always_on = true\n")
		b.WriteString("    }\n")
		b.WriteString("  }\n")
		return b.String()
	}

	// Generic block generation
	if isSingle {
		// Single block: use object syntax
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))

		// Add block attributes with smart defaults
		for _, attr := range block.Attributes {
			if attr.Required {
				tempAttr := schema.ParsedAttribute{
					Name:        attr.Name,
					Description: attr.Description,
					TFType:      attr.TFType,
					Required:    attr.Required,
					Optional:    attr.Optional,
					Computed:    attr.Computed,
					Sensitive:   attr.Sensitive,
					EnumValues:  []string{},
				}
				exampleValue := generateExampleValue(tempAttr)
				padding := strings.Repeat(" ", max(0, 25-len(attr.Name)))
				b.WriteString(fmt.Sprintf("    %s%s = %s\n", attr.Name, padding, exampleValue))
			}
		}

		// If no required attributes, add a comment
		hasRequired := false
		for _, attr := range block.Attributes {
			if attr.Required {
				hasRequired = true
				break
			}
		}
		if !hasRequired {
			b.WriteString(fmt.Sprintf("    # Configure %s attributes\n", block.Name))
		}

		b.WriteString("  }\n")
	} else {
		// Multi-value block: use map of objects syntax
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))
		b.WriteString(fmt.Sprintf("    %s = {\n", mapKey))

		// Add block attributes with smart defaults
		for _, attr := range block.Attributes {
			if attr.Required {
				tempAttr := schema.ParsedAttribute{
					Name:        attr.Name,
					Description: attr.Description,
					TFType:      attr.TFType,
					Required:    attr.Required,
					Optional:    attr.Optional,
					Computed:    attr.Computed,
					Sensitive:   attr.Sensitive,
					EnumValues:  []string{},
				}
				exampleValue := generateExampleValue(tempAttr)
				padding := strings.Repeat(" ", max(0, 25-len(attr.Name)))
				b.WriteString(fmt.Sprintf("      %s%s = %s\n", attr.Name, padding, exampleValue))
			}
		}

		// If no required attributes, add a comment
		hasRequired := false
		for _, attr := range block.Attributes {
			if attr.Required {
				hasRequired = true
				break
			}
		}
		if !hasRequired {
			b.WriteString(fmt.Sprintf("      # Configure %s attributes\n", block.Name))
		}

		b.WriteString("    }\n")
		b.WriteString("  }\n")
	}

	return b.String()
}

// max returns the maximum of two integers
func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

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

	// Always include location and resource_group_name (handled specially)
	b.WriteString(fmt.Sprintf("  %-27s = %s\n", "location", "\"East US 2\""))
	b.WriteString(fmt.Sprintf("  %-27s = %s\n", "resource_group_name", "\"eits-Sandbox-mspsandbox-BU-07959a-rg\""))

	// Dynamically include ALL required attributes with sensible defaults
	// Skip standard variables that are handled specially in the module
	hasRequiredAttrs := false
	for _, attr := range info.Attributes {
		if attr.Required && !isStandardTestVar(attr.Name) {
			if !hasRequiredAttrs {
				b.WriteString("\n")
				hasRequiredAttrs = true
			}
			exampleValue := generateExampleValue(attr)
			b.WriteString(fmt.Sprintf("  %-27s = %s\n", attr.Name, exampleValue))
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

	// Common Azure attribute patterns
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
	}

	// Type-based defaults
	switch attr.TFType {
	case "string":
		// Check if it looks like a name field
		if strings.Contains(attr.Name, "name") {
			return fmt.Sprintf("\"example-%s\"", strings.ReplaceAll(attr.Name, "_", "-"))
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

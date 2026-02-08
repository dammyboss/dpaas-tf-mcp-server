package generators

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/templates"
)

func GenerateTests(info *schema.ResourceInfo, scenarios []string) map[string]string {
	files := map[string]string{}

	scenarioSet := map[string]bool{}
	for _, s := range scenarios {
		scenarioSet[s] = true
	}

	if scenarioSet["default"] {
		files["tests/default/main.tf"] = generateDefaultTest(info)
		files["tests/default/versions.tf"] = templates.VersionsTestTf
	}

	if scenarioSet["complete"] {
		files["tests/complete/main.tf"] = generateCompleteTest(info)
		files["tests/complete/versions.tf"] = templates.VersionsTestTf
	}

	if scenarioSet["disabled"] {
		files["tests/disabled/main.tf"] = generateDisabledTest(info)
		files["tests/disabled/versions.tf"] = templates.VersionsTestTf
	}

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
			varName := getVariableName(attr.Name, info.ShortName)
			exampleValue := generateExampleValue(attr)
			b.WriteString(fmt.Sprintf("  %-27s = %s\n", varName, exampleValue))
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

// generateCompleteTest creates a test that sets ALL attributes and blocks.
// Proves every variable the module exposes is wirable without syntax/type errors.
func generateCompleteTest(info *schema.ResourceInfo) string {
	var b strings.Builder

	moduleName := strings.ReplaceAll(info.ShortName, "_", "_")

	b.WriteString(fmt.Sprintf("module \"%s\" {\n\n", moduleName))
	b.WriteString("  source = \"../..\"\n\n")
	b.WriteString("  enabled = true\n\n")
	b.WriteString("  namespace   = \"expn\"\n")
	b.WriteString("  tenant      = \"msp\"\n")
	b.WriteString("  environment = \"sbx\"\n")
	b.WriteString("  name        = \"complete\"\n\n")

	// Resource name
	resourceNameVar := info.ShortName + "_name"
	exampleName := strings.ReplaceAll(info.ShortName, "_", "-")
	b.WriteString(fmt.Sprintf("  %-27s = \"example-%s\"\n", resourceNameVar, exampleName))

	// Add location and resource_group_name if they exist
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

	// All non-standard attributes (required + optional)
	var attrs []schema.ParsedAttribute
	for _, attr := range info.Attributes {
		if !isStandardTestVar(attr.Name) {
			attrs = append(attrs, attr)
		}
	}

	if len(attrs) > 0 {
		b.WriteString("\n  # All attributes\n")
		for _, attr := range attrs {
			varName := getVariableName(attr.Name, info.ShortName)
			exampleValue := generateExampleValue(attr)
			b.WriteString(fmt.Sprintf("  %-27s = %s\n", varName, exampleValue))
		}
	}

	// All blocks (required + optional)
	if len(info.Blocks) > 0 {
		b.WriteString("\n  # All blocks\n")
		for _, block := range info.Blocks {
			exampleBlock := generateCompleteExampleBlock(block)
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

// generateDisabledTest creates a test with enabled=false.
// Proves the module can be cleanly skipped (count=0) without errors.
func generateDisabledTest(info *schema.ResourceInfo) string {
	var b strings.Builder

	moduleName := strings.ReplaceAll(info.ShortName, "_", "_")

	b.WriteString(fmt.Sprintf("module \"%s\" {\n\n", moduleName))
	b.WriteString("  source = \"../..\"\n\n")
	b.WriteString("  enabled = false\n\n")
	b.WriteString("  namespace   = \"expn\"\n")
	b.WriteString("  tenant      = \"msp\"\n")
	b.WriteString("  environment = \"sbx\"\n")
	b.WriteString("  name        = \"disabled\"\n\n")

	// Still need to provide required variables (they have no defaults)
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

	// Required attributes (no defaults, must be provided even when disabled)
	var requiredAttrs []schema.ParsedAttribute
	for _, attr := range info.Attributes {
		if attr.Required && !isStandardTestVar(attr.Name) {
			requiredAttrs = append(requiredAttrs, attr)
		}
	}

	if len(requiredAttrs) > 0 {
		b.WriteString("\n  # Required attributes (must be provided even when disabled)\n")
		for _, attr := range requiredAttrs {
			varName := getVariableName(attr.Name, info.ShortName)
			exampleValue := generateExampleValue(attr)
			b.WriteString(fmt.Sprintf("  %-27s = %s\n", varName, exampleValue))
		}
	}

	// Required blocks (must be provided even when disabled)
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

	// Tags (required by validation even when disabled)
	b.WriteString("\n  tags = {\n")
	b.WriteString("    \"CostString\"  = \"0000.111.11.22\"\n")
	b.WriteString("    \"AppID\"       = \"0\"\n")
	b.WriteString("    \"Environment\" = \"sbx\"\n")
	b.WriteString("  }\n")
	b.WriteString("}\n")

	return b.String()
}

// generateCompleteExampleBlock generates a block with ALL attributes (required + optional),
// including nested blocks recursively.
func generateCompleteExampleBlock(block schema.ParsedBlock) string {
	var b strings.Builder

	isSingle := isSingleBlock(block)
	mapKey := fmt.Sprintf("%s-1", block.Name)

	if isSingle {
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))
		writeCompleteBlockContent(&b, block, "    ")
		b.WriteString("  }\n")
	} else {
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))
		b.WriteString(fmt.Sprintf("    %s = {\n", mapKey))
		writeCompleteBlockContent(&b, block, "      ")
		b.WriteString("    }\n")
		b.WriteString("  }\n")
	}

	return b.String()
}

// writeCompleteBlockContent writes all attributes and nested blocks at the given indent level.
func writeCompleteBlockContent(b *strings.Builder, block schema.ParsedBlock, indent string) {
	for _, attr := range block.Attributes {
		exampleValue := generateExampleValue(attr)
		padding := strings.Repeat(" ", max(0, 25-len(attr.Name)))
		b.WriteString(fmt.Sprintf("%s%s%s = %s\n", indent, attr.Name, padding, exampleValue))
	}
	for _, nested := range block.Blocks {
		b.WriteString(fmt.Sprintf("%s%s = {\n", indent, nested.Name))
		writeCompleteBlockContent(b, nested, indent+"  ")
		b.WriteString(fmt.Sprintf("%s}\n", indent))
	}
	if len(block.Attributes) == 0 && len(block.Blocks) == 0 {
		b.WriteString(fmt.Sprintf("%s# Configure %s attributes\n", indent, block.Name))
	}
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
// Fully dynamic - no hardcoded resource-specific values
func generateExampleValue(attr schema.ParsedAttribute) string {
	// Non-string types are never enums
	switch attr.TFType {
	case "bool":
		return "true"
	case "number":
		return "1"
	}

	if attr.TFType == "string" {
		// _id fields are resource references, not enums — always use Azure ID format
		if strings.HasSuffix(attr.Name, "_id") {
			return fmt.Sprintf("\"%s\"", schema.GenerateAzureResourceID(attr.Name))
		}

		// Use enum values if available (from provider docs or schema)
		if len(attr.EnumValues) > 0 {
			return fmt.Sprintf("\"%s\"", attr.EnumValues[0])
		}

		// Name fields
		if strings.Contains(attr.Name, "name") {
			return fmt.Sprintf("\"example-%s\"", strings.ReplaceAll(attr.Name, "_", "-"))
		}
		// Version fields
		if strings.Contains(attr.Name, "version") {
			return "\"1.0\""
		}
		// Password/secret fields
		if strings.Contains(attr.Name, "password") || strings.Contains(attr.Name, "secret") {
			return "\"P@ssw0rd1234!\""
		}
		return "\"example-value\""
	}

	// List or complex types
	if strings.HasPrefix(attr.TFType, "list(") || strings.HasPrefix(attr.TFType, "set(") {
		return "[]"
	}
	if strings.HasPrefix(attr.TFType, "map(") {
		return "{}"
	}
	return "null"
}

// generateExampleBlock creates an example configuration for a required block
// Single blocks use object syntax, multi-value blocks use map of objects with named keys
func generateExampleBlock(block schema.ParsedBlock) string {
	var b strings.Builder

	// Check if this is a single block or multi-value block
	isSingle := isSingleBlock(block)

	// Create a map key for multi-value blocks
	mapKey := fmt.Sprintf("%s-1", block.Name)

	// Fully dynamic block generation based on schema
	if isSingle {
		// Single block: use object syntax
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))

		hasRequired := false
		for _, attr := range block.Attributes {
			if attr.Required {
				hasRequired = true
				exampleValue := generateExampleValue(attr)
				padding := strings.Repeat(" ", max(0, 25-len(attr.Name)))
				b.WriteString(fmt.Sprintf("    %s%s = %s\n", attr.Name, padding, exampleValue))
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

		hasRequired := false
		for _, attr := range block.Attributes {
			if attr.Required {
				hasRequired = true
				exampleValue := generateExampleValue(attr)
				padding := strings.Repeat(" ", max(0, 25-len(attr.Name)))
				b.WriteString(fmt.Sprintf("      %s%s = %s\n", attr.Name, padding, exampleValue))
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

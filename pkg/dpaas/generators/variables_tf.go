package generators

import (
	"fmt"
	"sort"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/templates"
)

func GenerateVariablesTf(info *schema.ResourceInfo) string {
	var b strings.Builder

	// Part A: null-label vars up to namespace
	b.WriteString(templates.NullLabelVarsPartA)
	b.WriteString("\n")

	// create_{resource} variable (injected between parts A and B)
	b.WriteString(fmt.Sprintf("variable \"create_%s\" {\n", info.ShortName))
	b.WriteString("  type        = bool\n")
	b.WriteString(fmt.Sprintf("  description = \"Whether to create the %s.\"\n", info.DisplayName))
	b.WriteString("  default     = true\n")
	b.WriteString("}\n")

	// Part B: rest of null-label vars (tenant through tags + end marker)
	b.WriteString(templates.NullLabelVarsPartB)
	b.WriteString("\n")

	// Resource name variable
	nameVar := info.ShortName + "_name"
	b.WriteString(fmt.Sprintf("variable \"%s\" {\n", nameVar))
	b.WriteString(fmt.Sprintf("  description = \"Specifies the name of the %s\"\n", info.DisplayName))
	b.WriteString("  type        = string\n")
	b.WriteString("  default     = null\n")
	b.WriteString("}\n\n")

	// Check if resource_group_name and location exist in schema
	hasResourceGroupName := false
	hasLocation := false
	for _, attr := range info.Attributes {
		if attr.Name == "resource_group_name" {
			hasResourceGroupName = true
		}
		if attr.Name == "location" {
			hasLocation = true
		}
	}

	// Only include resource_group_name if it exists in schema
	if hasResourceGroupName {
		b.WriteString("variable \"resource_group_name\" {\n")
		b.WriteString(fmt.Sprintf("  description = \"The name of the resource group in which to create the %s\"\n", info.DisplayName))
		b.WriteString("  type        = string\n")
		b.WriteString("}\n\n")
	}

	// Only include location if it exists in schema
	if hasLocation {
		b.WriteString("variable \"location\" {\n")
		b.WriteString("  description = \"Specifies the supported Azure location where the resource exists\"\n")
		b.WriteString("  type        = string\n")
		b.WriteString("}\n\n")
	}

	// Other required attributes (excluding standard ones)
	for _, attr := range info.Attributes {
		if isStandardVar(attr.Name) || !attr.Required {
			continue
		}
		writeVariable(&b, attr, info)
	}

	// Optional attributes
	for _, attr := range info.Attributes {
		if isStandardVar(attr.Name) || attr.Required {
			continue
		}
		writeVariable(&b, attr, info)
	}

	// Block variables
	for _, block := range info.Blocks {
		writeBlockVariable(&b, block)
	}

	return b.String()
}

func writeVariable(b *strings.Builder, attr schema.ParsedAttribute, info *schema.ResourceInfo) {
	b.WriteString(fmt.Sprintf("variable \"%s\" {\n", attr.Name))

	desc := attr.Description
	if desc == "" {
		desc = fmt.Sprintf("The %s attribute", strings.ReplaceAll(attr.Name, "_", " "))
	}
	desc = escapeDescription(desc)
	b.WriteString(fmt.Sprintf("  description = \"%s\"\n", desc))
	b.WriteString(fmt.Sprintf("  type        = %s\n", attr.TFType))

	if !attr.Required {
		b.WriteString("  default     = null\n")
	}

	// Validation block for enum values
	if len(attr.EnumValues) > 0 && len(attr.EnumValues) < 20 {
		b.WriteString("  validation {\n")
		b.WriteString(fmt.Sprintf("    condition = var.%s == null || contains(%s, var.%s)\n", attr.Name, formatEnumList(attr.EnumValues), attr.Name))
		b.WriteString(fmt.Sprintf("    error_message = \"%s must be one of: %s.\"\n", attr.Name, strings.Join(attr.EnumValues, ", ")))
		b.WriteString("  }\n")
	}

	if attr.Sensitive {
		b.WriteString("  sensitive   = true\n")
	}

	b.WriteString("}\n\n")
}

func writeBlockVariable(b *strings.Builder, block schema.ParsedBlock) {
	b.WriteString(fmt.Sprintf("variable \"%s\" {\n", block.Name))
	b.WriteString(fmt.Sprintf("  description = \"%s block configuration\"\n", strings.ReplaceAll(block.Name, "_", " ")))

	typeExpr := blockToTypeExpr(block, "  ")
	b.WriteString(fmt.Sprintf("  type        = %s\n", typeExpr))

	if !block.Required {
		if isSingleBlock(block) {
			b.WriteString("  default     = null\n")
		} else {
			b.WriteString("  default     = {}\n")
		}
	}

	b.WriteString("}\n\n")
}

func blockToTypeExpr(block schema.ParsedBlock, baseIndent string) string {
	objType := blockToObjectType(block, baseIndent)

	if isSingleBlock(block) {
		return objType
	}

	// Always use map for multi-value blocks per DPaaS standard
	// This allows for named keys and easier override patterns
	return "map(" + objType + ")"
}

func blockToObjectType(block schema.ParsedBlock, baseIndent string) string {
	inner := baseIndent + "  "
	var parts []string

	// Sort attributes for consistent output
	sortedAttrs := make([]schema.ParsedAttribute, len(block.Attributes))
	copy(sortedAttrs, block.Attributes)
	sort.Slice(sortedAttrs, func(i, j int) bool {
		return sortedAttrs[i].Name < sortedAttrs[j].Name
	})

	for _, attr := range sortedAttrs {
		if attr.Required {
			parts = append(parts, fmt.Sprintf("%s%s = %s", inner, attr.Name, attr.TFType))
		} else {
			parts = append(parts, fmt.Sprintf("%s%s = optional(%s)", inner, attr.Name, attr.TFType))
		}
	}

	// Sort blocks for consistent output
	sortedBlocks := make([]schema.ParsedBlock, len(block.Blocks))
	copy(sortedBlocks, block.Blocks)
	sort.Slice(sortedBlocks, func(i, j int) bool {
		return sortedBlocks[i].Name < sortedBlocks[j].Name
	})

	for _, nested := range sortedBlocks {
		nestedType := blockToTypeExpr(nested, inner)
		if nested.Required {
			parts = append(parts, fmt.Sprintf("%s%s = %s", inner, nested.Name, nestedType))
		} else {
			parts = append(parts, fmt.Sprintf("%s%s = optional(%s)", inner, nested.Name, nestedType))
		}
	}

	if len(parts) == 0 {
		return "object({})"
	}

	return "object({\n" + strings.Join(parts, "\n") + "\n" + baseIndent + "})"
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func isStandardVar(name string) bool {
	return name == "name" || name == "location" || name == "resource_group_name" || name == "tags" || name == "id"
}

func escapeDescription(s string) string {
	s = strings.ReplaceAll(s, "\"", "\\\"")
	s = strings.ReplaceAll(s, "\n", " ")
	s = strings.ReplaceAll(s, "\r", "")
	if len(s) > 200 {
		s = s[:197] + "..."
	}
	return s
}

func formatEnumList(vals []string) string {
	quoted := make([]string, len(vals))
	for i, v := range vals {
		quoted[i] = fmt.Sprintf("\"%s\"", v)
	}
	return "[" + strings.Join(quoted, ", ") + "]"
}

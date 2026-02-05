package generators

import (
	"fmt"
	"sort"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/templates"
)

// nullLabelReservedVars contains variable names defined by null-label
// that should not be overwritten by resource attributes
var nullLabelReservedVars = map[string]bool{
	"context": true, "enabled": true, "namespace": true,
	"tenant": true, "environment": true, "stage": true,
	"name": true, "delimiter": true, "attributes": true,
	"labels_as_tags": true, "additional_tag_map": true,
	"label_order": true, "regex_replace_chars": true,
	"id_length_limit": true, "label_key_case": true,
	"label_value_case": true, "descriptor_formats": true,
	"tags": true,
}

// getVariableName returns the variable name for an attribute,
// prefixing with resource short name if it conflicts with null-label
func getVariableName(attrName string, shortName string) string {
	if nullLabelReservedVars[attrName] && !isStandardVar(attrName) {
		return shortName + "_" + attrName
	}
	return attrName
}

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
	varName := getVariableName(attr.Name, info.ShortName)
	b.WriteString(fmt.Sprintf("variable \"%s\" {\n", varName))

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

	// Validation block for enum-valued string attributes
	if attr.TFType == "string" && len(attr.EnumValues) > 0 && len(attr.EnumValues) < 20 {
		b.WriteString("  validation {\n")
		b.WriteString(fmt.Sprintf("    condition = var.%s == null || contains(%s, var.%s)\n", varName, formatEnumList(attr.EnumValues), varName))
		b.WriteString(fmt.Sprintf("    error_message = \"%s must be one of: %s.\"\n", varName, strings.Join(attr.EnumValues, ", ")))
		b.WriteString("  }\n")
	}

	if attr.Sensitive {
		b.WriteString("  sensitive   = true\n")
	}

	b.WriteString("}\n\n")
}

func writeBlockVariable(b *strings.Builder, block schema.ParsedBlock) {
	b.WriteString(fmt.Sprintf("variable \"%s\" {\n", block.Name))

	typeExpr := blockToTypeExpr(block, "  ")
	b.WriteString(fmt.Sprintf("  type        = %s\n", typeExpr))

	if !block.Required {
		if isSingleBlock(block) {
			b.WriteString("  default     = null\n")
		} else {
			b.WriteString("  default     = {}\n")
		}
	}

	// Heredoc description listing all attributes and nested blocks
	b.WriteString("  description = <<-DESCRIPTION\n")
	writeBlockDescriptionLines(b, block, "  ")
	b.WriteString("  DESCRIPTION\n")

	// Validation blocks for enum-valued string attributes
	writeBlockValidations(b, block)

	b.WriteString("}\n\n")
}

// writeBlockDescriptionLines writes a structured description for a block variable,
// recursively documenting nested blocks with --- separators and indentation.
func writeBlockDescriptionLines(b *strings.Builder, block schema.ParsedBlock, indent string) {
	// Sorted attributes for stable output
	sortedAttrs := make([]schema.ParsedAttribute, len(block.Attributes))
	copy(sortedAttrs, block.Attributes)
	sort.Slice(sortedAttrs, func(i, j int) bool {
		return sortedAttrs[i].Name < sortedAttrs[j].Name
	})

	for _, attr := range sortedAttrs {
		b.WriteString(fmt.Sprintf("%s- `%s` - %s\n", indent, attr.Name, attrDescription(attr)))
	}

	// Nested blocks with --- separator
	sortedBlocks := make([]schema.ParsedBlock, len(block.Blocks))
	copy(sortedBlocks, block.Blocks)
	sort.Slice(sortedBlocks, func(i, j int) bool {
		return sortedBlocks[i].Name < sortedBlocks[j].Name
	})

	for _, nested := range sortedBlocks {
		b.WriteString("\n")
		b.WriteString(indent + "---\n")
		b.WriteString(fmt.Sprintf("%s`%s` block supports the following:\n", indent, nested.Name))
		writeBlockDescriptionLines(b, nested, indent+"  ")
	}
}

// attrDescription returns the docs description if available, otherwise a generated fallback.
func attrDescription(attr schema.ParsedAttribute) string {
	if attr.Description != "" {
		return attr.Description
	}
	req := "Optional"
	if attr.Required {
		req = "Required"
	}
	return fmt.Sprintf("(%s) The %s value.", req, strings.ReplaceAll(attr.Name, "_", " "))
}

// writeBlockValidations emits validation blocks for string attributes that have
// known enum values. Single blocks use direct property access; map blocks use
// an alltrue([for ...]) comprehension.
func writeBlockValidations(b *strings.Builder, block schema.ParsedBlock) {
	isSingle := isSingleBlock(block)

	for _, attr := range block.Attributes {
		if attr.TFType != "string" || len(attr.EnumValues) == 0 || len(attr.EnumValues) >= 20 {
			continue
		}

		enumList := formatEnumList(attr.EnumValues)
		qualifiedName := block.Name + "." + attr.Name

		b.WriteString("  validation {\n")
		if isSingle {
			if block.Required && attr.Required {
				b.WriteString(fmt.Sprintf("    condition     = contains(%s, var.%s.%s)\n", enumList, block.Name, attr.Name))
			} else if block.Required && !attr.Required {
				b.WriteString(fmt.Sprintf("    condition     = var.%s.%s == null || contains(%s, var.%s.%s)\n", block.Name, attr.Name, enumList, block.Name, attr.Name))
			} else {
				b.WriteString(fmt.Sprintf("    condition     = var.%s == null || contains(%s, var.%s.%s)\n", block.Name, enumList, block.Name, attr.Name))
			}
		} else {
			// map(object) — alltrue over the map; handles empty map (alltrue([]) == true)
			check := fmt.Sprintf("contains(%s, v.%s)", enumList, attr.Name)
			if !attr.Required {
				check = fmt.Sprintf("v.%s == null || %s", attr.Name, check)
			}
			b.WriteString(fmt.Sprintf("    condition     = alltrue([for k, v in var.%s : %s])\n", block.Name, check))
		}
		b.WriteString(fmt.Sprintf("    error_message = \"%s must be one of: %s.\"\n", qualifiedName, strings.Join(attr.EnumValues, ", ")))
		b.WriteString("  }\n")
	}
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

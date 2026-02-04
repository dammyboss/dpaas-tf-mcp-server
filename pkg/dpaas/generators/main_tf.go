package generators

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
)

func GenerateMainTf(info *schema.ResourceInfo) string {
	var b strings.Builder

	nameVar := info.ShortName + "_name"

	b.WriteString(fmt.Sprintf("resource \"%s\" \"this\" {\n", info.ResourceType))
	b.WriteString("  count               = local.enabled ? 1 : 0\n\n")
	b.WriteString(fmt.Sprintf("  name                = var.%s != null ? var.%s : module.this.id\n", nameVar, nameVar))
	b.WriteString("  location            = var.location\n")
	b.WriteString("  resource_group_name = var.resource_group_name\n")

	// Collect attrs excluding standard ones
	var otherAttrs []schema.ParsedAttribute
	for _, attr := range info.Attributes {
		if attr.Name == "location" || attr.Name == "resource_group_name" || attr.Name == "name" || attr.Name == "tags" {
			continue
		}
		otherAttrs = append(otherAttrs, attr)
	}

	if len(otherAttrs) > 0 {
		b.WriteString("\n")
		maxLen := 0
		for _, a := range otherAttrs {
			if len(a.Name) > maxLen {
				maxLen = len(a.Name)
			}
		}

		for _, a := range otherAttrs {
			padding := strings.Repeat(" ", maxLen-len(a.Name))
			if a.Required {
				b.WriteString(fmt.Sprintf("  %s%s = var.%s\n", a.Name, padding, a.Name))
			} else {
				b.WriteString(fmt.Sprintf("  %s%s = try(var.%s, null)\n", a.Name, padding, a.Name))
			}
		}
	}

	b.WriteString("  tags                = local.tags\n")

	// Dynamic blocks
	if len(info.Blocks) > 0 {
		b.WriteString("\n")
		for _, block := range info.Blocks {
			writeTopLevelDynamicBlock(&b, block)
		}
	}

	b.WriteString("}\n")
	return b.String()
}

func writeTopLevelDynamicBlock(b *strings.Builder, block schema.ParsedBlock) {
	varRef := "var." + block.Name

	b.WriteString(fmt.Sprintf("  dynamic \"%s\" {\n", block.Name))

	if isSingleBlock(block) {
		b.WriteString(fmt.Sprintf("    for_each = %s != null ? [%s] : []\n", varRef, varRef))
	} else {
		b.WriteString(fmt.Sprintf("    for_each = %s != null ? %s : []\n", varRef, varRef))
	}

	b.WriteString("    content {\n")
	writeBlockContent(b, block, block.Name, "      ")
	b.WriteString("    }\n")
	b.WriteString("  }\n")
}

func writeBlockContent(b *strings.Builder, block schema.ParsedBlock, iterVar string, indent string) {
	for _, attr := range block.Attributes {
		b.WriteString(fmt.Sprintf("%s%s = %s.value.%s\n", indent, attr.Name, iterVar, attr.Name))
	}

	for _, nested := range block.Blocks {
		nestedRef := iterVar + ".value." + nested.Name

		b.WriteString(fmt.Sprintf("%s\n", ""))
		b.WriteString(fmt.Sprintf("%sdynamic \"%s\" {\n", indent, nested.Name))

		if isSingleBlock(nested) {
			b.WriteString(fmt.Sprintf("%s  for_each = %s != null ? [%s] : []\n", indent, nestedRef, nestedRef))
		} else {
			b.WriteString(fmt.Sprintf("%s  for_each = %s != null ? %s : []\n", indent, nestedRef, nestedRef))
		}

		b.WriteString(fmt.Sprintf("%s  content {\n", indent))
		writeBlockContent(b, nested, nested.Name, indent+"    ")
		b.WriteString(fmt.Sprintf("%s  }\n", indent))
		b.WriteString(fmt.Sprintf("%s}\n", indent))
	}
}

func isSingleBlock(block schema.ParsedBlock) bool {
	return block.NestingMode == "single" || block.NestingMode == "group" || (block.NestingMode == "list" && block.MaxItems == 1)
}

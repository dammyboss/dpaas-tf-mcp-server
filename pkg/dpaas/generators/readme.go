package generators

import (
	"fmt"
	"sort"
	"strings"
	"time"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
)

func GenerateReadme(info *schema.ResourceInfo) string {
	var b strings.Builder

	b.WriteString(fmt.Sprintf("# EITS Cloud Enablement Azure %s Module\n\n", info.DisplayName))
	b.WriteString(fmt.Sprintf("EITS Terraform module which creates [Azure %s] resources. This module will:\n\n", info.DisplayName))
	b.WriteString(fmt.Sprintf("- Deploy Azure %s with configurable options\n", info.DisplayName))
	b.WriteString("- Support both custom naming and auto-generated names using null-label\n")
	b.WriteString("- Apply standardized tagging and security policies\n")
	b.WriteString("- Support conditional resource creation\n\n")
	b.WriteString("See CHANGELOG.md for the list of changes for each release.\n")
	b.WriteString("*We highly recommend that in your code you pin the version to the exact version you are using so that your infrastructure remains stable, and update versions in a systematic way so that they do not catch you by surprise.*\n\n")

	b.WriteString("## Notes\n\n")
	b.WriteString(fmt.Sprintf("- Null-label naming convention support for standardized resource names\n"))
	b.WriteString(fmt.Sprintf("- Conditional resource creation using `create_%s` parameter\n", info.ShortName))
	b.WriteString("- Standardized DPaaS tagging applied automatically\n\n")

	// Security section
	b.WriteString("## EITS Security & Compliance\n\n")
	b.WriteString("**Last Module Review**: " + time.Now().Format("2006-01-02") + "\n\n")
	b.WriteString("See below for the date and results of our EITS security and compliance scanning.\n\n")
	b.WriteString("<!-- BEGIN_BENCHMARK_TABLE -->\n")
	b.WriteString("<!-- END_BENCHMARK_TABLE -->\n\n")

	// Usage section
	b.WriteString("## Usage\n\n")
	b.WriteString("```hcl\n")
	b.WriteString(generateUsageExample(info))
	b.WriteString("```\n\n")

	// Terraform-docs style documentation
	writeRequirements(&b)
	writeProviders(&b)
	writeInputs(&b, info)
	writeOutputs(&b, info)

	// Contact
	b.WriteString("## Contact\n\n")
	b.WriteString("For advice or to report an issue, either email the EITS Cloud Enablement team <eitsukicloud@experian.com> or post in the [Terraform Modules Teams Channel](https://teams.microsoft.com/l/channel/19%3a8c4faa258cd54d2687caa746f71ae050%40thread.tacv2/Terraform%2520Modules?groupId=c08d819b-fd4a-44e1-98f1-225d1bb48b31&tenantId=be67623c-1932-42a6-9d24-6c359fe5ea71)\n\n")

	// Acknowledgments
	b.WriteString("## Acknowledgments\n\n")
	b.WriteString("Thanks to the Data Platform and Analytics team for the module development. This module follows EITS cloud enablement standards and best practices.\n\n")

	// tf-docs section
	b.WriteString("<!-- BEGIN_TF_DOCS -->\n")
	b.WriteString("<!-- END_TF_DOCS -->\n")

	return b.String()
}

// writeRequirements writes the Requirements section.
func writeRequirements(b *strings.Builder) {
	b.WriteString("## Requirements\n\n")
	b.WriteString("| Name | Version |\n")
	b.WriteString("|------|------|\n")
	b.WriteString("| terraform | >= 1.9, < 2.0 |\n")
	b.WriteString("| azurerm | >= 4.14.0 |\n\n")
}

// writeProviders writes the Providers section.
func writeProviders(b *strings.Builder) {
	b.WriteString("## Providers\n\n")
	b.WriteString("| Name | Version |\n")
	b.WriteString("|------|------|\n")
	b.WriteString("| azurerm | >= 4.14.0 |\n\n")
}

// writeInputs writes the Inputs table with all module variables.
func writeInputs(b *strings.Builder, info *schema.ResourceInfo) {
	b.WriteString("## Inputs\n\n")
	b.WriteString("| Name | Description | Type | Default | Required |\n")
	b.WriteString("|------|-------------|------|---------|----------|\n")

	// DPaaS standard variables first
	b.WriteString(fmt.Sprintf("| create\\_%s | Whether to create the %s. | `bool` | `true` | no |\n", info.ShortName, info.DisplayName))
	b.WriteString("| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |\n")
	b.WriteString("| namespace | Namespace for naming convention (e.g. expn). | `string` | n/a | yes |\n")
	b.WriteString("| tenant | Tenant for naming convention (e.g. msp). | `string` | n/a | yes |\n")
	b.WriteString("| environment | Environment for naming convention (e.g. sbx, dev, prd). | `string` | n/a | yes |\n")
	b.WriteString("| name | Name for naming convention. | `string` | n/a | yes |\n")

	// Resource name variable
	resourceNameVar := info.ShortName + "_name"
	b.WriteString(fmt.Sprintf("| %s | Custom name for the %s. If not set, name is auto-generated using null-label. | `string` | `null` | no |\n", resourceNameVar, info.DisplayName))

	// Resource attributes (sorted)
	sortedAttrs := make([]schema.ParsedAttribute, len(info.Attributes))
	copy(sortedAttrs, info.Attributes)
	sort.Slice(sortedAttrs, func(i, j int) bool {
		return sortedAttrs[i].Name < sortedAttrs[j].Name
	})

	for _, attr := range sortedAttrs {
		if isStandardVar(attr.Name) {
			continue
		}
		varName := getVariableName(attr.Name, info.ShortName)
		desc := truncateDescription(attr.Description, 80)
		if desc == "" {
			desc = fmt.Sprintf("The %s of the %s.", strings.ReplaceAll(attr.Name, "_", " "), info.DisplayName)
		}
		tfType := formatTypeForTable(attr.TFType)
		def := "`null`"
		req := "no"
		if attr.Required {
			def = "n/a"
			req = "yes"
		}
		b.WriteString(fmt.Sprintf("| %s | %s | %s | %s | %s |\n", varName, desc, tfType, def, req))
	}

	// Block variables (sorted)
	sortedBlocks := make([]schema.ParsedBlock, len(info.Blocks))
	copy(sortedBlocks, info.Blocks)
	sort.Slice(sortedBlocks, func(i, j int) bool {
		return sortedBlocks[i].Name < sortedBlocks[j].Name
	})

	for _, block := range sortedBlocks {
		desc := fmt.Sprintf("Configuration block for %s.", strings.ReplaceAll(block.Name, "_", " "))
		typeName := "`object({...})`"
		if !isSingleBlock(block) {
			typeName = "`map(object({...}))`"
		}
		def := "`null`"
		req := "no"
		if block.Required {
			if isSingleBlock(block) {
				def = "n/a"
			} else {
				def = "`{}`"
			}
			req = "yes"
		} else {
			if isSingleBlock(block) {
				def = "`null`"
			} else {
				def = "`{}`"
			}
		}
		b.WriteString(fmt.Sprintf("| %s | %s | %s | %s | %s |\n", block.Name, desc, typeName, def, req))
	}

	b.WriteString("| tags | Additional tags to apply to the resource. | `map(string)` | `{}` | no |\n")
	b.WriteString("\n")
}

// writeOutputs writes the Outputs table.
func writeOutputs(b *strings.Builder, info *schema.ResourceInfo) {
	b.WriteString("## Outputs\n\n")
	b.WriteString("| Name | Description |\n")
	b.WriteString("|------|-------------|\n")
	b.WriteString(fmt.Sprintf("| id | The ID of the %s. |\n", info.DisplayName))

	for _, name := range info.ComputedOnlyAttrs {
		displayName := strings.ReplaceAll(name, "_", " ")
		b.WriteString(fmt.Sprintf("| %s | The %s of the %s. |\n", name, displayName, info.DisplayName))
	}

	b.WriteString("\n")
}

// truncateDescription shortens a description for the table.
func truncateDescription(s string, maxLen int) string {
	s = strings.ReplaceAll(s, "\n", " ")
	s = strings.ReplaceAll(s, "\r", "")
	s = strings.ReplaceAll(s, "|", "/")
	if len(s) > maxLen {
		s = s[:maxLen-3] + "..."
	}
	return s
}

// formatTypeForTable formats a Terraform type expression for the markdown table.
func formatTypeForTable(tfType string) string {
	if strings.HasPrefix(tfType, "list(") || strings.HasPrefix(tfType, "set(") || strings.HasPrefix(tfType, "map(") {
		return fmt.Sprintf("`%s`", tfType)
	}
	return fmt.Sprintf("`%s`", tfType)
}

func generateUsageExample(info *schema.ResourceInfo) string {
	var b strings.Builder

	moduleName := strings.ReplaceAll(info.ShortName, "_", "_")

	b.WriteString(fmt.Sprintf("module \"%s\" {\n", moduleName))
	b.WriteString(fmt.Sprintf("  source = \"git::https://code.experian.local/scm/DPAAS/%s.git\"\n\n", info.ModuleName))
	b.WriteString(fmt.Sprintf("  create_%s = true\n", info.ShortName))
	b.WriteString("  enabled            = true\n\n")
	b.WriteString("  namespace   = \"expn\"\n")
	b.WriteString("  tenant      = \"msp\"\n")
	b.WriteString("  environment = \"sbx\"\n")
	b.WriteString("  name        = \"sample\"\n\n")
	b.WriteString("  location            = \"East US 2\"\n")
	b.WriteString("  resource_group_name = \"example-rg\"\n\n")
	b.WriteString("  tags = {\n")
	b.WriteString("    CostString  = \"0000.111.11.22\"\n")
	b.WriteString("    AppID       = \"0\"\n")
	b.WriteString("    Environment = \"sbx\"\n")
	b.WriteString("  }\n")
	b.WriteString("}\n")

	return b.String()
}

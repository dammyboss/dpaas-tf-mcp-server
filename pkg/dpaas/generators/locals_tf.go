package generators

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
)

func GenerateLocalsTf(info *schema.ResourceInfo) string {
	var b strings.Builder

	b.WriteString(`# Helper locals to make the dynamic block more readable
# There are three attributes here to cater for resources that
locals {

`)
	b.WriteString(fmt.Sprintf("  dpaas_tags = {\n"))
	b.WriteString(fmt.Sprintf("    \"innersource\"      = \"DPaaS\"\n"))
	b.WriteString(fmt.Sprintf("    \"innersource-repo\" = \"git::https://code.experian.local/scm/DPAAS/%s.git//\"\n", info.ModuleName))
	b.WriteString(fmt.Sprintf("  }\n\n"))
	b.WriteString(fmt.Sprintf("  tags = merge(try(var.tags, {}), local.dpaas_tags)\n\n"))
	b.WriteString(fmt.Sprintf("  enabled = module.this.enabled && var.create_%s\n", info.ShortName))

	// Add resource_name local for resources with naming restrictions
	rule := GetNamingRule(info.ResourceType)
	if rule != nil {
		b.WriteString(fmt.Sprintf("\n  # Azure naming restriction: lowercase letters and numbers only, max %d characters\n", rule.MaxLength))
		b.WriteString(fmt.Sprintf("  resource_name = substr(replace(lower(module.this.id), \"/[^a-z0-9]/\", \"\"), 0, %d)\n", rule.MaxLength))
	}

	b.WriteString("\n}\n")

	return b.String()
}

package generators

import (
	"fmt"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
)

func GenerateLocalsTf(info *schema.ResourceInfo) string {
	return fmt.Sprintf(`# Helper locals to make the dynamic block more readable
# There are three attributes here to cater for resources that
locals {

  dpaas_tags = {
    "innersource"      = "DPaaS"
    "innersource-repo" = "git::https://code.experian.local/scm/DPAAS/%s.git//"
  }

  tags = merge(try(var.tags, {}), local.dpaas_tags)

  enabled = module.this.enabled && var.create_%s

}
`, info.ModuleName, info.ShortName)
}

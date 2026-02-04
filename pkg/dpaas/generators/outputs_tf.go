package generators

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
)

func GenerateOutputsTf(info *schema.ResourceInfo) string {
	var b strings.Builder

	b.WriteString("# outputs.tf\n")
	b.WriteString(fmt.Sprintf("output \"id\" {\n"))
	b.WriteString(fmt.Sprintf("  description = \"The ID of the %s\"\n", info.DisplayName))
	b.WriteString(fmt.Sprintf("  value       = %s.this\n", info.ResourceType))
	b.WriteString("}\n")

	// Computed-only attributes
	for _, name := range info.ComputedOnlyAttrs {
		displayName := strings.ReplaceAll(name, "_", " ")
		b.WriteString("\n")
		b.WriteString(fmt.Sprintf("output \"%s\" {\n", name))
		b.WriteString(fmt.Sprintf("  description = \"The %s of the %s\"\n", displayName, info.DisplayName))
		b.WriteString(fmt.Sprintf("  value       = %s.this[*].%s\n", info.ResourceType, name))
		b.WriteString("}\n")
	}

	return b.String()
}

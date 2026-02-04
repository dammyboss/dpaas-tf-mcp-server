package tools

import (
	"context"
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
	log "github.com/sirupsen/logrus"
)

// DPaaSListResources registers the dpaas_list_azure_resources tool.
func DPaaSListResources(logger *log.Logger) server.ServerTool {
	return server.ServerTool{
		Tool: mcp.NewTool("dpaas_list_azure_resources",
			mcp.WithDescription("List all available Azure resource types from the azurerm provider that can be used to generate DPaaS innersource modules. Optionally filter by keyword."),
			mcp.WithTitleAnnotation("DPaaS: List Azure resources"),
			mcp.WithOpenWorldHintAnnotation(true),
			mcp.WithReadOnlyHintAnnotation(true),
			mcp.WithDestructiveHintAnnotation(false),
			mcp.WithString("filter",
				mcp.Description("Optional keyword to filter resource types (e.g. 'network', 'storage', 'bastion')")),
		),
		Handler: func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
			return dpaasListResourcesHandler(ctx, request, logger)
		},
	}
}

func dpaasListResourcesHandler(_ context.Context, request mcp.CallToolRequest, logger *log.Logger) (*mcp.CallToolResult, error) {
	filter := request.GetString("filter", "")

	resources, err := schema.FetchAllResourceTypes(filter, logger)
	if err != nil {
		return DPaaSToolError(logger, "failed to fetch Azure resource types (ensure terraform is installed and on PATH)", err)
	}
	if len(resources) == 0 {
		return DPaaSToolErrorf(logger, "no Azure resources found matching filter: %q", filter)
	}

	var b strings.Builder
	b.WriteString(fmt.Sprintf("Available Azure resources (%d found):\n\n", len(resources)))
	for _, r := range resources {
		b.WriteString(fmt.Sprintf("  - %s\n", r))
	}
	b.WriteString("\nUse dpaas_generate_innersource_module with any of these resource types to generate a complete module.\n")

	return mcp.NewToolResultText(b.String()), nil
}

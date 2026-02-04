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

// DPaaSExtractSchema registers the dpaas_extract_resource_schema tool.
func DPaaSExtractSchema(logger *log.Logger) server.ServerTool {
	return server.ServerTool{
		Tool: mcp.NewTool("dpaas_extract_resource_schema",
			mcp.WithDescription("Extracts the complete schema for a specific Azure resource from the azurerm provider. Returns all arguments, nested blocks, types, and required/optional status. Use this to inspect a resource before generating a module."),
			mcp.WithTitleAnnotation("DPaaS: Extract Azure resource schema"),
			mcp.WithOpenWorldHintAnnotation(true),
			mcp.WithReadOnlyHintAnnotation(true),
			mcp.WithDestructiveHintAnnotation(false),
			mcp.WithString("resource_type",
				mcp.Required(),
				mcp.Description("The Azure resource type (e.g. 'azurerm_bastion_host', 'azurerm_virtual_network')")),
		),
		Handler: func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
			return dpaasExtractSchemaHandler(ctx, request, logger)
		},
	}
}

func dpaasExtractSchemaHandler(_ context.Context, request mcp.CallToolRequest, logger *log.Logger) (*mcp.CallToolResult, error) {
	resourceType, err := request.RequireString("resource_type")
	if err != nil {
		return DPaaSToolError(logger, "missing required input: resource_type", err)
	}
	resourceType = strings.TrimSpace(strings.ToLower(resourceType))

	if !strings.HasPrefix(resourceType, "azurerm_") {
		return DPaaSToolErrorf(logger, "resource_type must start with 'azurerm_' (got: %q)", resourceType)
	}

	info, err := schema.ExtractResourceSchema(resourceType, logger)
	if err != nil {
		return DPaaSToolError(logger, fmt.Sprintf("failed to extract schema for %s", resourceType), err)
	}

	return mcp.NewToolResultText(formatSchemaInfo(info)), nil
}

func formatSchemaInfo(info *schema.ResourceInfo) string {
	var b strings.Builder

	b.WriteString(fmt.Sprintf("Resource Schema: %s\n", info.ResourceType))
	b.WriteString(fmt.Sprintf("Module Name:     %s\n", info.ModuleName))
	b.WriteString(fmt.Sprintf("Display Name:    %s\n\n", info.DisplayName))

	b.WriteString(fmt.Sprintf("Attributes (%d):\n", len(info.Attributes)))
	for _, a := range info.Attributes {
		status := "optional"
		if a.Required {
			status = "REQUIRED"
		}
		b.WriteString(fmt.Sprintf("  %-40s %-12s %s\n", a.Name, a.TFType, status))
		if a.Description != "" {
			b.WriteString(fmt.Sprintf("  %-40s   - %s\n", "", truncate(a.Description, 100)))
		}
		if len(a.EnumValues) > 0 {
			b.WriteString(fmt.Sprintf("  %-40s   Values: %s\n", "", strings.Join(a.EnumValues, ", ")))
		}
	}

	if len(info.Blocks) > 0 {
		b.WriteString(fmt.Sprintf("\nNested Blocks (%d):\n", len(info.Blocks)))
		writeBlockSummary(&b, info.Blocks, "  ")
	}

	if len(info.ComputedOnlyAttrs) > 0 {
		b.WriteString(fmt.Sprintf("\nComputed Outputs (%d):\n", len(info.ComputedOnlyAttrs)))
		for _, name := range info.ComputedOnlyAttrs {
			b.WriteString(fmt.Sprintf("  - %s\n", name))
		}
	}

	total := len(info.Attributes) + len(info.Blocks) + len(info.ComputedOnlyAttrs)
	b.WriteString(fmt.Sprintf("\nTotal schema items: %d\n", total))

	return b.String()
}

func writeBlockSummary(b *strings.Builder, blocks []schema.ParsedBlock, indent string) {
	for _, blk := range blocks {
		req := "optional"
		if blk.Required {
			req = "REQUIRED"
		}
		b.WriteString(fmt.Sprintf("%s%s [%s, %s] -- %d attrs\n", indent, blk.Name, blk.NestingMode, req, len(blk.Attributes)))
		if len(blk.Blocks) > 0 {
			writeBlockSummary(b, blk.Blocks, indent+"  ")
		}
	}
}

func truncate(s string, max int) string {
	if len(s) <= max {
		return s
	}
	return s[:max-3] + "..."
}

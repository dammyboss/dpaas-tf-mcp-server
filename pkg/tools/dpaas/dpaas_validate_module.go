package tools

import (
	"context"
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/validation"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
	log "github.com/sirupsen/logrus"
)

// DPaaSValidateModule registers the dpaas_validate_module tool.
func DPaaSValidateModule(logger *log.Logger) server.ServerTool {
	return server.ServerTool{
		Tool: mcp.NewTool("dpaas_validate_module",
			mcp.WithDescription("Validates an existing Terraform module against DPaaS innersource standards. Checks file structure, null-label markers, count patterns, tags, argument coverage, and more."),
			mcp.WithTitleAnnotation("DPaaS: Validate module against innersource standards"),
			mcp.WithOpenWorldHintAnnotation(true),
			mcp.WithReadOnlyHintAnnotation(true),
			mcp.WithDestructiveHintAnnotation(false),
			mcp.WithString("module_path",
				mcp.Required(),
				mcp.Description("Filesystem path to the module directory to validate")),
			mcp.WithString("resource_type",
				mcp.Required(),
				mcp.Description("The Azure resource type the module targets (e.g. 'azurerm_bastion_host')")),
		),
		Handler: func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
			return dpaasValidateModuleHandler(ctx, request, logger)
		},
	}
}

func dpaasValidateModuleHandler(_ context.Context, request mcp.CallToolRequest, logger *log.Logger) (*mcp.CallToolResult, error) {
	modulePath, err := request.RequireString("module_path")
	if err != nil {
		return DPaaSToolError(logger, "missing required input: module_path", err)
	}

	resourceType, err := request.RequireString("resource_type")
	if err != nil {
		return DPaaSToolError(logger, "missing required input: resource_type", err)
	}
	resourceType = strings.TrimSpace(strings.ToLower(resourceType))

	// extract schema for coverage comparison
	info, err := schema.ExtractResourceSchema(resourceType, logger)
	if err != nil {
		return DPaaSToolError(logger, fmt.Sprintf("failed to extract schema for %s (needed for coverage check)", resourceType), err)
	}

	report, err := validation.ValidateModule(modulePath, info)
	if err != nil {
		return DPaaSToolError(logger, "validation failed", err)
	}

	return mcp.NewToolResultText(formatValidationReport(modulePath, info, report)), nil
}

func formatValidationReport(path string, info *schema.ResourceInfo, report *validation.ValidationReport) string {
	var b strings.Builder

	status := "PASSED"
	if !report.Passed {
		status = "FAILED"
	}

	b.WriteString(fmt.Sprintf("Validation Report: %s\n", path))
	b.WriteString(fmt.Sprintf("Resource Type:     %s\n", info.ResourceType))
	b.WriteString(fmt.Sprintf("Result:            %s\n\n", status))
	b.WriteString(fmt.Sprintf("Checks: %d/%d passed\n", report.PassedChecks, report.TotalChecks))

	for _, c := range report.Checks {
		symbol := "PASS"
		if !c.Passed {
			symbol = "FAIL"
		}
		line := fmt.Sprintf("  [%s] %s", symbol, c.Name)
		if !c.Passed && c.Message != "" {
			line += " -- " + c.Message
		}
		b.WriteString(line + "\n")
	}

	if cr := report.CoverageReport; cr != nil {
		b.WriteString(fmt.Sprintf("\nArgument Coverage: %.0f%%\n", cr.CoveragePercent))
		b.WriteString(fmt.Sprintf("  Attributes: %d/%d\n", cr.GeneratedAttrCount, cr.SchemaAttrCount))
		b.WriteString(fmt.Sprintf("  Blocks:     %d/%d\n", cr.GeneratedBlockCount, cr.SchemaBlockCount))
		if len(cr.MissingAttrs) > 0 {
			b.WriteString(fmt.Sprintf("  Missing attributes: %s\n", strings.Join(cr.MissingAttrs, ", ")))
		}
		if len(cr.MissingBlocks) > 0 {
			b.WriteString(fmt.Sprintf("  Missing blocks: %s\n", strings.Join(cr.MissingBlocks, ", ")))
		}
	}

	return b.String()
}

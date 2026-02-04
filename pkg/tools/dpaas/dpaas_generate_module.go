package tools

import (
	"context"
	"fmt"
	"path/filepath"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/generators"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/validation"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
	log "github.com/sirupsen/logrus"
)

// DPaaSGenerateModule registers the dpaas_generate_innersource_module tool.
func DPaaSGenerateModule(logger *log.Logger) server.ServerTool {
	return server.ServerTool{
		Tool: mcp.NewTool("dpaas_generate_innersource_module",
			mcp.WithDescription(`Generate a complete DPaaS innersource Terraform module for an Azure resource.

This tool:
1. Extracts the full resource schema from the azurerm provider
2. Generates all required files following DPaaS standards (expn-tf-azure-{resource} naming)
3. Creates test scenarios with all required attributes under tests/
4. Validates argument coverage and DPaaS standards compliance
5. Returns a full validation report

The module folder will be named following DPaaS convention: expn-tf-azure-{resource}
All arguments from the provider schema are included — nothing is hardcoded.`),
			mcp.WithTitleAnnotation("DPaaS: Generate innersource Terraform module"),
			mcp.WithOpenWorldHintAnnotation(false),
			mcp.WithReadOnlyHintAnnotation(false),
			mcp.WithDestructiveHintAnnotation(false),
			mcp.WithString("resource_type",
				mcp.Required(),
				mcp.Description("Azure resource type (e.g. 'azurerm_bastion_host', 'azurerm_virtual_network')")),
			mcp.WithString("output_path",
				mcp.Required(),
				mcp.Description("Parent directory where the module folder will be created (module will be named expn-tf-azure-{resource})")),
		),
		Handler: func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
			return dpaasGenerateModuleHandler(ctx, request, logger)
		},
	}
}

func dpaasGenerateModuleHandler(_ context.Context, request mcp.CallToolRequest, logger *log.Logger) (*mcp.CallToolResult, error) {
	resourceType, err := request.RequireString("resource_type")
	if err != nil {
		return DPaaSToolError(logger, "missing required input: resource_type", err)
	}
	resourceType = strings.TrimSpace(strings.ToLower(resourceType))
	if !strings.HasPrefix(resourceType, "azurerm_") {
		return DPaaSToolErrorf(logger, "resource_type must start with 'azurerm_'")
	}

	outputPath, err := request.RequireString("output_path")
	if err != nil {
		return DPaaSToolError(logger, "missing required input: output_path", err)
	}

	// 1. extract schema
	logger.Infof("[dpaas] extracting schema for %s", resourceType)
	info, err := schema.ExtractResourceSchema(resourceType, logger)
	if err != nil {
		return DPaaSToolError(logger, fmt.Sprintf("schema extraction failed for %s", resourceType), err)
	}

	// 2. generate all files
	logger.Infof("[dpaas] generating module files for %s", info.ModuleName)
	module := generators.GenerateModule(info)

	// 3. write to disk using the correct DPaaS module naming convention
	// The module folder should always be: expn-tf-azure-{resource}
	modulePath := filepath.Join(outputPath, info.ModuleName)
	written, err := generators.WriteModule(modulePath, module)
	if err != nil {
		return DPaaSToolError(logger, "failed to write module files", err)
	}

	// 4. validate
	logger.Info("[dpaas] validating generated module …")
	report, _ := validation.ValidateModule(modulePath, info)

	return mcp.NewToolResultText(formatGenerationReport(info, modulePath, written, report)), nil
}

func formatGenerationReport(info *schema.ResourceInfo, modulePath string, written []string, report *validation.ValidationReport) string {
	var b strings.Builder

	b.WriteString(fmt.Sprintf("Module generated: %s\n", info.ModuleName))
	b.WriteString(fmt.Sprintf("Location: %s\n\n", modulePath))
	b.WriteString(fmt.Sprintf("Files created (%d):\n", len(written)))
	for _, f := range written {
		b.WriteString(fmt.Sprintf("  - %s\n", f))
	}

	if report == nil {
		return b.String()
	}

	b.WriteString(fmt.Sprintf("\nValidation: %d/%d checks passed\n\n", report.PassedChecks, report.TotalChecks))
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

	if report.Passed {
		b.WriteString("\nModule passes all DPaaS innersource standards.\n")
	} else {
		b.WriteString("\nSome checks failed -- review the issues above.\n")
	}

	return b.String()
}

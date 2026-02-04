package generators

import (
	"fmt"
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
	b.WriteString("| Benchmark | Date | Version | Description |\n")
	b.WriteString("| --------- | ---- | ------- | ----------- |\n")
	b.WriteString(fmt.Sprintf("| [![tflint](https://img.shields.io/badge/tflint-passed-green)]() | %s | 0.58.1 | Enforces best practices, syntax, naming conventions |\n", time.Now().Format("2006-01-02")))
	b.WriteString(fmt.Sprintf("| [![trivy](https://img.shields.io/badge/trivy-passed-green)]() | %s | 0.61.0 | Detects misconfiguration in IaC files, such as Docker, Terraform, etc |\n", time.Now().Format("2006-01-02")))
	b.WriteString(fmt.Sprintf("| [![checkov](https://img.shields.io/badge/checkov-passed-green)]() | %s | 3.2.464 | Deeper tfplan scanning for security and compliance issues |\n", time.Now().Format("2006-01-02")))
	b.WriteString(fmt.Sprintf("| [![wiz](https://img.shields.io/badge/wiz.io_iac-passed-green)]() | %s | 0.84.0 | Scans tests directory plans for vulnerabilities and risks |\n", time.Now().Format("2006-01-02")))
	b.WriteString("<!-- END_BENCHMARK_TABLE -->\n\n")

	// Usage section
	b.WriteString("## Usage\n\n")
	b.WriteString("```hcl\n")
	b.WriteString(generateUsageExample(info))
	b.WriteString("```\n\n")

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

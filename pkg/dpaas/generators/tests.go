package generators

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/templates"
)

func GenerateTests(info *schema.ResourceInfo, scenarios []string) map[string]string {
	files := map[string]string{}

	scenarioSet := map[string]bool{}
	for _, s := range scenarios {
		scenarioSet[s] = true
	}

	if scenarioSet["default"] {
		files["tests/default/main.tf"] = generateDefaultTest(info)
		files["tests/default/versions.tf"] = templates.VersionsTestTf
	}

	if scenarioSet["complete"] {
		files["tests/complete/main.tf"] = generateCompleteTest(info)
		files["tests/complete/versions.tf"] = templates.VersionsTestTf
	}

	if scenarioSet["disabled"] {
		files["tests/disabled/main.tf"] = generateDisabledTest(info)
		files["tests/disabled/versions.tf"] = templates.VersionsTestTf
	}

	return files
}

func generateDefaultTest(info *schema.ResourceInfo) string {
	var b strings.Builder

	moduleName := strings.ReplaceAll(info.ShortName, "_", "_")

	b.WriteString(fmt.Sprintf("module \"%s\" {\n\n", moduleName))
	b.WriteString("  source = \"../..\"\n\n")
	b.WriteString("  enabled = true\n\n")
	b.WriteString("  namespace   = \"expn\"\n")
	b.WriteString("  tenant      = \"msp\"\n")
	b.WriteString("  environment = \"sbx\"\n")
	b.WriteString("  name        = \"sample\"\n\n")

	// Add the {resource}_name as a commented example (it's optional in the module)
	resourceNameVar := info.ShortName + "_name"
	exampleName := strings.ReplaceAll(info.ShortName, "_", "-")
	b.WriteString(fmt.Sprintf("  # %-25s = \"example-%s\"\n", resourceNameVar, exampleName))

	// Only add location and resource_group_name if they exist in the schema
	hasLocation := false
	hasResourceGroupName := false
	for _, attr := range info.Attributes {
		if attr.Name == "location" {
			hasLocation = true
		}
		if attr.Name == "resource_group_name" {
			hasResourceGroupName = true
		}
	}

	if hasLocation {
		b.WriteString(fmt.Sprintf("  %-27s = %s\n", "location", "\"East US 2\""))
	}
	if hasResourceGroupName {
		b.WriteString(fmt.Sprintf("  %-27s = %s\n", "resource_group_name", "\"eits-Sandbox-mspsandbox-BU-07959a-rg\""))
	}

	// Collect required attributes (excluding standard ones)
	var requiredAttrs []schema.ParsedAttribute
	for _, attr := range info.Attributes {
		if attr.Required && !isStandardTestVar(attr.Name) {
			requiredAttrs = append(requiredAttrs, attr)
		}
	}

	// Add required attributes section if any exist
	if len(requiredAttrs) > 0 {
		b.WriteString("\n  # Required attributes\n")
		for _, attr := range requiredAttrs {
			varName := getVariableName(attr.Name, info.ShortName)
			exampleValue := generateExampleValue(attr)
			b.WriteString(fmt.Sprintf("  %-27s = %s\n", varName, exampleValue))
		}
	}

	// Add required blocks section
	var requiredBlocks []schema.ParsedBlock
	for _, block := range info.Blocks {
		if block.Required {
			requiredBlocks = append(requiredBlocks, block)
		}
	}

	if len(requiredBlocks) > 0 {
		b.WriteString("\n  # Required blocks\n")
		for _, block := range requiredBlocks {
			exampleBlock := generateExampleBlock(block)
			b.WriteString(exampleBlock)
		}
	}

	// Tags
	b.WriteString("\n  tags = {\n")
	b.WriteString("    \"CostString\"  = \"0000.111.11.22\"\n")
	b.WriteString("    \"AppID\"       = \"0\"\n")
	b.WriteString("    \"Environment\" = \"sbx\"\n")
	b.WriteString("  }\n")
	b.WriteString("}\n")

	return b.String()
}

// generateCompleteTest creates a test that sets ALL attributes and blocks.
// Proves every variable the module exposes is wirable without syntax/type errors.
func generateCompleteTest(info *schema.ResourceInfo) string {
	var b strings.Builder

	moduleName := strings.ReplaceAll(info.ShortName, "_", "_")

	b.WriteString(fmt.Sprintf("module \"%s\" {\n\n", moduleName))
	b.WriteString("  source = \"../..\"\n\n")
	b.WriteString("  enabled = true\n\n")
	b.WriteString("  namespace   = \"expn\"\n")
	b.WriteString("  tenant      = \"msp\"\n")
	b.WriteString("  environment = \"sbx\"\n")
	b.WriteString("  name        = \"complete\"\n\n")

	// Resource name
	resourceNameVar := info.ShortName + "_name"
	exampleName := strings.ReplaceAll(info.ShortName, "_", "-")
	b.WriteString(fmt.Sprintf("  %-27s = \"example-%s\"\n", resourceNameVar, exampleName))

	// Add location and resource_group_name if they exist
	hasLocation := false
	hasResourceGroupName := false
	for _, attr := range info.Attributes {
		if attr.Name == "location" {
			hasLocation = true
		}
		if attr.Name == "resource_group_name" {
			hasResourceGroupName = true
		}
	}
	if hasLocation {
		b.WriteString(fmt.Sprintf("  %-27s = %s\n", "location", "\"East US 2\""))
	}
	if hasResourceGroupName {
		b.WriteString(fmt.Sprintf("  %-27s = %s\n", "resource_group_name", "\"eits-Sandbox-mspsandbox-BU-07959a-rg\""))
	}

	// All non-standard attributes (required + optional)
	var attrs []schema.ParsedAttribute
	for _, attr := range info.Attributes {
		if !isStandardTestVar(attr.Name) {
			attrs = append(attrs, attr)
		}
	}

	if len(attrs) > 0 {
		b.WriteString("\n  # All attributes\n")
		for _, attr := range attrs {
			varName := getVariableName(attr.Name, info.ShortName)
			exampleValue := generateExampleValue(attr)
			b.WriteString(fmt.Sprintf("  %-27s = %s\n", varName, exampleValue))
		}
	}

	// All blocks (required + optional)
	if len(info.Blocks) > 0 {
		b.WriteString("\n  # All blocks\n")
		for _, block := range info.Blocks {
			exampleBlock := generateCompleteExampleBlock(block)
			b.WriteString(exampleBlock)
		}
	}

	// Tags
	b.WriteString("\n  tags = {\n")
	b.WriteString("    \"CostString\"  = \"0000.111.11.22\"\n")
	b.WriteString("    \"AppID\"       = \"0\"\n")
	b.WriteString("    \"Environment\" = \"sbx\"\n")
	b.WriteString("  }\n")
	b.WriteString("}\n")

	return b.String()
}

// generateDisabledTest creates a test with enabled=false.
// Proves the module can be cleanly skipped (count=0) without errors.
func generateDisabledTest(info *schema.ResourceInfo) string {
	var b strings.Builder

	moduleName := strings.ReplaceAll(info.ShortName, "_", "_")

	b.WriteString(fmt.Sprintf("module \"%s\" {\n\n", moduleName))
	b.WriteString("  source = \"../..\"\n\n")
	b.WriteString("  enabled = false\n\n")
	b.WriteString("  namespace   = \"expn\"\n")
	b.WriteString("  tenant      = \"msp\"\n")
	b.WriteString("  environment = \"sbx\"\n")
	b.WriteString("  name        = \"disabled\"\n\n")

	// Still need to provide required variables (they have no defaults)
	hasLocation := false
	hasResourceGroupName := false
	for _, attr := range info.Attributes {
		if attr.Name == "location" {
			hasLocation = true
		}
		if attr.Name == "resource_group_name" {
			hasResourceGroupName = true
		}
	}

	if hasLocation {
		b.WriteString(fmt.Sprintf("  %-27s = %s\n", "location", "\"East US 2\""))
	}
	if hasResourceGroupName {
		b.WriteString(fmt.Sprintf("  %-27s = %s\n", "resource_group_name", "\"eits-Sandbox-mspsandbox-BU-07959a-rg\""))
	}

	// Required attributes (no defaults, must be provided even when disabled)
	var requiredAttrs []schema.ParsedAttribute
	for _, attr := range info.Attributes {
		if attr.Required && !isStandardTestVar(attr.Name) {
			requiredAttrs = append(requiredAttrs, attr)
		}
	}

	if len(requiredAttrs) > 0 {
		b.WriteString("\n  # Required attributes (must be provided even when disabled)\n")
		for _, attr := range requiredAttrs {
			varName := getVariableName(attr.Name, info.ShortName)
			exampleValue := generateExampleValue(attr)
			b.WriteString(fmt.Sprintf("  %-27s = %s\n", varName, exampleValue))
		}
	}

	// Required blocks (must be provided even when disabled)
	var requiredBlocks []schema.ParsedBlock
	for _, block := range info.Blocks {
		if block.Required {
			requiredBlocks = append(requiredBlocks, block)
		}
	}

	if len(requiredBlocks) > 0 {
		b.WriteString("\n  # Required blocks\n")
		for _, block := range requiredBlocks {
			exampleBlock := generateExampleBlock(block)
			b.WriteString(exampleBlock)
		}
	}

	// Tags (required by validation even when disabled)
	b.WriteString("\n  tags = {\n")
	b.WriteString("    \"CostString\"  = \"0000.111.11.22\"\n")
	b.WriteString("    \"AppID\"       = \"0\"\n")
	b.WriteString("    \"Environment\" = \"sbx\"\n")
	b.WriteString("  }\n")
	b.WriteString("}\n")

	return b.String()
}

// generateCompleteExampleBlock generates a block with ALL attributes (required + optional),
// including nested blocks recursively.
func generateCompleteExampleBlock(block schema.ParsedBlock) string {
	var b strings.Builder

	isSingle := isSingleBlock(block)
	mapKey := fmt.Sprintf("%s-1", block.Name)

	if isSingle {
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))
		writeCompleteBlockContent(&b, block, "    ")
		b.WriteString("  }\n")
	} else {
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))
		b.WriteString(fmt.Sprintf("    %s = {\n", mapKey))
		writeCompleteBlockContent(&b, block, "      ")
		b.WriteString("    }\n")
		b.WriteString("  }\n")
	}

	return b.String()
}

// writeCompleteBlockContent writes all attributes and nested blocks at the given indent level.
func writeCompleteBlockContent(b *strings.Builder, block schema.ParsedBlock, indent string) {
	for _, attr := range block.Attributes {
		exampleValue := generateExampleValue(attr)
		padding := strings.Repeat(" ", max(0, 25-len(attr.Name)))
		b.WriteString(fmt.Sprintf("%s%s%s = %s\n", indent, attr.Name, padding, exampleValue))
	}
	for _, nested := range block.Blocks {
		if isSingleBlock(nested) {
			// Single nested block: direct object syntax
			b.WriteString(fmt.Sprintf("%s%s = {\n", indent, nested.Name))
			writeCompleteBlockContent(b, nested, indent+"  ")
			b.WriteString(fmt.Sprintf("%s}\n", indent))
		} else {
			// Multi-value nested block: map syntax with named key
			mapKey := fmt.Sprintf("%s-1", nested.Name)
			b.WriteString(fmt.Sprintf("%s%s = {\n", indent, nested.Name))
			b.WriteString(fmt.Sprintf("%s  %s = {\n", indent, mapKey))
			writeCompleteBlockContent(b, nested, indent+"    ")
			b.WriteString(fmt.Sprintf("%s  }\n", indent))
			b.WriteString(fmt.Sprintf("%s}\n", indent))
		}
	}
	if len(block.Attributes) == 0 && len(block.Blocks) == 0 {
		b.WriteString(fmt.Sprintf("%s# Configure %s attributes\n", indent, block.Name))
	}
}

// isStandardTestVar identifies variables that are handled specially in the module
// and should not be included from the schema's required attributes list
func isStandardTestVar(name string) bool {
	// These variables are handled specially:
	// - name: renamed to {resource}_name and made optional (default = null)
	// - location: always created as required, but we add it manually
	// - resource_group_name: always created as required, but we add it manually
	// - tags: comes from null-label, not a direct input
	// - id: computed output, not an input
	return name == "name" || name == "location" || name == "resource_group_name" || name == "tags" || name == "id"
}

// generateExampleValue creates a sensible example value for an attribute.
// Uses pattern-based name matching derived from analysis of 1000+ azurerm resource schemas.
// Priority: type → _id → enum → name patterns → fallback
func generateExampleValue(attr schema.ParsedAttribute) string {
	// ── bool ────────────────────────────────────────────────────────────────
	if attr.TFType == "bool" {
		return "true"
	}

	// ── number ─────────────────────────────────────────────────────────────
	if attr.TFType == "number" {
		return generateNumberValue(attr.Name)
	}

	// ── string ─────────────────────────────────────────────────────────────
	if attr.TFType == "string" {
		// _id fields → Azure resource ID format
		if strings.HasSuffix(attr.Name, "_id") {
			return fmt.Sprintf("\"%s\"", schema.GenerateAzureResourceID(attr.Name))
		}

		// Enum values from provider docs
		if len(attr.EnumValues) > 0 {
			return fmt.Sprintf("\"%s\"", attr.EnumValues[0])
		}

		return generateStringValue(attr.Name)
	}

	// ── list / set / map ───────────────────────────────────────────────────
	if strings.HasPrefix(attr.TFType, "list(") || strings.HasPrefix(attr.TFType, "set(") {
		return "[]"
	}
	if strings.HasPrefix(attr.TFType, "map(") {
		return "{}"
	}
	return "null"
}

// generateNumberValue returns a realistic number based on the attribute name.
func generateNumberValue(name string) string {
	n := strings.ToLower(name)

	// Suffix-based patterns (most specific first)
	switch {
	case strings.HasSuffix(n, "_in_days") || strings.HasSuffix(n, "_days") ||
		n == "retention_in_days" || n == "retention_days" || n == "retention_period_days" ||
		n == "soft_delete_retention_days":
		return "30"
	case strings.HasSuffix(n, "_in_hours") || strings.HasSuffix(n, "_hours"):
		return "24"
	case strings.HasSuffix(n, "_in_minutes") || strings.HasSuffix(n, "_minutes"):
		return "5"
	case strings.HasSuffix(n, "_in_seconds") || strings.HasSuffix(n, "_seconds") ||
		n == "max_age_in_seconds" || n == "interval_in_seconds":
		return "60"
	case strings.HasSuffix(n, "_in_kilobytes") || strings.HasSuffix(n, "_kb") ||
		strings.HasSuffix(n, "_size_kb"):
		return "1024"
	case strings.HasSuffix(n, "_in_mb") || strings.HasSuffix(n, "_mb") ||
		strings.HasSuffix(n, "_size_mb") || strings.HasSuffix(n, "_quota_mb"):
		return "256"
	case strings.HasSuffix(n, "_size_gb") || strings.HasSuffix(n, "_gb") ||
		n == "max_size_gb" || n == "disk_size_gb":
		return "50"
	case strings.HasSuffix(n, "_percentage") || strings.HasSuffix(n, "_percent"):
		return "50"
	case strings.HasSuffix(n, "_port") || n == "port" || n == "frontend_port" || n == "backend_port":
		return "443"
	case strings.HasSuffix(n, "_count") || strings.HasSuffix(n, "_capacity") ||
		n == "instance_count" || n == "node_count" || n == "worker_count":
		return "2"
	case strings.HasSuffix(n, "_threshold") || n == "threshold" || n == "unhealthy_threshold":
		return "80"
	}

	// Prefix-based patterns
	switch {
	case strings.HasPrefix(n, "min_"):
		return "1"
	case strings.HasPrefix(n, "max_"):
		return "10"
	}

	// Exact / contains patterns
	switch {
	case n == "priority" || strings.HasSuffix(n, "_priority"):
		return "100"
	case n == "ttl" || n == "default_ttl":
		return "300"
	case n == "timeout" || strings.HasSuffix(n, "_timeout") || strings.HasSuffix(n, "_timeout_sec"):
		return "30"
	case n == "interval" || strings.HasSuffix(n, "_interval"):
		return "5"
	case n == "frequency" || strings.HasSuffix(n, "_frequency"):
		return "5"
	case n == "weight" || strings.HasSuffix(n, "_weight"):
		return "50"
	case n == "severity":
		return "3"
	case n == "lun":
		return "0"
	case n == "asn":
		return "65515"
	case n == "capacity":
		return "2"
	case n == "rule_sequence":
		return "100"
	case n == "score":
		return "30"
	case n == "idle_timeout_in_minutes":
		return "4"
	case n == "max_pods" || n == "pod_max_pid":
		return "30"
	case strings.HasSuffix(n, "_fault_domain") || strings.HasSuffix(n, "_fault_domain_count"):
		return "2"
	case n == "cpu":
		return "2"
	case n == "memory":
		return "4"
	case strings.Contains(n, "staleness_prefix"):
		return "100"
	case n == "max_bid_price":
		return "-1"
	case n == "order":
		return "0"
	case n == "size":
		return "5"
	case n == "duration":
		return "4"
	case n == "day_of_week":
		return "0"
	case n == "day_of_month":
		return "1"
	case n == "week_of_year":
		return "1"
	}

	// Default for any number
	return "1"
}

// generateStringValue returns a realistic string based on the attribute name.
// Called after _id and enum checks have already been done.
func generateStringValue(name string) string {
	n := strings.ToLower(name)

	// ── Credential / secret patterns ───────────────────────────────────────
	switch {
	case strings.Contains(n, "password"):
		return "\"P@ssw0rd1234!\""
	case n == "client_secret" || n == "consumer_secret" || n == "app_secret" ||
		n == "service_principal_key" || n == "shared_access_policy_key" ||
		n == "radius_server_secret":
		return "\"P@ssw0rd1234!\""
	case n == "admin_username" || n == "username" || n == "administrator_login" ||
		n == "domain_username":
		return "\"adminuser\""
	case n == "public_key" || n == "key_data":
		return "\"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC example@example.com\""
	}

	// ── Network / IP patterns ──────────────────────────────────────────────
	switch {
	case n == "ip_address" || n == "private_ip_address":
		return "\"10.0.0.4\""
	case n == "public_ip_address":
		return "\"20.0.0.1\""
	case n == "start_ip_address":
		return "\"0.0.0.0\""
	case n == "end_ip_address":
		return "\"255.255.255.255\""
	case n == "dns_service_ip":
		return "\"10.0.0.10\""
	case strings.HasSuffix(n, "_ip_address"):
		return "\"10.0.0.4\""
	case n == "address_space":
		return "\"10.0.0.0/16\""
	case strings.Contains(n, "address_prefix") || strings.Contains(n, "_cidr") ||
		n == "pod_cidr" || n == "service_cidr" || n == "subnet_cidr":
		return "\"10.0.1.0/24\""
	case n == "ip_mask":
		return "\"10.0.0.0/24\""
	case strings.HasSuffix(n, "_fqdn") || n == "fqdn" || n == "portal_fqdn" || n == "private_fqdn":
		return "\"example.contoso.com\""
	case n == "hostname" || n == "host_name" || strings.HasSuffix(n, "_hostname") ||
		n == "default_hostname":
		return "\"example.contoso.com\""
	case n == "domain_name" || strings.HasSuffix(n, "_domain") || n == "root_domain" ||
		n == "zone_name":
		return "\"example.com\""
	case n == "domain_name_label":
		return "\"example-dns-label\""
	case n == "dns_prefix" || strings.HasPrefix(n, "dns_prefix"):
		return "\"example-dns\""
	}

	// ── URL / URI / endpoint patterns ──────────────────────────────────────
	switch {
	case n == "url" || strings.HasSuffix(n, "_url"):
		return "\"https://example.com\""
	case n == "uri" || strings.HasSuffix(n, "_uri"):
		return "\"https://example.vault.azure.net/\""
	case n == "endpoint" || strings.HasSuffix(n, "_endpoint"):
		return "\"https://example.endpoint.net\""
	case n == "connection_string" || strings.HasSuffix(n, "_connection_string"):
		return "\"Server=tcp:example.database.windows.net,1433;Database=exampledb;\""
	}

	// ── Path patterns ──────────────────────────────────────────────────────
	switch {
	case n == "path" || n == "mount_path" || n == "health_check_path" ||
		strings.HasSuffix(n, "_path"):
		return "\"/\""
	}

	// ── Time / date / timezone patterns ────────────────────────────────────
	switch {
	case n == "time_zone" || n == "timezone":
		return "\"UTC\""
	case n == "utc_offset":
		return "\"+00:00\""
	case strings.HasSuffix(n, "_time") || n == "start_time" || n == "end_time" ||
		n == "start" || n == "effective_until":
		return "\"2024-01-01T00:00:00Z\""
	case strings.HasSuffix(n, "_date") || n == "start_date" || n == "expiration_date" || n == "expiry":
		return "\"2024-12-31\""
	case strings.Contains(n, "_retention") && !strings.Contains(n, "days"):
		// ISO 8601 duration for weekly_retention, monthly_retention, yearly_retention
		return "\"P1W\""
	}

	// ── Azure-specific patterns ────────────────────────────────────────────
	switch {
	case n == "vm_size":
		return "\"Standard_DS2_v2\""
	case n == "collation":
		return "\"SQL_Latin1_General_CP1_CI_AS\""
	case n == "content_type":
		return "\"application/json\""
	case n == "max_surge":
		return "\"10%\""
	case n == "publisher":
		return "\"Canonical\""
	case n == "offer":
		return "\"0001-com-ubuntu-server-jammy\""
	case n == "sku" || n == "sku_name":
		return "\"Standard\""
	case n == "tier" || n == "sku_tier":
		return "\"Standard\""
	case n == "kind":
		return "\"StorageV2\""
	case n == "edge_zone":
		return "\"microsoftlosangeles1\""
	}

	// ── Description / content patterns ─────────────────────────────────────
	switch {
	case n == "description":
		return "\"Managed by Terraform\""
	case n == "body":
		return "\"example-body\""
	case n == "content":
		return "\"example-content\""
	case n == "subject":
		return "\"CN=example\""
	case n == "phone" || n == "phone_number":
		return "\"+15555555555\""
	case n == "email":
		return "\"admin@example.com\""
	case n == "branch":
		return "\"main\""
	case n == "computer_name":
		return "\"example-vm\""
	case n == "custom_data":
		return "\"IyEvYmluL2Jhc2g=\"" // base64("#!/bin/bash")
	case n == "label" || strings.HasSuffix(n, "_label"):
		return "\"example-label\""
	case n == "thumbprint":
		return "\"0000000000000000000000000000000000000000\""
	case n == "data" || n == "public_cert_data":
		return "\"base64encodeddata\""
	}

	// ── Name patterns (broad match — keep near end) ────────────────────────
	if strings.Contains(n, "name") {
		return fmt.Sprintf("\"example-%s\"", strings.ReplaceAll(name, "_", "-"))
	}

	// ── Version patterns ───────────────────────────────────────────────────
	if strings.Contains(n, "version") {
		return "\"1.0\""
	}

	// ── Key / token patterns ───────────────────────────────────────────────
	switch {
	case strings.HasSuffix(n, "_key") || n == "key" || n == "access_key" || n == "api_key":
		return "\"example-key-value\""
	case n == "token":
		return "\"example-token\""
	}

	// ── Default fallback ───────────────────────────────────────────────────
	return "\"example-value\""
}

// generateExampleBlock creates an example configuration for a required block
// Single blocks use object syntax, multi-value blocks use map of objects with named keys
func generateExampleBlock(block schema.ParsedBlock) string {
	var b strings.Builder

	// Check if this is a single block or multi-value block
	isSingle := isSingleBlock(block)

	// Create a map key for multi-value blocks
	mapKey := fmt.Sprintf("%s-1", block.Name)

	// Fully dynamic block generation based on schema
	if isSingle {
		// Single block: use object syntax
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))

		hasRequired := false
		for _, attr := range block.Attributes {
			if attr.Required {
				hasRequired = true
				exampleValue := generateExampleValue(attr)
				padding := strings.Repeat(" ", max(0, 25-len(attr.Name)))
				b.WriteString(fmt.Sprintf("    %s%s = %s\n", attr.Name, padding, exampleValue))
			}
		}
		if !hasRequired {
			b.WriteString(fmt.Sprintf("    # Configure %s attributes\n", block.Name))
		}

		b.WriteString("  }\n")
	} else {
		// Multi-value block: use map of objects syntax
		b.WriteString(fmt.Sprintf("  %s = {\n", block.Name))
		b.WriteString(fmt.Sprintf("    %s = {\n", mapKey))

		hasRequired := false
		for _, attr := range block.Attributes {
			if attr.Required {
				hasRequired = true
				exampleValue := generateExampleValue(attr)
				padding := strings.Repeat(" ", max(0, 25-len(attr.Name)))
				b.WriteString(fmt.Sprintf("      %s%s = %s\n", attr.Name, padding, exampleValue))
			}
		}
		if !hasRequired {
			b.WriteString(fmt.Sprintf("      # Configure %s attributes\n", block.Name))
		}

		b.WriteString("    }\n")
		b.WriteString("  }\n")
	}

	return b.String()
}

// max returns the maximum of two integers
func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

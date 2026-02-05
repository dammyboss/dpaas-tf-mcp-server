package schema

import (
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
	"time"
)

// GitHub raw content URL for azurerm provider docs
const azurermDocsBase = "https://raw.githubusercontent.com/hashicorp/terraform-provider-azurerm/main/website/docs/r/"

// DocsInfo holds enum values and descriptions extracted from provider docs.
type DocsInfo struct {
	Enums        map[string][]string // qualified key → allowed values
	Descriptions map[string]string   // qualified key → description text
}

// FetchDocsInfo fetches provider docs and extracts both enum values and descriptions.
func FetchDocsInfo(resourceType string) *DocsInfo {
	shortName := strings.TrimPrefix(resourceType, "azurerm_")
	url := azurermDocsBase + shortName + ".html.markdown"

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(url)
	if err != nil || resp.StatusCode != 200 {
		return nil
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil
	}

	return parseDocsInfo(string(body))
}

// FetchDocsEnumValues is a convenience wrapper returning only enum values.
func FetchDocsEnumValues(resourceType string) map[string][]string {
	info := FetchDocsInfo(resourceType)
	if info == nil {
		return nil
	}
	return info.Enums
}

// parseDocsInfo parses raw markdown and extracts both enum values and
// descriptions for every attribute, tracking block context via headers and
// the "A `x` block supports the following:" convention.
func parseDocsInfo(docs string) *DocsInfo {
	enums := make(map[string][]string)
	descriptions := make(map[string]string)

	enumPattern := regexp.MustCompile(`(?i)(?:possible|valid|allowed)\s+(?:values?|options?)\s+(?:are|include|is)\s*[:=]?\s*(.+?)[.\n]`)
	// Group 1 = attr name, Group 2 = rest of the line (description text)
	attrPattern := regexp.MustCompile("(?m)^\\*\\s+`([a-zA-Z0-9_.]+)`\\s*-?\\s*(.*)")
	linkPattern := regexp.MustCompile(`\[([^\]]+)\]\([^)]+\)`)

	lines := strings.Split(docs, "\n")

	var currentBlock string
	headerBlockPattern := regexp.MustCompile(`^#{2,4}\s+` + "`?" + `([a-z_]+)` + "`?")
	supportsBlockPattern := regexp.MustCompile("(?i)^(?:a|an)\\s+`([a-z_]+)`\\s+block\\s+supports")

	for i, line := range lines {
		// Detect block context
		if m := supportsBlockPattern.FindStringSubmatch(line); m != nil {
			currentBlock = m[1]
		} else if m := headerBlockPattern.FindStringSubmatch(line); m != nil {
			candidate := m[1]
			if !isGenericHeading(candidate) {
				currentBlock = candidate
			}
		}

		attrMatch := attrPattern.FindStringSubmatch(line)
		if attrMatch == nil {
			continue
		}

		attrName := attrMatch[1]

		// Build qualified key
		key := attrName
		if !strings.Contains(attrName, ".") && currentBlock != "" {
			key = currentBlock + "." + attrName
		}

		// Extract description (group 2), strip markdown links
		if desc := strings.TrimSpace(attrMatch[2]); desc != "" {
			descriptions[key] = linkPattern.ReplaceAllString(desc, "$1")
		}

		// Enum extraction: search current line + continuation lines, stop at next attr
		end := i + 1
		for end < len(lines) && end < i+4 {
			if attrPattern.MatchString(lines[end]) {
				break
			}
			end++
		}
		searchText := strings.Join(lines[i:end], "\n")

		enumMatch := enumPattern.FindStringSubmatch(searchText)
		if enumMatch == nil {
			continue
		}

		vals := parseEnumList(enumMatch[1])
		if len(vals) < 2 {
			continue
		}

		enums[key] = vals
	}

	return &DocsInfo{Enums: enums, Descriptions: descriptions}
}

// parseEnumList splits a comma/and-separated list of enum values
// like `Http`, `Https` or "Basic" "Standard_v2" etc.
func parseEnumList(raw string) []string {
	// Normalise "and" into commas
	raw = strings.ReplaceAll(raw, " and ", ", ")

	var vals []string
	for _, token := range strings.Split(raw, ",") {
		token = strings.TrimSpace(token)
		token = strings.Trim(token, "`\"'()[]")
		if token != "" && len(token) < 60 && !strings.Contains(token, " ") {
			vals = append(vals, token)
		}
	}
	return vals
}

// MergeDocsEnums merges enum values fetched from docs into the ResourceInfo.
// It matches top-level attributes by name, and block attributes by "block.attr" key.
func MergeDocsEnums(info *ResourceInfo, docsEnums map[string][]string) {
	if docsEnums == nil {
		return
	}

	// Top-level attributes
	for i, attr := range info.Attributes {
		if vals, ok := docsEnums[attr.Name]; ok && len(attr.EnumValues) == 0 {
			info.Attributes[i].EnumValues = vals
		}
	}

	// Block attributes (recursive)
	for i, block := range info.Blocks {
		mergeBlockEnums(&info.Blocks[i], block.Name, docsEnums)
	}
}

func mergeBlockEnums(block *ParsedBlock, prefix string, docsEnums map[string][]string) {
	for i, attr := range block.Attributes {
		if len(attr.EnumValues) > 0 {
			continue
		}
		// Try qualified key first (e.g. "sku.tier"), fall back to unqualified
		key := prefix + "." + attr.Name
		if vals, ok := docsEnums[key]; ok {
			block.Attributes[i].EnumValues = vals
		} else if vals, ok := docsEnums[attr.Name]; ok {
			block.Attributes[i].EnumValues = vals
		}
	}
	for i, nested := range block.Blocks {
		mergeBlockEnums(&block.Blocks[i], prefix+"."+nested.Name, docsEnums)
	}
}

// MergeDocsInfo merges both enum values and descriptions into ResourceInfo.
func MergeDocsInfo(info *ResourceInfo, docsInfo *DocsInfo) {
	if docsInfo == nil {
		return
	}
	MergeDocsEnums(info, docsInfo.Enums)
	mergeDocsDescriptions(info, docsInfo.Descriptions)
}

func mergeDocsDescriptions(info *ResourceInfo, descriptions map[string]string) {
	for i, attr := range info.Attributes {
		if info.Attributes[i].Description == "" {
			if desc, ok := descriptions[attr.Name]; ok {
				info.Attributes[i].Description = desc
			}
		}
	}
	for i, block := range info.Blocks {
		mergeBlockDescriptions(&info.Blocks[i], block.Name, descriptions)
	}
}

func mergeBlockDescriptions(block *ParsedBlock, prefix string, descriptions map[string]string) {
	for i, attr := range block.Attributes {
		if block.Attributes[i].Description == "" {
			key := prefix + "." + attr.Name
			if desc, ok := descriptions[key]; ok {
				block.Attributes[i].Description = desc
			} else if desc, ok := descriptions[attr.Name]; ok {
				block.Attributes[i].Description = desc
			}
		}
	}
	for i, nested := range block.Blocks {
		mergeBlockDescriptions(&block.Blocks[i], prefix+"."+nested.Name, descriptions)
	}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// isGenericHeading filters out common markdown headings that are not block names
func isGenericHeading(s string) bool {
	generics := map[string]bool{
		"argument": true, "arguments": true, "reference": true,
		"attributes": true, "attribute": true, "example": true,
		"examples": true, "usage": true, "import": true,
		"timeouts": true, "note": true, "notes": true,
	}
	return generics[strings.ToLower(s)]
}

// GenerateAzureResourceID generates a properly formatted Azure resource ID
// based on the attribute name suffix. Returns a placeholder ID that matches
// the Azure ID segment structure.
func GenerateAzureResourceID(attrName string) string {
	sub := "00000000-0000-0000-0000-000000000000"
	rg := "example-resource-group"

	// Known Azure resource ID patterns derived from attribute name
	// These are the standard Azure resource ID formats per resource type
	patterns := map[string]string{
		"subnet_id":                      fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-subnet", sub, rg),
		"virtual_network_id":             fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/example-vnet", sub, rg),
		"public_ip_address_id":           fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/publicIPAddresses/example-pip", sub, rg),
		"network_security_group_id":      fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkSecurityGroups/example-nsg", sub, rg),
		"key_vault_id":                   fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.KeyVault/vaults/example-kv", sub, rg),
		"storage_account_id":             fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Storage/storageAccounts/examplestorage", sub, rg),
		"log_analytics_workspace_id":     fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/example-workspace", sub, rg),
		"service_plan_id":                fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/serverFarms/example-service-plan", sub, rg),
		"app_service_plan_id":            fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/serverFarms/example-app-service-plan", sub, rg),
		"container_app_environment_id":   fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.App/managedEnvironments/example-environment", sub, rg),
		"private_link_configuration_id":  fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/applicationGateways/example-appgw/privateLinkConfigurations/example-plc", sub, rg),
		"firewall_policy_id":             fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/example-waf", sub, rg),
	}

	if id, ok := patterns[attrName]; ok {
		return id
	}

	// Generic fallback: derive resource type from attribute name
	resourceType := strings.TrimSuffix(attrName, "_id")
	return fmt.Sprintf("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Resources/resources/example-%s", sub, rg, resourceType)
}

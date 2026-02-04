package schema

import (
	"encoding/json"
	"fmt"
	"sort"
	"strings"
)

// ParseTerraformSchema parses raw JSON from `terraform providers schema -json`
// and returns the processed ResourceInfo for the requested resource type.
func ParseTerraformSchema(data []byte, resourceType string) (*ResourceInfo, error) {
	var tfSchema TerraformSchema
	if err := json.Unmarshal(data, &tfSchema); err != nil {
		return nil, fmt.Errorf("failed to parse terraform schema JSON: %w", err)
	}

	for _, provider := range tfSchema.ProviderSchemas {
		if entry, ok := provider.ResourceSchemas[resourceType]; ok {
			return processResource(resourceType, entry)
		}
	}

	return nil, fmt.Errorf("resource type %q not found in provider schemas", resourceType)
}

// ListResourceTypes extracts every resource type name from the raw schema JSON,
// optionally filtered by a substring match.
func ListResourceTypes(data []byte, filter string) ([]string, error) {
	var tfSchema TerraformSchema
	if err := json.Unmarshal(data, &tfSchema); err != nil {
		return nil, fmt.Errorf("failed to parse schema JSON: %w", err)
	}

	filter = strings.ToLower(filter)
	var names []string
	for _, provider := range tfSchema.ProviderSchemas {
		for name := range provider.ResourceSchemas {
			if filter == "" || strings.Contains(strings.ToLower(name), filter) {
				names = append(names, name)
			}
		}
	}
	sort.Strings(names)
	return names, nil
}

// ---------------------------------------------------------------------------

func processResource(resourceType string, entry ResourceSchemaEntry) (*ResourceInfo, error) {
	shortName := strings.TrimPrefix(resourceType, "azurerm_")
	info := &ResourceInfo{
		ResourceType: resourceType,
		ShortName:    shortName,
		ModuleName:   "expn-tf-azure-" + strings.ReplaceAll(shortName, "_", "-"),
		DisplayName:  toDisplayName(shortName),
	}

	attrs, computedOnly := processAttributes(entry.Block.Attributes)
	info.Attributes = attrs
	info.ComputedOnlyAttrs = computedOnly
	info.Blocks = processBlocks(entry.Block.BlockTypes)
	return info, nil
}

func processAttributes(raw map[string]Attribute) ([]ParsedAttribute, []string) {
	var attrs []ParsedAttribute
	var computedOnly []string

	for _, name := range sortedAttrKeys(raw) {
		a := raw[name]

		if a.Deprecated {
			continue
		}
		if name == "id" {
			continue
		}
		// Computed-only attributes are not user-settable — they become outputs
		if a.Computed && !a.Optional && !a.Required {
			computedOnly = append(computedOnly, name)
			continue
		}

		attrs = append(attrs, ParsedAttribute{
			Name:        name,
			TFType:      parseTFType(a.Type),
			Description: a.Description,
			Required:    a.Required,
			Optional:    a.Optional,
			Computed:    a.Computed,
			Sensitive:   a.Sensitive,
			EnumValues:  extractEnumValues(a.Description),
		})
	}
	return attrs, computedOnly
}

func processBlocks(raw map[string]BlockTypeEntry) []ParsedBlock {
	var blocks []ParsedBlock

	for _, name := range sortedBlockKeys(raw) {
		bt := raw[name]
		if bt.Deprecated {
			continue
		}

		b := ParsedBlock{
			Name:        name,
			NestingMode: bt.NestingMode,
			Required:    bt.MinItems > 0,
			MaxItems:    bt.MaxItems,
		}
		b.Attributes, _ = processAttributes(bt.Block.Attributes)
		b.Blocks = processBlocks(bt.Block.BlockTypes)
		blocks = append(blocks, b)
	}
	return blocks
}

// ---------------------------------------------------------------------------
// Type parsing
// ---------------------------------------------------------------------------

// parseTFType converts the raw JSON "type" field from the provider schema into
// a valid Terraform type expression string.
func parseTFType(raw json.RawMessage) string {
	if len(raw) == 0 {
		return "any"
	}

	var scalar string
	if err := json.Unmarshal(raw, &scalar); err == nil {
		if scalar == "dynamic" {
			return "any"
		}
		return scalar
	}

	var arr []json.RawMessage
	if err := json.Unmarshal(raw, &arr); err != nil || len(arr) < 2 {
		return "any"
	}

	var kind string
	if err := json.Unmarshal(arr[0], &kind); err != nil {
		return "any"
	}

	switch kind {
	case "list":
		return "list(" + parseTFType(arr[1]) + ")"
	case "set":
		return "set(" + parseTFType(arr[1]) + ")"
	case "map":
		return "map(" + parseTFType(arr[1]) + ")"
	case "tuple":
		return "list(any)"
	case "object":
		var fields map[string]json.RawMessage
		if err := json.Unmarshal(arr[1], &fields); err != nil {
			return "object({})"
		}
		if len(fields) == 0 {
			return "object({})"
		}
		var parts []string
		for _, k := range sortedRawKeys(fields) {
			parts = append(parts, fmt.Sprintf("%s = %s", k, parseTFType(fields[k])))
		}
		return "object({\n      " + strings.Join(parts, "\n      ") + "\n    })"
	}
	return "any"
}

// ---------------------------------------------------------------------------
// Enum extraction (heuristic from description text)
// ---------------------------------------------------------------------------

func extractEnumValues(desc string) []string {
	if desc == "" {
		return nil
	}

	lower := strings.ToLower(desc)
	triggers := []string{
		"accepted values are ",
		"possible values are ",
		"valid values are ",
		"must be one of: ",
		"allowed values: ",
		"possible values include ",
	}

	for _, trigger := range triggers {
		idx := strings.Index(lower, trigger)
		if idx == -1 {
			continue
		}
		rest := desc[idx+len(trigger):]
		if end := strings.IndexAny(rest, ".\n"); end > 0 {
			rest = rest[:end]
		}
		rest = strings.ReplaceAll(rest, " and ", ", ")

		var vals []string
		for _, token := range strings.Split(rest, ",") {
			token = strings.TrimSpace(token)
			token = strings.Trim(token, "`\"'()[]")
			if token != "" && len(token) < 80 {
				vals = append(vals, token)
			}
		}
		if len(vals) >= 2 {
			return vals
		}
	}
	return nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func toDisplayName(s string) string {
	parts := strings.Split(s, "_")
	for i, p := range parts {
		if len(p) > 0 {
			parts[i] = strings.ToUpper(p[:1]) + p[1:]
		}
	}
	return strings.Join(parts, " ")
}

func sortedAttrKeys(m map[string]Attribute) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return keys
}

func sortedBlockKeys(m map[string]BlockTypeEntry) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return keys
}

func sortedRawKeys(m map[string]json.RawMessage) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return keys
}

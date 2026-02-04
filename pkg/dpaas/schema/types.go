package schema

import "encoding/json"

// TerraformSchema is the top-level output of `terraform providers schema -json`.
type TerraformSchema struct {
	FormatVersion   string                    `json:"format_version"`
	ProviderSchemas map[string]ProviderSchema `json:"provider_schemas"`
}

// ProviderSchema holds schemas for all resources within a single provider.
type ProviderSchema struct {
	ResourceSchemas map[string]ResourceSchemaEntry `json:"resource_schemas"`
}

// ResourceSchemaEntry is the raw schema block for one resource type.
type ResourceSchemaEntry struct {
	Version int   `json:"version"`
	Block   Block `json:"block"`
}

// Block is a Terraform schema block — either the root block of a resource or a nested block.
type Block struct {
	Attributes map[string]Attribute      `json:"attributes"`
	BlockTypes map[string]BlockTypeEntry `json:"block_types"`
}

// Attribute is the raw schema definition of a single attribute.
type Attribute struct {
	Type        json.RawMessage `json:"type"`
	Description string          `json:"description"`
	Required    bool            `json:"required"`
	Optional    bool            `json:"optional"`
	Computed    bool            `json:"computed"`
	Sensitive   bool            `json:"sensitive"`
	Deprecated  bool            `json:"deprecated"`
}

// BlockTypeEntry is the raw schema definition of a nested block type.
type BlockTypeEntry struct {
	Block       Block  `json:"block"`
	NestingMode string `json:"nesting_mode"` // single | list | set | map | group
	MinItems    int    `json:"min_items"`
	MaxItems    int    `json:"max_items"`
	Deprecated  bool   `json:"deprecated"`
}

// ---------------------------------------------------------------------------
// Processed types — populated by the parser, consumed by generators.
// ---------------------------------------------------------------------------

// ResourceInfo is the fully processed, generator-ready representation of one Azure resource.
type ResourceInfo struct {
	ResourceType      string            // e.g. "azurerm_bastion_host"
	ShortName         string            // e.g. "bastion_host"
	ModuleName        string            // e.g. "expn-tf-azure-bastion-host"
	DisplayName       string            // e.g. "Bastion Host"
	Attributes        []ParsedAttribute // settable attributes (required + optional)
	Blocks            []ParsedBlock     // nested block definitions
	ComputedOnlyAttrs []string          // computed-only attr names → become outputs
}

// ParsedAttribute is one attribute that will become a variable and a resource argument.
type ParsedAttribute struct {
	Name        string
	TFType      string   // Terraform variable type expression
	Description string
	Required    bool
	Optional    bool
	Computed    bool
	Sensitive   bool
	EnumValues  []string // possible values extracted from description
}

// ParsedBlock is one nested block that will become a variable (object/list) + dynamic block.
type ParsedBlock struct {
	Name        string
	NestingMode string // single | list | set | map | group
	Required    bool   // true when min_items > 0
	MaxItems    int
	Attributes  []ParsedAttribute
	Blocks      []ParsedBlock // recursively nested
}

# Plan: Handle Naming Conflicts Between Resource Attributes and Null-Label Variables

## Problem

When a resource attribute name conflicts with a null-label variable name (e.g., `enabled`), both the null-label template and the variable generator create variables with the same name, causing Terraform to fail:

```
Error: Duplicate variable declaration
  on ../../variables.tf line 300:
  300: variable "enabled" {
A variable named "enabled" was already declared at ../../variables.tf:48,1-19.
```

**Example:** `azurerm_windows_web_app` has an `enabled` attribute (controls if web app is running), but null-label also has `enabled` (controls if resource is created).

## Root Cause

The `isStandardVar()` function only excludes `name`, `location`, `resource_group_name`, `tags`, and `id`. It doesn't exclude null-label reserved names like `enabled`, `namespace`, `environment`, `tenant`, `stage`, etc.

## Solution: Rename Conflicting Attributes with Resource Prefix

When a resource attribute conflicts with a null-label variable, rename it using the pattern: `{shortname}_{attribute}`.

**Example:**
- `enabled` → `windows_web_app_enabled`
- `namespace` → `windows_web_app_namespace` (if such a resource existed)

**Why this approach:**
1. Maintains both null-label functionality AND resource-specific attributes
2. Clear naming shows which resource the attribute belongs to
3. Follows existing pattern where `name` → `{shortname}_name`

## Implementation

### Step 1: Add Reserved Names List (variables_tf.go)

```go
// nullLabelReservedVars contains variable names defined by null-label
// that should not be overwritten by resource attributes
var nullLabelReservedVars = map[string]bool{
    "context": true, "enabled": true, "namespace": true,
    "tenant": true, "environment": true, "stage": true,
    "name": true, "delimiter": true, "attributes": true,
    "labels_as_tags": true, "additional_tag_map": true,
    "label_order": true, "regex_replace_chars": true,
    "id_length_limit": true, "label_key_case": true,
    "label_value_case": true, "descriptor_formats": true,
    "tags": true,
}
```

### Step 2: Add Helper Function (variables_tf.go)

```go
// getVariableName returns the variable name for an attribute,
// prefixing with resource short name if it conflicts with null-label
func getVariableName(attrName string, shortName string) string {
    if nullLabelReservedVars[attrName] && !isStandardVar(attrName) {
        return shortName + "_" + attrName
    }
    return attrName
}
```

### Step 3: Update writeVariable() (variables_tf.go)

Change line ~91:
```go
// Before
b.WriteString(fmt.Sprintf("variable \"%s\" {\n", attr.Name))

// After
varName := getVariableName(attr.Name, info.ShortName)
b.WriteString(fmt.Sprintf("variable \"%s\" {\n", varName))
```

### Step 4: Update main_tf.go

Change line ~59 where attributes are referenced:
```go
// Before
b.WriteString(fmt.Sprintf("  %s%s = var.%s\n", a.Name, padding, a.Name))

// After
varName := getVariableName(a.Name, info.ShortName)
b.WriteString(fmt.Sprintf("  %s%s = var.%s\n", a.Name, padding, varName))
```

Note: The resource attribute name stays the same (e.g., `enabled`), only the variable reference changes (e.g., `var.windows_web_app_enabled`).

### Step 5: Update tests.go

Change line ~71 where test values are written:
```go
// Before
b.WriteString(fmt.Sprintf("  %-27s = %s\n", attr.Name, exampleValue))

// After
varName := getVariableName(attr.Name, info.ShortName)
b.WriteString(fmt.Sprintf("  %-27s = %s\n", varName, exampleValue))
```

## Files to Modify

| File | Changes |
|------|---------|
| `pkg/dpaas/generators/variables_tf.go` | Add `nullLabelReservedVars` map, add `getVariableName()` helper, update `writeVariable()` |
| `pkg/dpaas/generators/main_tf.go` | Update attribute variable references |
| `pkg/dpaas/generators/tests.go` | Update test attribute names |

## Expected Output

For `azurerm_windows_web_app`:

**variables.tf:**
```hcl
# From null-label (controls resource creation)
variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources"
  default     = null
}

# From resource schema (controls if web app is running)
variable "windows_web_app_enabled" {
  description = "(Optional) Should the Windows Web App be enabled? Defaults to `true`."
  type        = bool
  default     = null
}
```

**main.tf:**
```hcl
resource "azurerm_windows_web_app" "this" {
  count   = local.enabled ? 1 : 0
  ...
  enabled = try(var.windows_web_app_enabled, null)
  ...
}
```

**tests/default/main.tf:**
```hcl
module "windows_web_app" {
  ...
  enabled = true  # null-label: create the resource

  windows_web_app_enabled = true  # resource attribute: app is running
  ...
}
```

## Testing

1. Rebuild: `go build -o terraform-mcp ./cmd/terraform-mcp-server/`
2. Regenerate: `azurerm_windows_web_app`
3. Validate: `terraform init && terraform validate`
4. Plan: `terraform plan` (should succeed without duplicate variable errors)

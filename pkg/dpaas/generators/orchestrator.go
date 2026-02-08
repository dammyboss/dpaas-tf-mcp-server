package generators

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/templates"
)

// GenerateModule produces all files for a DPaaS innersource module.
// scenarios controls which test scenarios are generated (default, complete, disabled).
func GenerateModule(info *schema.ResourceInfo, scenarios []string) GeneratedModule {
	m := GeneratedModule{}

	// Static files (byte-for-byte copies)
	m["context.tf"] = templates.ContextTf
	m[".pre-commit-config.yaml"] = templates.PreCommitConfig
	m[".gitignore"] = templates.Gitignore
	m["versions.tf"] = templates.VersionsRootTf

	// Dynamic files
	m["locals.tf"] = GenerateLocalsTf(info)
	m["main.tf"] = GenerateMainTf(info)
	m["variables.tf"] = GenerateVariablesTf(info)
	m["outputs.tf"] = GenerateOutputsTf(info)
	m["README.md"] = GenerateReadme(info)
	m["CHANGELOG.md"] = GenerateChangelog(info)

	// Tests
	for k, v := range GenerateTests(info, scenarios) {
		m[k] = v
	}

	return m
}

// WriteModule writes all generated files to the specified output directory.
func WriteModule(outputDir string, module GeneratedModule) ([]string, error) {
	var written []string

	for relPath, content := range module {
		fullPath := filepath.Join(outputDir, relPath)

		if err := os.MkdirAll(filepath.Dir(fullPath), 0755); err != nil {
			return written, fmt.Errorf("mkdir %s: %w", filepath.Dir(fullPath), err)
		}

		if err := os.WriteFile(fullPath, []byte(content), 0644); err != nil {
			return written, fmt.Errorf("write %s: %w", fullPath, err)
		}

		written = append(written, relPath)
	}
	return written, nil
}

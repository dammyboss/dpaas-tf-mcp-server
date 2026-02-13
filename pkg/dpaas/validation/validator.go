package validation

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
)

// ValidationReport is the top-level result returned to the caller.
type ValidationReport struct {
	Passed         bool
	TotalChecks    int
	PassedChecks   int
	Checks         []CheckResult
	CoverageReport *CoverageReport
}

// CheckResult is one named assertion.
type CheckResult struct {
	Name    string
	Passed  bool
	Message string
}

// CoverageReport quantifies how many schema items appeared in the generated module.
type CoverageReport struct {
	SchemaAttrCount     int
	GeneratedAttrCount  int
	SchemaBlockCount    int
	GeneratedBlockCount int
	MissingAttrs        []string
	MissingBlocks       []string
	CoveragePercent     float64
}

// ---------------------------------------------------------------------------

// ValidateModule runs every DPaaS standard check against a module directory.
func ValidateModule(modulePath string, info *schema.ResourceInfo) (*ValidationReport, error) {
	r := &ValidationReport{}

	// ── 1. required-file existence ──────────────────────────────────────────
	for _, f := range []string{
		"context.tf", "locals.tf", "main.tf", "outputs.tf",
		"variables.tf", "versions.tf", "README.md", "CHANGELOG.md",
		".pre-commit-config.yaml", ".gitignore",
	} {
		r.addCheck(fmt.Sprintf("File exists: %s", f), fileExists(filepath.Join(modulePath, f)), "")
	}

	// ── 2. tests/ has at least one scenario ────────────────────────────────
	testMains, _ := filepath.Glob(filepath.Join(modulePath, "tests", "*", "main.tf"))
	r.addCheck("tests/ has at least one scenario", len(testMains) > 0, "")

	// ── 3. main.tf structure ────────────────────────────────────────────────
	if mainTf, err := os.ReadFile(filepath.Join(modulePath, "main.tf")); err == nil {
		content := string(mainTf)
		r.addCheck("main.tf uses count pattern",
			containsCountPattern(content),
			"Resource must use: count = local.enabled ? 1 : 0")
		r.addCheck("main.tf resource named 'this'",
			strings.Contains(content, fmt.Sprintf(`"%s" "this"`, info.ResourceType)),
			"Resource block must be named 'this'")
		r.addCheck("main.tf references local.tags",
			strings.Contains(content, "local.tags"),
			"Tags attribute must reference local.tags")
	}

	// ── 4. variables.tf null-label markers ──────────────────────────────────
	if varsTf, err := os.ReadFile(filepath.Join(modulePath, "variables.tf")); err == nil {
		content := string(varsTf)
		r.addCheck("variables.tf: Start of null-label marker",
			strings.Contains(content, "Start of null-label Variables"), "")
		r.addCheck("variables.tf: End of null-label marker",
			strings.Contains(content, "End of null-label Variables"), "")
		r.addCheck("variables.tf: create_ flag present",
			strings.Contains(content, fmt.Sprintf("create_%s", info.ShortName)), "")
		r.addCheck("variables.tf: resource name variable present",
			strings.Contains(content, fmt.Sprintf("%s_name", info.ShortName)), "")
	}

	// ── 5. locals.tf DPaaS tags ─────────────────────────────────────────────
	if localsTf, err := os.ReadFile(filepath.Join(modulePath, "locals.tf")); err == nil {
		content := string(localsTf)
		r.addCheck("locals.tf: dpaas_tags defined",
			strings.Contains(content, "dpaas_tags"), "")
		r.addCheck("locals.tf: innersource tag present",
			strings.Contains(content, `"innersource"`), "")
		r.addCheck("locals.tf: enabled uses create_ flag",
			strings.Contains(content, fmt.Sprintf("create_%s", info.ShortName)), "")
	}

	// ── 6. argument coverage ────────────────────────────────────────────────
	if info != nil {
		cr := checkCoverage(modulePath, info)
		r.CoverageReport = cr
		r.addCheck(
			fmt.Sprintf("Argument coverage: %.0f%%", cr.CoveragePercent),
			cr.CoveragePercent == 100,
			fmt.Sprintf("Missing attrs: %v  Missing blocks: %v", cr.MissingAttrs, cr.MissingBlocks),
		)
	}

	r.Passed = r.PassedChecks == r.TotalChecks
	return r, nil
}

// ---------------------------------------------------------------------------

func (r *ValidationReport) addCheck(name string, passed bool, message string) {
	r.TotalChecks++
	if passed {
		r.PassedChecks++
	}
	r.Checks = append(r.Checks, CheckResult{Name: name, Passed: passed, Message: message})
}

func checkCoverage(modulePath string, info *schema.ResourceInfo) *CoverageReport {
	cr := &CoverageReport{}

	mainRaw, err1 := os.ReadFile(filepath.Join(modulePath, "main.tf"))
	varsRaw, err2 := os.ReadFile(filepath.Join(modulePath, "variables.tf"))
	if err1 != nil || err2 != nil {
		return cr
	}
	mainContent := string(mainRaw)
	varsContent := string(varsRaw)

	for _, a := range info.Attributes {
		if a.Name == "id" {
			continue
		}
		cr.SchemaAttrCount++
		if strings.Contains(varsContent, fmt.Sprintf(`variable "%s"`, a.Name)) {
			cr.GeneratedAttrCount++
		} else {
			cr.MissingAttrs = append(cr.MissingAttrs, a.Name)
		}
	}

	for _, blk := range info.Blocks {
		cr.SchemaBlockCount++
		hasDynamic := strings.Contains(mainContent, fmt.Sprintf(`dynamic "%s"`, blk.Name))
		hasVar := strings.Contains(varsContent, fmt.Sprintf(`variable "%s"`, blk.Name))
		if hasDynamic && hasVar {
			cr.GeneratedBlockCount++
		} else {
			cr.MissingBlocks = append(cr.MissingBlocks, blk.Name)
		}
	}

	total := cr.SchemaAttrCount + cr.SchemaBlockCount
	matched := cr.GeneratedAttrCount + cr.GeneratedBlockCount
	if total > 0 {
		cr.CoveragePercent = float64(matched) / float64(total) * 100
	}
	return cr
}

// containsCountPattern checks for "count = local.enabled ? 1 : 0" regardless of whitespace alignment.
func containsCountPattern(content string) bool {
	for _, line := range strings.Split(content, "\n") {
		trimmed := strings.TrimSpace(line)
		normalized := strings.Join(strings.Fields(trimmed), " ")
		if normalized == "count = local.enabled ? 1 : 0" {
			return true
		}
	}
	return false
}

func fileExists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

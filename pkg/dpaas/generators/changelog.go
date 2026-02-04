package generators

import (
	"fmt"
	"time"

	"github.com/hashicorp/terraform-mcp-server/pkg/dpaas/schema"
)

func GenerateChangelog(info *schema.ResourceInfo) string {
	return fmt.Sprintf(`# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - %s

### Added
- Initial release of the Experian Azure %s Terraform module

### Security Features
`, time.Now().Format("2006-01-02"), info.DisplayName)
}

package schema

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	log "github.com/sirupsen/logrus"
)

const azurermProviderSource = "hashicorp/azurerm"

// ExtractResourceSchema fetches the full provider schema via the Terraform CLI,
// parses it, caches the result, and returns a generator-ready ResourceInfo.
func ExtractResourceSchema(resourceType string, logger *log.Logger) (*ResourceInfo, error) {
	if cached, err := LoadFromCache(resourceType); err == nil && cached != nil {
		logger.Infof("[dpaas] cache hit for %s", resourceType)
		return cached, nil
	}

	logger.Infof("[dpaas] extracting schema for %s via terraform CLI", resourceType)

	schemaJSON, err := fetchProviderSchema(logger)
	if err != nil {
		return nil, err
	}

	info, err := ParseTerraformSchema(schemaJSON, resourceType)
	if err != nil {
		return nil, err
	}

	if cacheErr := SaveToCache(resourceType, info); cacheErr != nil {
		logger.Warnf("[dpaas] cache write failed: %v", cacheErr)
	}
	return info, nil
}

// FetchAllResourceTypes returns every azurerm_* resource type known to the
// installed provider, optionally filtered by a substring.
func FetchAllResourceTypes(filter string, logger *log.Logger) ([]string, error) {
	if cached, err := LoadFullProviderCache(); err == nil && cached != nil {
		return ListResourceTypes(cached, filter)
	}

	logger.Info("[dpaas] fetching full azurerm provider schema …")
	schemaJSON, err := fetchProviderSchema(logger)
	if err != nil {
		return nil, err
	}

	if cacheErr := SaveFullProviderCache(schemaJSON); cacheErr != nil {
		logger.Warnf("[dpaas] full-provider cache write failed: %v", cacheErr)
	}
	return ListResourceTypes(schemaJSON, filter)
}

// ---------------------------------------------------------------------------

func fetchProviderSchema(logger *log.Logger) ([]byte, error) {
	tmp, err := os.MkdirTemp("", "dpaas-schema-*")
	if err != nil {
		return nil, fmt.Errorf("mkdirtemp: %w", err)
	}
	defer os.RemoveAll(tmp)

	providerHCL := fmt.Sprintf(`terraform {
  required_providers {
    azurerm = {
      source = "%s"
    }
  }
}
`, azurermProviderSource)

	if err := os.WriteFile(filepath.Join(tmp, "main.tf"), []byte(providerHCL), 0644); err != nil {
		return nil, fmt.Errorf("write provider config: %w", err)
	}

	logger.Info("[dpaas] running terraform init …")
	initCmd := exec.Command("terraform", "init", "-backend=false", "-no-color", "-input=false")
	initCmd.Dir = tmp
	if out, err := initCmd.CombinedOutput(); err != nil {
		return nil, fmt.Errorf("terraform init failed (is terraform installed and on PATH?): %w\n%s", err, string(out))
	}

	logger.Info("[dpaas] running terraform providers schema -json …")
	schemaCmd := exec.Command("terraform", "providers", "schema", "-json", "-no-color")
	schemaCmd.Dir = tmp
	out, err := schemaCmd.Output()
	if err != nil {
		return nil, fmt.Errorf("terraform providers schema: %w", err)
	}
	return out, nil
}

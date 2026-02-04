package schema

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"time"
)

const (
	cacheDirName         = ".dpaas-schema-cache"
	cacheMaxAge          = 7 * 24 * time.Hour
	fullProviderCacheKey = "_full_provider_schema.json"
)

type cacheEntry struct {
	ResourceType string        `json:"resource_type"`
	CachedAt     time.Time     `json:"cached_at"`
	Schema       *ResourceInfo `json:"schema"`
}

// ---------------------------------------------------------------------------

func resolveDir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	dir := filepath.Join(home, cacheDirName)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", err
	}
	return dir, nil
}

// SaveToCache persists a parsed ResourceInfo to disk.
func SaveToCache(resourceType string, info *ResourceInfo) error {
	dir, err := resolveDir()
	if err != nil {
		return err
	}

	data, err := json.MarshalIndent(cacheEntry{
		ResourceType: resourceType,
		CachedAt:     time.Now(),
		Schema:       info,
	}, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(dir, resourceType+".json"), data, 0644)
}

// LoadFromCache reads a cached ResourceInfo. Returns error when missing, unreadable, or expired.
func LoadFromCache(resourceType string) (*ResourceInfo, error) {
	dir, err := resolveDir()
	if err != nil {
		return nil, err
	}

	path := filepath.Join(dir, resourceType+".json")
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var entry cacheEntry
	if err := json.Unmarshal(raw, &entry); err != nil {
		os.Remove(path)
		return nil, fmt.Errorf("corrupted cache: %w", err)
	}
	if time.Since(entry.CachedAt) > cacheMaxAge {
		os.Remove(path)
		return nil, fmt.Errorf("cache expired")
	}
	return entry.Schema, nil
}

// SaveFullProviderCache persists the raw terraform providers schema -json bytes.
func SaveFullProviderCache(data []byte) error {
	dir, err := resolveDir()
	if err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(dir, fullProviderCacheKey), data, 0644)
}

// LoadFullProviderCache reads the raw cached provider schema bytes.
func LoadFullProviderCache() ([]byte, error) {
	dir, err := resolveDir()
	if err != nil {
		return nil, err
	}
	path := filepath.Join(dir, fullProviderCacheKey)

	stat, err := os.Stat(path)
	if err != nil {
		return nil, err
	}
	if time.Since(stat.ModTime()) > cacheMaxAge {
		os.Remove(path)
		return nil, fmt.Errorf("cache expired")
	}
	return os.ReadFile(path)
}

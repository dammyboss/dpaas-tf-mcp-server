#!/usr/bin/env bash
# Build cross-platform binaries and package for npm distribution.
# Usage: ./scripts/build-npm.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NPM_DIR="$REPO_ROOT/npm"
BIN_DIR="$NPM_DIR/bin"
VERSION=$(cat "$REPO_ROOT/version/VERSION")
REVISION=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo "unknown")
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

LDFLAGS="-s -w -X terraform-mcp-server/version.GitCommit=$REVISION -X terraform-mcp-server/version.BuildDate=$BUILD_DATE -X terraform-mcp-server/version.Version=$VERSION"

# Platforms to build: OS/ARCH pairs
PLATFORMS=(
  "darwin/amd64"
  "darwin/arm64"
  "linux/amd64"
  "linux/arm64"
  "windows/amd64"
)

echo "==> Building terraform-mcp-server v$VERSION for npm distribution"
echo "    Revision: $REVISION"
echo "    Date:     $BUILD_DATE"
echo ""

# Clean previous builds
rm -rf "$BIN_DIR"
mkdir -p "$BIN_DIR"

for platform in "${PLATFORMS[@]}"; do
  GOOS="${platform%/*}"
  GOARCH="${platform#*/}"
  ext=""
  if [ "$GOOS" = "windows" ]; then
    ext=".exe"
  fi

  output="$BIN_DIR/terraform-mcp-server-${GOOS}-${GOARCH}${ext}"
  echo "  Building $GOOS/$GOARCH -> $(basename "$output")"

  CGO_ENABLED=0 GOOS="$GOOS" GOARCH="$GOARCH" \
    go build \
      -ldflags "$LDFLAGS" \
      -trimpath \
      -buildvcs=false \
      -o "$output" \
      ./cmd/terraform-mcp-server

done

# Update version in package.json
if command -v node &>/dev/null; then
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('$NPM_DIR/package.json', 'utf8'));
    pkg.version = '$VERSION';
    fs.writeFileSync('$NPM_DIR/package.json', JSON.stringify(pkg, null, 2) + '\n');
  "
  echo ""
  echo "  Updated npm/package.json version to $VERSION"
fi

echo ""
echo "==> Build complete. Binaries in $BIN_DIR:"
ls -lh "$BIN_DIR"
echo ""
echo "To publish:"
echo "  cd npm && npm publish --registry <your-registry-url>"

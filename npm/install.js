#!/usr/bin/env node
"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");

const PLATFORM_MAP = {
  darwin: "darwin",
  linux: "linux",
  win32: "windows",
};

const ARCH_MAP = {
  x64: "amd64",
  arm64: "arm64",
};

const platform = PLATFORM_MAP[os.platform()];
const arch = ARCH_MAP[os.arch()];

if (!platform || !arch) {
  console.warn(
    `[terraform-mcp-server] Warning: unsupported platform ${os.platform()} ${os.arch()}`
  );
  process.exit(0);
}

const ext = platform === "windows" ? ".exe" : "";
const binaryName = `terraform-mcp-server-${platform}-${arch}${ext}`;
const binaryPath = path.join(__dirname, "bin", binaryName);

if (!fs.existsSync(binaryPath)) {
  console.error(
    `[terraform-mcp-server] Error: binary not found at ${binaryPath}\n` +
      `This package may not include a build for your platform (${os.platform()} ${os.arch()}).`
  );
  process.exit(1);
}

// Ensure the binary is executable (no-op on Windows)
if (platform !== "windows") {
  try {
    fs.chmodSync(binaryPath, 0o755);
  } catch (err) {
    console.warn(
      `[terraform-mcp-server] Warning: could not set executable permission: ${err.message}`
    );
  }
}

console.log(`[terraform-mcp-server] Installed for ${platform}-${arch}`);

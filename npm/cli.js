#!/usr/bin/env node
"use strict";

const { execFileSync } = require("child_process");
const path = require("path");
const os = require("os");

const PLATFORM_MAP = {
  darwin: "darwin",
  linux: "linux",
  win32: "windows",
};

const ARCH_MAP = {
  x64: "amd64",
  arm64: "arm64",
};

function getBinaryPath() {
  const platform = PLATFORM_MAP[os.platform()];
  const arch = ARCH_MAP[os.arch()];

  if (!platform || !arch) {
    console.error(
      `Unsupported platform: ${os.platform()} ${os.arch()}\n` +
        `Supported: darwin (amd64, arm64), linux (amd64, arm64), windows (amd64, arm64)`
    );
    process.exit(1);
  }

  const ext = platform === "windows" ? ".exe" : "";
  const binaryName = `terraform-mcp-server-${platform}-${arch}${ext}`;
  return path.join(__dirname, "bin", binaryName);
}

const binary = getBinaryPath();
const args = process.argv.slice(2);

try {
  const result = execFileSync(binary, args, {
    stdio: "inherit",
    env: process.env,
  });
  process.exit(0);
} catch (err) {
  if (err.status !== null) {
    process.exit(err.status);
  }
  console.error(`Failed to run terraform-mcp-server: ${err.message}`);
  process.exit(1);
}

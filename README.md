# DPaaS Terraform MCP Server

[![Go](https://img.shields.io/badge/Built%20with-Go-00ADD8?style=flat&logo=go)](https://go.dev/)
[![Terraform](https://img.shields.io/badge/Terraform-Module%20Generator-7B42BC?style=flat&logo=terraform)](https://www.terraform.io/)
[![MCP](https://img.shields.io/badge/Protocol-MCP-blue?style=flat)](https://modelcontextprotocol.io/)
[![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4?style=flat&logo=microsoftazure)](https://azure.microsoft.com/)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?style=flat&logo=github)](https://github.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Damilola_Onadeinde-0077B5?style=flat&logo=linkedin)](https://linkedin.com/in/damilola-onadeinde)
[![YouTube](https://img.shields.io/badge/YouTube-DevOps_with_Dami-FF0000?style=flat&logo=youtube)](https://youtube.com/@devopswithdami)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support%20My%20Work-orange?style=flat&logo=buymeacoffee)](https://buymeacoffee.com/devopswithdami)

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction) server that generates DPaaS innersource Terraform modules for Azure resources. Powered by AI coding assistants, it dynamically extracts provider schemas, fetches documentation-driven enum values, and produces production-ready Terraform modules that follow DPaaS conventions.

## How It Works

```
You (AI prompt) ──> MCP Client ──> DPaaS MCP Server ──> Terraform Provider Schema
                                                     ──> Azure Provider Docs
                                                     ──> Generated Module Output
```

1. You describe the Azure resource you want (e.g., "Generate a DPaaS module for azurerm_storage_account")
2. The MCP server extracts the full resource schema from the Terraform provider
3. Enum values and descriptions are fetched from the official Azure provider documentation
4. A complete, production-ready module is generated following DPaaS conventions

## Features

- **Dynamic Schema Extraction** — Generates modules from live Terraform provider schemas, not templates
- **Documentation-Driven Enums** — Fetches enum values and descriptions from official Azure provider docs
- **DPaaS Convention Compliant** — Output follows innersource module structure with null-label integration
- **Multiple Test Scenarios** — Generate `default`, `complete`, and `disabled` test cases
- **No Hardcoded Values** — Everything is derived dynamically from the schema and documentation
- **Cross-Platform** — Available as npm package (macOS, Linux, Windows), Docker image, or local binary
- **Multi-Client Support** — Works with Claude Desktop, Amazon Q, VS Code, Cursor, and any MCP-compatible client

## Generated Module Structure

```
expn-tf-azure-{resource}/
  main.tf              # Resource definition with all attributes
  variables.tf         # Typed variables with descriptions and enum validations
  outputs.tf           # Standard outputs (id, name, resource group)
  locals.tf            # Local values and naming
  versions.tf          # Provider and Terraform version constraints
  context.tf           # Null-label context integration
  CHANGELOG.md         # Initial changelog
  README.md            # Module documentation
  .gitignore           # Standard ignores
  .pre-commit-config.yaml
  tests/
    default/           # Required attributes only
      main.tf
      versions.tf
    complete/          # All attributes and blocks populated
      main.tf
      versions.tf
    disabled/          # Module with enabled = false
      main.tf
      versions.tf
```

## Prerequisites

- **Go** (1.22+) — If building from source
- **Terraform** — Required for schema extraction (`terraform providers schema -json`)
- **Node.js** (v16+) — If installing via npm
- **Docker** — If using the Docker image (Terraform included in image)

## Installation

### Option 1: npm Package (Recommended)

Install from Azure DevOps Artifacts feed:

1. Add the scoped registry to your `~/.npmrc`:
```
@dpaas:registry=https://pkgs.dev.azure.com/<ORGANIZATION>/<PROJECT>/_packaging/<FEED>/npm/registry/
```

2. Set up authentication in `~/.npmrc` (see [Azure DevOps Artifacts docs](https://learn.microsoft.com/en-us/azure/devops/artifacts/npm/npmrc)):
```
; begin auth token
//pkgs.dev.azure.com/<ORGANIZATION>/<PROJECT>/_packaging/<FEED>/npm/registry/:username=<YOUR_USERNAME>
//pkgs.dev.azure.com/<ORGANIZATION>/<PROJECT>/_packaging/<FEED>/npm/registry/:_password=<BASE64_ENCODED_PAT>
//pkgs.dev.azure.com/<ORGANIZATION>/<PROJECT>/_packaging/<FEED>/npm/registry/:email=npm requires email to be set but doesn't use the value
//pkgs.dev.azure.com/<ORGANIZATION>/<PROJECT>/_packaging/<FEED>/npm/:username=<YOUR_USERNAME>
//pkgs.dev.azure.com/<ORGANIZATION>/<PROJECT>/_packaging/<FEED>/npm/:_password=<BASE64_ENCODED_PAT>
//pkgs.dev.azure.com/<ORGANIZATION>/<PROJECT>/_packaging/<FEED>/npm/:email=npm requires email to be set but doesn't use the value
; end auth token
```

3. Verify installation:
```bash
npx @dpaas/terraform-mcp-server --version
```

### Option 2: Docker

```bash
git clone <REPO_URL>
cd dpaas-tf-mcp-server
docker build --target=dpaas -t terraform-mcp-dpaas .
```

> Terraform is included in the Docker image — no local Terraform installation required.

### Option 3: Build from Source

```bash
git clone <REPO_URL>
cd dpaas-tf-mcp-server
make build
```

Binary will be at `bin/terraform-mcp-server`.

## MCP Client Configuration

### Claude Desktop / Amazon Q Developer

Add to your MCP client config (`claude_desktop_config.json` or equivalent):

**npm:**
```json
{
  "mcpServers": {
    "terraform-dpaas": {
      "command": "npx",
      "args": ["-y", "@dpaas/terraform-mcp-server", "stdio"]
    }
  }
}
```

**Docker:**
```json
{
  "mcpServers": {
    "terraform-dpaas": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-v", "/path/to/output:/output",
        "terraform-mcp-dpaas"
      ]
    }
  }
}
```

**Local binary:**
```json
{
  "mcpServers": {
    "terraform-dpaas": {
      "command": "/path/to/bin/terraform-mcp-server",
      "args": ["stdio"]
    }
  }
}
```

### VS Code

Add to your User Settings (JSON) or `.vscode/mcp.json`:

```json
{
  "mcp": {
    "servers": {
      "terraform-dpaas": {
        "command": "npx",
        "args": ["-y", "@dpaas/terraform-mcp-server", "stdio"]
      }
    }
  }
}
```

### Claude Code

```bash
claude mcp add terraform-dpaas -s user -t stdio -- npx -y @dpaas/terraform-mcp-server stdio
```

## Usage

Once connected to your MCP client, use natural language prompts:

### Generate a module (default test only)
> "Generate a DPaaS Terraform module for azurerm_storage_account in /path/to/output"

### Generate with specific test scenarios
> "Generate a DPaaS Terraform module for azurerm_storage_account. Set test_scenarios to 'default,complete,disabled'"

### Generate with all test scenarios
> "Generate a DPaaS Terraform module for azurerm_load_test. Set test_scenarios to 'default,complete,disabled'"

### Test Scenarios

| Scenario | Description |
|----------|-------------|
| `default` | Only required attributes and blocks — validates the minimum viable configuration |
| `complete` | All attributes and blocks populated with example values — validates full resource coverage |
| `disabled` | Module with `enabled = false` — validates the module can be cleanly disabled |

## Available MCP Tools

| Tool | Description |
|------|-------------|
| `dpaas_generate_module` | Generate a complete DPaaS Terraform module for an Azure resource |
| `dpaas_extract_schema` | Extract and view the raw Terraform provider schema for a resource |
| `dpaas_list_resources` | List available Azure resources from the Terraform provider |
| `dpaas_validate_module` | Run `terraform validate` on a generated module |

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TRANSPORT_MODE` | Transport mode: `stdio` or `streamable-http` | `stdio` |
| `TRANSPORT_HOST` | Host to bind the HTTP server | `127.0.0.1` |
| `TRANSPORT_PORT` | HTTP server port | `8080` |
| `MCP_ENDPOINT` | HTTP server endpoint path | `/mcp` |

## Development

### Build Commands

| Command | Description |
|---------|-------------|
| `make build` | Build the binary for your platform |
| `make npm-build` | Build cross-platform binaries for npm package |
| `make npm-publish NPM_REGISTRY=<url>` | Build and publish npm package |
| `make docker-build` | Build Docker image |
| `make test` | Run all tests |
| `make clean` | Remove build artifacts |
| `make help` | Show all available commands |

### Publishing a New Version

```bash
# Build cross-platform binaries and publish to Azure DevOps Artifacts
make npm-build
cd npm && npm publish
```

### Project Architecture

```
pkg/
  dpaas/
    schema/           # Schema extraction, docs fetcher, types
    generators/       # File generators (main.tf, variables.tf, tests, etc.)
    templates/        # Static template files (null-label, versions, etc.)
    validation/       # Terraform validate wrapper
  tools/
    dpaas/            # MCP tool handlers
cmd/
  terraform-mcp-server/  # Entry point and CLI setup
npm/                  # npm package wrapper (cli.js, install.js)
scripts/              # Build scripts (build-npm.sh)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## About the Developer

**Damilola Onadeinde**
*DevOps/AI Engineer | Cloud Infrastructure Specialist | Open Source Contributor*

Connect with me:

<a href="https://github.com"><img src="https://img.icons8.com/fluent/48/000000/github.png" alt="GitHub" width="40"/></a>
<a href="https://linkedin.com/in/damilola-onadeinde"><img src="https://img.icons8.com/fluent/48/000000/linkedin.png" alt="LinkedIn" width="40"/></a>
<a href="https://devopswithdami.com"><img src="https://img.icons8.com/fluent/48/000000/domain.png" alt="Portfolio" width="40"/></a>
<a href="https://youtube.com/@devopswithdami"><img src="https://img.icons8.com/fluent/48/000000/youtube-play.png" alt="YouTube" width="40"/></a>

## Support the Developer

If you find this project helpful and would like to support my work, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support%20My%20Work-orange?style=for-the-badge&logo=buymeacoffee)](https://buymeacoffee.com/devopswithdami)

Your support helps me continue creating open-source tools and improving this project!

## License

This project is licensed under the terms of the MPL-2.0 open source license. Please refer to [LICENSE](./LICENSE) for the full terms.

# DPaaS Terraform MCP Server — Presentation Guide

---

## SLIDE 1: Title
**AI-Powered Terraform Module Generation with MCP**
- Subtitle: "From Prompt to Production-Ready Infrastructure Code"
- Presenter: Damilola Onadeinde — DevOps/AI Engineer
- Date: February 2026

### Speech:
> "Good [morning/afternoon] everyone, thank you for being here. Today I'm going to show you something that I'm genuinely excited about — a tool that takes one of our most repetitive tasks as a DPaaS team and turns it into a single AI prompt. By the end of this session, you'll see a complete, production-ready Terraform module generated in under 30 seconds. Let's dive in."

---

## SLIDE 2: The Problem
**Writing DPaaS Terraform modules is painful**

- 10-16 files per module, all must follow DPaaS conventions
- Azure resources have 20-300+ attributes (Application Gateway: 186!)
- Enum values scattered across provider docs — easy to miss
- Manual process: **2-4 hours** per module for complex resources
- Hard to enforce consistency across teams

### Speech:
> "Let's start with the problem we all know too well. Every time we need a new DPaaS innersource Terraform module, someone has to manually create 10 to 16 files — main.tf, variables.tf, tests, the null-label integration, tagging, naming conventions — the list goes on. For a complex resource like Application Gateway with 186 attributes, that's easily 2 to 4 hours of work. And that's assuming you don't miss any attributes or get the enum values wrong. Multiply that across every Azure resource we support, and it's a significant time sink. So I asked myself — what if AI could do this for us?"

---

## SLIDE 3: The Solution
**DPaaS Terraform MCP Server**

- One AI prompt = one fully validated, production-ready module
- Built on the **Model Context Protocol (MCP)** — works with any AI assistant
- No hardcoded values — everything derived dynamically from the live provider schema
- **Before:** 2-4 hours of manual work
- **After:** 30 seconds, fully validated

### Speech:
> "The solution is the DPaaS Terraform MCP Server. It's a tool that plugs into any AI assistant — Claude, Copilot, Amazon Q, you name it — and gives it the ability to generate complete DPaaS Terraform modules. You type a prompt like 'Generate a DPaaS module for Azure Storage Account,' and in about 30 seconds, you have a fully validated module with all the files, all the attributes, all the test scenarios, ready for a pull request. No hardcoded values. Everything is pulled dynamically from the live Terraform provider schema and official Azure documentation."

---

## SLIDE 4: How It Works
**4-Step Pipeline**

```
Prompt: "Generate a DPaaS module for azurerm_application_gateway"
                              |
         Step 1: Extract schema from Terraform provider
         Step 2: Fetch enum values & descriptions from Azure docs
         Step 3: Generate all files (main.tf, variables.tf, tests, etc.)
         Step 4: Validate — terraform fmt + 22-point DPaaS compliance check
                              |
              Output: expn-tf-azure-application-gateway/
              22/22 checks passed | 100% argument coverage
```

### Speech:
> "Here's what happens under the hood when you run that prompt. Step one — we extract the full resource schema from the Terraform provider. Every attribute, every block, every nesting mode. Step two — we fetch enum values and descriptions from the official Azure provider documentation on GitHub. This is important because the provider schema alone doesn't include enum constraints — we parse them from the docs. Step three — we generate all the files: main.tf with the count pattern and dynamic blocks, variables.tf with typed variables and enum validations, three test scenarios, and all the supporting files. Step four — we run terraform fmt for formatting and a 22-point DPaaS compliance check. The result? A module that passes every standard we have."

---

## SLIDE 5: MCP Tools for the DPaaS Team
**What the MCP Server Exposes**

| Tool | What It Does | How It Helps DPaaS |
|------|-------------|-------------------|
| `dpaas_generate_module` | Generates a complete innersource module for any Azure resource | Eliminates hours of boilerplate — the core workflow |
| `dpaas_extract_schema` | Extracts and displays the raw Terraform provider schema | Quickly inspect any resource's attributes and blocks without digging through docs |
| `dpaas_list_resources` | Lists all available Azure resources from the provider | Discover what resources are available before generating |
| `dpaas_validate_module` | Runs `terraform validate` on a generated module | Catch errors immediately — no manual terminal work |

### Speech:
> "The MCP server isn't just one tool — it exposes four tools that help the DPaaS team at different stages. The main one is the module generator — that's the core workflow that eliminates hours of boilerplate. But we also have a schema extractor, so if you just want to quickly see what attributes a resource has without digging through documentation, you can ask the AI and it pulls the schema instantly. There's a resource lister so you can discover available Azure resources before you generate. And finally, there's a validate tool that runs terraform validate directly — so you can catch errors without leaving your AI assistant. Together, these tools give the team a complete Terraform development workflow powered by AI."

---

## SLIDE 6: Live Demo
**Let's see it in action**

### Demo Flow:

**Demo 1 — Simple Resource (2 min)**
1. Open AI client (Azure AI Toolkit / Claude Desktop)
2. Prompt: *"Generate a DPaaS Terraform module for azurerm_traffic_manager_profile with test scenarios default, complete, disabled"*
3. Show: 22/22 checks passed, 100% coverage
4. Quickly open main.tf, variables.tf, tests/default/main.tf

**Demo 2 — Complex Resource (3 min)**
1. Prompt: *"Generate a DPaaS Terraform module for azurerm_application_gateway with all test scenarios"*
2. Show: 22/22 passed, 100% coverage (9 attrs, 25 blocks)
3. Open tests/complete/main.tf — highlight realistic values: `port = 443`, `sku.name = "Basic"`, proper Azure resource IDs
4. Run live: `terraform init -backend=false && terraform validate` → "Success!"

### Speech (before demo):
> "Enough slides — let me show you the real thing. I'm going to generate two modules live. First, a simple one — Traffic Manager Profile — to show the happy path. Then, the real test — Application Gateway, one of the most complex resources in Azure with 186 attributes and 25 nested blocks. Let's see if it can handle it."

### Speech (after demo):
> "So what you just saw — a complete, validated, production-ready module for one of Azure's most complex resources, generated in under 30 seconds. Every attribute covered. Every DPaaS convention followed. Every test scenario included. And I didn't write a single line of Terraform."

---

## SLIDE 7: Impact
**What This Means for the Team**

| Metric | Before | After |
|--------|--------|-------|
| Time per module | 2-4 hours | **30 seconds** |
| Attributes missed | Common | **0% — 100% coverage** |
| Convention compliance | Manual review | **Automated (22 checks)** |
| Enum values | Manually looked up | **Auto-fetched from docs** |
| Test scenarios | Often skipped | **Always generated** |
| Consistency | Variable | **Guaranteed** |

### Speech:
> "Let me put some numbers on what this means. We went from 2 to 4 hours per module to 30 seconds. From commonly missing attributes to guaranteed 100% coverage. From manual compliance reviews to automated 22-point checks. Test scenarios that used to get skipped are now always generated. And most importantly — every module that comes out of this tool follows the exact same DPaaS conventions. No more inconsistency across teams. This isn't just a productivity tool — it's a quality tool."

---

## SLIDE 8: Get Started & What's Next
**Available today — here's how to use it**

**Setup (one-time):**
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

**Works with:** Claude Desktop, Claude Code, VS Code, Cursor, Amazon Q, Azure AI Toolkit

**What's next:**
- Support for AWS and GCP providers
- Module update/diff tool — regenerate and show what changed
- CI/CD integration — auto-generate on provider version bumps

### Speech:
> "This is available today. Setup is a one-time config — you add a few lines to your AI client's MCP configuration, and you're ready to go. It works with Claude Desktop, VS Code, Cursor, Amazon Q, Azure AI Toolkit — basically any AI tool that supports the MCP protocol. Looking ahead, we're planning to extend this to AWS and GCP providers, add a module diff tool so you can regenerate and see what changed, and eventually integrate this into our CI/CD pipelines so modules stay up to date automatically when the provider releases new versions."

---

## SLIDE 9: Q&A
**Questions?**

- GitHub: github.com/dammyboss/dpaas-tf-mcp-server
- LinkedIn: linkedin.com/in/damilola-onadeinde
- YouTube: youtube.com/@devopswithdami

### Speech:
> "That's it. One prompt, one module, fully validated, every time. I'm happy to take any questions. And if you want to try it out yourself, the repo link is right here — feel free to reach out if you need help getting set up."

---

## PREPARATION CHECKLIST

### Before the presentation:
- [ ] Binary rebuilt: `go build -o terraform-mcp ./cmd/terraform-mcp-server/`
- [ ] AI client configured and MCP server connected
- [ ] Terminal ready for `terraform validate`
- [ ] Clean output directory (delete previously generated modules)
- [ ] Internet connection working (for docs fetching)
- [ ] Terraform installed and on PATH
- [ ] Backup screen recording ready in case of live demo issues

### Timing Guide (Target: 12-15 minutes)
| Section | Duration |
|---------|----------|
| Slides 1-4 (Problem → Solution → How it works) | 4-5 min |
| Slide 5 (MCP Tools) | 1-2 min |
| Slide 6 (Live Demo) | 5-6 min |
| Slides 7-9 (Impact → Get Started → Q&A) | 2-3 min |

### Handling Questions
- **"Why not use Terraform Registry modules?"** → "Registry modules are opinionated and fixed. This generates modules from YOUR conventions, for ANY Azure resource."
- **"What if the provider schema changes?"** → "We read the live schema every time. No templates to maintain."
- **"How accurate are the enum values?"** → "They come directly from the official HashiCorp provider docs on GitHub."
- **"Does it work offline?"** → "Schema extraction works offline. Enum fetching needs internet but is non-blocking — the module still generates without it."

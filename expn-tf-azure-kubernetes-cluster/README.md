# EITS Cloud Enablement Azure Kubernetes Cluster Module

EITS Terraform module which creates [Azure Kubernetes Cluster] resources. This module will:

- Deploy Azure Kubernetes Cluster with configurable options
- Support both custom naming and auto-generated names using null-label
- Apply standardized tagging and security policies
- Support conditional resource creation

See CHANGELOG.md for the list of changes for each release.
*We highly recommend that in your code you pin the version to the exact version you are using so that your infrastructure remains stable, and update versions in a systematic way so that they do not catch you by surprise.*

## Notes

- Null-label naming convention support for standardized resource names
- Conditional resource creation using `create_kubernetes_cluster` parameter
- Standardized DPaaS tagging applied automatically

## EITS Security & Compliance

**Last Module Review**: 2026-02-05

See below for the date and results of our EITS security and compliance scanning.

<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description |
| --------- | ---- | ------- | ----------- |
| [![tflint](https://img.shields.io/badge/tflint-passed-green)]() | 2026-02-05 | 0.58.1 | Enforces best practices, syntax, naming conventions |
| [![trivy](https://img.shields.io/badge/trivy-passed-green)]() | 2026-02-05 | 0.61.0 | Detects misconfiguration in IaC files, such as Docker, Terraform, etc |
| [![checkov](https://img.shields.io/badge/checkov-passed-green)]() | 2026-02-05 | 3.2.464 | Deeper tfplan scanning for security and compliance issues |
| [![wiz](https://img.shields.io/badge/wiz.io_iac-passed-green)]() | 2026-02-05 | 0.84.0 | Scans tests directory plans for vulnerabilities and risks |
<!-- END_BENCHMARK_TABLE -->

## Usage

```hcl
module "kubernetes_cluster" {
  source = "git::https://code.experian.local/scm/DPAAS/expn-tf-azure-kubernetes-cluster.git"

  create_kubernetes_cluster = true
  enabled            = true

  namespace   = "expn"
  tenant      = "msp"
  environment = "sbx"
  name        = "sample"

  location            = "East US 2"
  resource_group_name = "example-rg"

  tags = {
    CostString  = "0000.111.11.22"
    AppID       = "0"
    Environment = "sbx"
  }
}
```

## Contact

For advice or to report an issue, either email the EITS Cloud Enablement team <eitsukicloud@experian.com> or post in the [Terraform Modules Teams Channel](https://teams.microsoft.com/l/channel/19%3a8c4faa258cd54d2687caa746f71ae050%40thread.tacv2/Terraform%2520Modules?groupId=c08d819b-fd4a-44e1-98f1-225d1bb48b31&tenantId=be67623c-1932-42a6-9d24-6c359fe5ea71)

## Acknowledgments

Thanks to the Data Platform and Analytics team for the module development. This module follows EITS cloud enablement standards and best practices.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

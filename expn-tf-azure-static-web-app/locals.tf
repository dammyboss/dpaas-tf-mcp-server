# Helper locals to make the dynamic block more readable
# There are three attributes here to cater for resources that
locals {

  dpaas_tags = {
    "innersource"      = "DPaaS"
    "innersource-repo" = "git::https://code.experian.local/scm/DPAAS/expn-tf-azure-static-web-app.git//"
  }

  tags = merge(try(var.tags, {}), local.dpaas_tags)

  enabled = module.this.enabled && var.create_static_web_app

}

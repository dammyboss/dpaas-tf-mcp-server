module "label1" {
  source      = "./../../"
  namespace   = "test"
  tenant      = ""
  environment = "sbx"
  stage       = "test"
  name        = "LabelTest1"
  attributes  = ["fire", "water", "earth", "air"]

  label_order = ["name", "tenant", "environment", "stage", "attributes"]

  tags = {
    "CostString"  = "0000.000.00.00"
    "AppID"       = "0000"
    "Environment" = "sbx"
  }
}

module "label1t1" {
  source = "../../"

  id_length_limit = 32

  context = module.label1.context
}

module "label1t2" {
  source = "../../"

  id_length_limit = 33

  context = module.label1.context
}
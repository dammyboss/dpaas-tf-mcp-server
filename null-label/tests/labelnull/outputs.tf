output "label1" {
  value = {
    id         = module.label1.id
    name       = module.label1.name
    namespace  = module.label1.namespace
    stage      = module.label1.stage
    tenant     = module.label1.tenant
    attributes = module.label1.attributes
    delimiter  = module.label1.delimiter
  }
  description = "label 1 list values"
}

output "label1_tags" {
  value       = module.label1.tags
  description = "label 1 tags"
}

output "label1_context" {
  value       = module.label1.context
  description = "label 1 context"
}

output "label1_normalized_context" {
  value       = module.label1.normalized_context
  description = "label 1 normalized_context"
}

output "label1t1" {
  value = {
    id      = module.label1t1.id
    id_full = module.label1t1.id_full
  }
  description = "label 1t ID"
}
output "label1t1_tags" {
  value       = module.label1t1.tags
  description = "label 1t tags"
}

output "label1t2" {
  value = {
    id      = module.label1t2.id
    id_full = module.label1t2.id_full
  }
  description = "label 1t2 ID"
}

output "label1t2_tags" {
  value       = module.label1t2.tags
  description = "label 1t2 tags"
}

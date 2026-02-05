# outputs.tf
output "id" {
  description = "The ID of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this
}

output "current_kubernetes_version" {
  description = "The current kubernetes version of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].current_kubernetes_version
}

output "fqdn" {
  description = "The fqdn of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].fqdn
}

output "http_application_routing_zone_name" {
  description = "The http application routing zone name of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].http_application_routing_zone_name
}

output "kube_admin_config" {
  description = "The kube admin config of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].kube_admin_config
}

output "kube_admin_config_raw" {
  description = "The kube admin config raw of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].kube_admin_config_raw
}

output "kube_config" {
  description = "The kube config of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].kube_config
}

output "kube_config_raw" {
  description = "The kube config raw of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].kube_config_raw
}

output "node_resource_group_id" {
  description = "The node resource group id of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].node_resource_group_id
}

output "oidc_issuer_url" {
  description = "The oidc issuer url of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].oidc_issuer_url
}

output "portal_fqdn" {
  description = "The portal fqdn of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].portal_fqdn
}

output "private_fqdn" {
  description = "The private fqdn of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this[*].private_fqdn
}

output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "vnet_name" {
  value = module.vnet.vnet_name
}

output "aks_subnet_id" {
  value = module.vnet.aks_subnet_id
}

output "acr_name" {
  value = module.acr.acr_name
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "aks_cluster_name" {
  value = module.aks.aks_cluster_name
}

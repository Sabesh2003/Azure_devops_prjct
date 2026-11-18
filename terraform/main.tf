module "resource_group" {
  source = "./modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
}

module "vnet" {
  source = "./modules/vnet"

  vnet_name           = var.vnet_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
}

module "acr" {
  source = "./modules/acr"

  acr_name            = var.acr_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
}

module "aks" {
  source = "./modules/aks"

  aks_name            = var.aks_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  subnet_id           = module.vnet.aks_subnet_id
  acr_id              = module.acr.acr_id

  system_node_vm_size = var.system_node_vm_size
  user_node_vm_size   = var.user_node_vm_size
  system_node_count   = var.system_node_count
  user_node_count     = var.user_node_count
}

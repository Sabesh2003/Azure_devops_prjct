resource "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.aks_name}-dns"
  sku_tier            = "Free"

  default_node_pool {
    name           = "system"
    vm_size        = var.system_node_vm_size
    node_count     = var.system_node_count
    vnet_subnet_id = var.subnet_id
    type           = "VirtualMachineScaleSets"
    os_sku         = "Ubuntu"
  }

  identity { type = "SystemAssigned" }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = "10.22.0.0/16"
    service_cidr        = "10.21.0.0/24"
    dns_service_ip      = "10.21.0.10"
    outbound_type       = "loadBalancer"
    load_balancer_sku   = "standard"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_node_vm_size
  node_count            = var.user_node_count
  mode                  = "User"
  vnet_subnet_id        = var.subnet_id
  os_type               = "Linux"
  os_sku                = "Ubuntu"
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.this]
}

# 1. Output Values - Resource Group
output "resource_group_id" {
  description = "Resource Group ID"
  # Atrribute Reference
  value = azurerm_resource_group.main.id
}
output "resource_group_name" {
  description = "Resource Group name"
  # Argument Reference
  value = azurerm_resource_group.main.name
}

# 2. Output Values - Virtual Network Name
output "virtual_network_name" {
  description = "Virutal Network Name"
  value = azurerm_virtual_network.main.name
}
# 3. Output Values - Virtual Network Location
output "virtual_network_location" {
  description = "Virutal Network Location"
  value = azurerm_virtual_network.main.location
}

output "subnet_group_name" {
  description = "Subnet name"
  # Argument Reference
  value = azurerm_subnet.main.name
}

output "azurerm_virtual_machine" {
  description = "azurerm_virtual_machine name"
  # Argument Reference
  value = azurerm_virtual_machine.main[*].name
}
output "Network_interface_name" {
  description = "network_interface name"
  # Argument Reference
  value = azurerm_network_interface.main[*].name
}
output "public_ip_name" {
  description = "public_ip"
  # Argument Reference
  value = azurerm_public_ip.main.name
}
output "Load_balancer_name" {
  description = "Load_balancer_name"
  # Argument Reference
  value = azurerm_lb.main.name
}
output "lb_backend_address_pool_name" {
  description = "azurerm_lb_backend_address_pool name"
  # Argument Reference
  value = azurerm_lb_backend_address_pool.main.name
}

output "availset_name" {
  description = "availset name"
  # Argument Reference
  value = azurerm_availability_set.availset.name
}

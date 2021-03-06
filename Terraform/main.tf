provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "main" {
  count               = var.num_of_vms
  name                = "${var.prefix}-nic${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "mainConfiguration"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}
resource "azurerm_network_interface_security_group_association" "main" {
  count                     = var.num_of_vms
  network_interface_id      = azurerm_network_interface.main[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_public_ip" "main" {

  depends_on = [
    azurerm_virtual_network.main,
    azurerm_subnet.main
  ]
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags
}
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main" {
  #resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.num_of_vms
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "mainConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}
resource "azurerm_availability_set" "availset" {
  name                         = "availset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

data "azurerm_resource_group" "packer_rg" {
  name = var.packer_resource_group
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.packer_rg.name
}


output "image_id" {
  value = "/subscriptions/522b5d75-2fbe-4fb5-b2d5-6c15a215feca/resourceGroups/RG-EASTUS-SPT-PLATFORM/providers/Microsoft.Compute/images/myPackerImagePK"
}
resource "azurerm_virtual_machine" "main" {
  depends_on = [
    azurerm_virtual_network.main,
    azurerm_subnet.main
  ]
  count                 = var.num_of_vms
  name                  = "${var.prefix}${count.index}-vm"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  availability_set_id   = azurerm_availability_set.availset.id
  vm_size               = "Standard_F2"
  network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]

  storage_image_reference {
    id = data.azurerm_image.image.id
  }


  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  storage_os_disk {
    name              = "WSdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  tags = var.tags
}
resource "azurerm_managed_disk" "external" {
  count                = var.num_of_vms
  name                 = "${var.prefix}-disk${count.index + 1}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}
resource "azurerm_virtual_machine_data_disk_attachment" "external" {
  count              = var.num_of_vms
  managed_disk_id    = azurerm_managed_disk.external.*.id[count.index]
  virtual_machine_id = azurerm_virtual_machine.main[count.index].id
  lun                = 10 + count.index
  caching            = "ReadWrite"
}
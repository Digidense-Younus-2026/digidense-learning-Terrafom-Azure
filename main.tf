# =====================================================
# 1. Resource Group
# =====================================================
resource "azurerm_resource_group" "rg1" {
  location = "eastus2"
  name     = "dev-rg-2"
}
/*data "azurerm_subscription" "main" {
  subscription_id = "4ffc4be1-d195-4e71-aa14-07e148042f6c"
}
resource "azuread_user" "user1" {
  display_name          = "infra Dev"
  user_principal_name   = "infra_dev@devoteymgmail.onmicrosoft.com"
  password              = "P@ssw0rd123"
  force_password_change = true
}

resource "azuread_user" "user2" {
  display_name          = "App Dev"
  user_principal_name   = "app_dev@devoteymgmail.onmicrosoft.com"
  password              = "P@ssw0rd234"
  force_password_change = true
}

resource "azuread_group" "Group1" {
  display_name     = "SRE"
  security_enabled = true
  mail_enabled     = false
  members = [
    azuread_user.user1.object_id,
  azuread_user.user2.object_id]
}
resource "azurerm_role_assignment" "role_attachment" {
  principal_id         = azuread_group.Group1.object_id
  scope                = data.azurerm_subscription.main.id
  role_definition_name = "Reader"
}*/
# =====================================================
# 2. Virtual Network
# =====================================================
resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  name                = "azure-vm-net"
  resource_group_name = azurerm_resource_group.rg1.name
}

# =====================================================
# 3. Subnet
# =====================================================
resource "azurerm_subnet" "subnet1" {
  name                 = "azure-vm-subnet1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
# =====================================================
# 4. Public IP Address
# =====================================================
resource "azurerm_public_ip" "public_ip" {
  name                = "Azure-vm-public-ip"
  allocation_method   = "Static"
  location            = "azurerm_resource_group.rg1.location"
  resource_group_name = azurerm_resource_group.rg1.name
  sku = "Standard"
}
# =====================================================
# 5. Network Security Group
# =====================================================
resource "azurerm_network_security_group" "nsg" {
  name                = "azure-vm-nsg"
  location            = "azurerm_resource_group.rg1.location"
  resource_group_name = azurerm_resource_group.rg1.name
  security_rule {
    name = "Allow-SSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = var.admin_source_ip
    destination_address_prefix = "*"

  }
}

# =====================================================
# 6. Network Interface
# =====================================================
resource "azurerm_network_interface" "nic" {
  location            = azurerm_resource_group.rg1.location
  name                = "azurerm-vm-nic"
  resource_group_name = azurerm_resource_group.rg1.name
  ip_configuration {
    name                          = "internal"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id

  }
}
# =====================================================
# 7. Associate NSG with Network Interface
# =====================================================
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# =====================================================
# 8. Linux Virtual Machine
# =====================================================
resource "azurerm_linux_virtual_machine" "mainvm" {
  name                = var.vm_name
  computer_name       = var.vm_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  admin_username      = var.admin_username
  location            = azurerm_resource_group.rg1.location
  size                = var.vm_size
  # Network Interface Association
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  # Disable Password Authentication
  disable_password_authentication = true

  # SSH Public Key Authentication
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  # Operating System Disk
  os_disk {
    name                 = "linux-vm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu 22.04 LTS Image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Boot Diagnostics
  boot_diagnostics {}
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  type    = string
  default = "dev-rg-2"
}

variable "vm_name" {
  type    = string
  default = "Webserver-linux"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2als_v7"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

# variable "admin_source_ip" {
#   description = "Your public IP address in CIDR format"
#   type        = string
# }

variable "ssh_public_key_path" {
  type    = string
  default = "C:\\Users\\HP\\.ssh\\id_ed25519.pub"
}
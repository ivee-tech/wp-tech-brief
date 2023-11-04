variable "AKS_VNET" {
  type        = string
  description = "This is the vnet name"
}

variable "AKS_VNET_SUBNET" {
  type        = string
  description = "This is the subnet name"
}

variable "AKS_VNET_ADDRESS_PREFIX" {
  type        = list(string)
  description = "This is the vnet address prefix"
}

variable "AKS_VNET_SUBNET_PREFIX" {
  type        = string
  description = "This is the subnet address prefix"
}


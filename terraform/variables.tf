variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "Central India"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-employee-attendance"
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string
  default     = "vnet-employee-attendance"
}

variable "acr_name" {
  description = "Globally unique ACR name (5-50 alphanumeric characters)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 alphanumeric characters only."
  }
}

variable "aks_name" {
  description = "AKS cluster name."
  type        = string
  default     = "aks-employee-attendance"
}

variable "system_node_vm_size" {
  description = "System node VM size."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "user_node_vm_size" {
  description = "User node VM size."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "system_node_count" {
  description = "Initial system node count."
  type        = number
  default     = 1
}

variable "user_node_count" {
  description = "Initial user node count."
  type        = number
  default     = 1
}

variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "resource_group_name" {}

variable "vnet_subnet_id" {}

variable "pod_subnet_id" {}

variable "spotPod_subnet_id" {}

variable "mi_aks_cp_id" {}

# variable "mi_aks_kubelet_id" {
  
# }

variable "la_id" {}

variable "private_dns_zone_id" {}
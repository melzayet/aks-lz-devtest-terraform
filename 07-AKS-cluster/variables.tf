#############
# VARIABLES #
#############

variable "prefix" {}

variable "state_sa_name" {}

variable "container_name" {}

variable "access_key" {}

variable "private_dns_zone_name" {
default =  "privatelink.eastus.azmk8s.io"
}

variable "wif_subject" {
  
}

variable "wif_app_object_id" {
  
}
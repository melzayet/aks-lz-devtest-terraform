# Creates cluster with default linux node pool

resource "azuread_application_federated_identity_credential" "wif_credential" {
  application_object_id = var.wif_app_object_id
  display_name          = "todo-kubernetes-federated-credential"
  description           = "Identity for accessing resources by todo App"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = azurerm_kubernetes_cluster.akscluster.oidc_issuer_url
  subject               = var.wif_subject
}

resource "azurerm_kubernetes_cluster" "akscluster" {
  lifecycle {
   ignore_changes = [
     default_node_pool[0].node_count
   ]
  }

  name                    = var.prefix
  dns_prefix              = var.prefix
  location                = var.location
  resource_group_name     = var.resource_group_name
  kubernetes_version      = "1.24.6"
  private_cluster_enabled = true
  private_dns_zone_id     = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = true
  azure_policy_enabled    = false
  oidc_issuer_enabled     = true
  oms_agent {
    log_analytics_workspace_id = var.la_id
  }

  default_node_pool {
    name            = "defaultpool"
    vm_size         = "Standard_B2ms"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
    enable_auto_scaling   = true
    max_count             = 4
    min_count             = 2
    vnet_subnet_id  = var.vnet_subnet_id
    pod_subnet_id   = var.pod_subnet_id
    zones      = [1,2,3]
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    outbound_type = "userAssignedNATGateway"
    dns_service_ip = "192.168.100.10"
    service_cidr = "192.168.100.0/24"
    docker_bridge_cidr = "172.17.0.1/16"

  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
      managed            = true
    //  admin_group_object_ids = talk to Ayo about this one, this arg could reduce code other places possibly 
      azure_rbac_enabled = true
    }

  identity {
    type        = "UserAssigned"
    identity_ids = [var.mi_aks_cp_id]
  }
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.akscluster.id
}

output "node_pool_rg" {
  value = azurerm_kubernetes_cluster.akscluster.node_resource_group
}

# Managed Identities created for Addons

output "kubelet_id" {
  value = azurerm_kubernetes_cluster.akscluster.kubelet_identity[0].object_id
}

/*
resource "azurerm_kubernetes_cluster_node_pool" "nodepool_cpu_spot" {
    zones    = [1, 2, 3]
    enable_auto_scaling   = true
    kubernetes_cluster_id = azurerm_kubernetes_cluster.akscluster.id
    max_count             = 3
    min_count             = 1
    mode                  = "User"
    name                  = "spotnodes"
    orchestrator_version  = azurerm_kubernetes_cluster.akscluster.kubernetes_version
    os_type               = "Linux" # Default is Linux, we can change to Windows
    vm_size               = "Standard_A2m_v2"
    priority              = "Spot"
    spot_max_price        = -1
    eviction_policy       = "Delete"
    vnet_subnet_id        = var.vnet_subnet_id
    pod_subnet_id         = var.spotPod_subnet_id
    node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
    node_labels = {
      "nodepool-type" = "user"
      "environment"   = "staging"
      "nodepoolos"    = "linux"
      "sku"           = "cpu"    
      "kubernetes.azure.com/scalesetpriority" = "spot"
    }
    tags = {
      "nodepool-type" = "user"
      "environment"   = "staging"
      "nodepoolos"    = "linux"
      "sku"           = "cpu"    
    }
  }
  */

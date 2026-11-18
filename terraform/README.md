# Terraform – Azure infrastructure

The root Terraform configuration composes four local modules:

- `modules/resource-group`: resource group
- `modules/vnet`: virtual network and AKS subnet
- `modules/acr`: Azure Container Registry (Basic)
- `modules/aks`: AKS cluster, system/user node pools, and kubelet identity `AcrPull` role assignment

## Prerequisites

- Terraform 1.5 or later
- Azure CLI
- Azure subscription permissions to create the resources and role assignments
- Sufficient regional VM quota and availability for the selected node SKU

## Configure from this directory

```powershell
az login
az account set --subscription "<SUBSCRIPTION_ID>"
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`: set `subscription_id` and a globally unique ACR name containing only letters and numbers (5–50 characters).

## Validate and deploy

```powershell
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Review the plan, regional quota, SKU availability and estimated cost before applying:

```powershell
terraform apply
```

Do not apply without reviewing the plan. Keep `terraform.tfvars` and state files private; `.gitignore` excludes them.

## Important notes

- AKS Free tier removes the AKS management fee, not the cost of worker VMs, disks, networking, load balancer or ACR.
- The configuration uses Azure CNI Overlay with VNet subnet `10.20.1.0/24`, pod CIDR `10.22.0.0/16`, and service CIDR `10.21.0.0/24`. Ensure these ranges do not overlap with connected networks.
- Initial system and user pool counts are one each. Confirm the chosen VM SKU is available and your subscription has quota in the selected region.
- ACR admin user is disabled. AKS pulls images using its kubelet managed identity and the `AcrPull` role assignment.
- This is a learning baseline, not a production-ready network/security design.

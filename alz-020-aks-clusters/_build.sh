# 1. build locally.
# 2. switch to ado pipeline once built locally.
# 3. switch to mdp pipeline once mdp created & update to private endpoints (if any).

tenant      73578441-dc3d-4ecd-a298-fc5c6f40e191
appl_prd_01 2bc7b65e-18d6-42ae-afb2-e66d50be6b05

# agfc
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.NetworkFunction
az provider register --namespace Microsoft.ServiceNetworking
az extension add --name alb

# entra / rbac / permissions
# see 070-aks\aks-permissions.xlsx

# NORTH - prd - blu
# login as sp_appl_prd_01
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-nteu-tfstate" `
  -backend-config="storage_account_name=sardzprdnteutfstate" `
  -backend-config="container_name=alz-020-aks-clusters" `
  -backend-config="key=prd-nteu-blu.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu-blu.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu-blu.tfvars" -auto-approve
# destroy
terraform destroy -var-file="environments/prd/nteu/prd-nteu-blu.tfvars"

# NORTH - prd - grn
# login as sp_appl_prd_01
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-nteu-tfstate" `
  -backend-config="storage_account_name=sardzprdnteutfstate" `
  -backend-config="container_name=alz-020-aks-clusters" `
  -backend-config="key=prd-nteu-grn.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu-grn.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu-grn.tfvars" -auto-approve
# destroy
terraform destroy -var-file="environments/prd/nteu/prd-nteu-grn.tfvars"

# NOTE:
# Using the kubernetes or helm provider does not play well with setting api_server_access_profile.
# Once a firewall rule is set on the api, the kubernetes and helm jobs start to fail; despite having correct rules in place.
# As such aks bootstrapping isnt done with terraform, but moved to 071-aks-bootstrap.

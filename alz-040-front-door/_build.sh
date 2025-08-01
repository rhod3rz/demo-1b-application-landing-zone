# 1. build locally.
# 2. switch to ado pipeline once built locally.
# 3. switch to mdp pipeline once mdp created & update to private endpoints (if any).

tenant          73578441-dc3d-4ecd-a298-fc5c6f40e191
appl_nonprod_01 2bc7b65e-18d6-42ae-afb2-e66d50be6b05

# NORTH - prd
# login as sp_appl_prd_01
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-nteu-tfstate" `
  -backend-config="storage_account_name=sardzprdnteutfstate" `
  -backend-config="container_name=alz-040-front-door" `
  -backend-config="key=prd-nteu.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu.tfvars" -auto-approve
# destroy
terraform destroy -var-file="environments/prd/nteu/prd-nteu.tfvars"

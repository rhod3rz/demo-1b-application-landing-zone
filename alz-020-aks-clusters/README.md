# Application Landing Zone - AKS Cluster Repo

## 1. Repo Structure, Azure DevOps and Branching Strategy
---

The repo follows the standards documented in 000-tfstate-bootstrap.

## 2. AKS Cluster Repo
---

### 2.1 Summary

This repo deploys the Application Landing Zone aks cluster components.

### 2.2 Components

The following components are deployed via this repo.  
See the **[environment]-[region].tfvars** file for full configuration details.

- User Assigned Managed Identities
- Key Vaults
- Container Registries
- AKS Clusters
- Federated Identities
- Application Gateway for Containers
- Private EndPoints

### 2.3 Exceptions

None

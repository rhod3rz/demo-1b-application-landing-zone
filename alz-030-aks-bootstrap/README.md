# Application Landing Zone - AKS Bootstrap Repo

## 1. Repo Structure, Azure DevOps and Branching Strategy
---

The repo follows the standards documented in 000-tfstate-bootstrap.

## 2. AKS Bootstrap Repo
---

### 2.1 Summary

This repo deploys the Application Landing Zone aks bootstrap components.

### 2.2 Components

The following components are deployed via this repo.  

#### HELM

- ALB Controller (Application Gateway for Containers)
- Cert Manager

#### Kustomize

- Namespaces
- Cluster Roles
- Cluster Role Bindings
- Role Bindings
- Service Accounts
- Key Vault Secret Providers

### 2.3 Exceptions

None

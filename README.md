# Azure Landing Zone - Application Spoke

## 1. Summary
---

This repository builds on the **Platform Landing Zone**, which should be reviewed first to understand the foundation of this architecture:  
👉 https://github.com/rhod3rz/demo-1a-platform-landing-zone

It forms the **Application Landing Zone** of the Enterprise-Scale Azure Landing Zone (ALZ), focusing on deploying **AKS infrastructure**, **supporting services**, and **regionally resilient ingress architecture** using Azure Front Door. It is built with **Infrastructure as Code (IaC)** using Terraform and follows best practices from Microsoft's **Cloud Adoption Framework (CAF)**.

> **NOTE:** For the purposes of this demo, the solution is split across three repositories. In a real-world implementation, each demo repository would typically map to an Azure DevOps project, and each folder to an individual Azure DevOps repository.

The table below details what each folder covers.

| Folder                  | Description                                                                                                          |
|-------------------------|----------------------------------------------------------------------------------------------------------------------|
| `alz-010-aks-lz`        | Deploys the application lz: vnets, subnets, route tables, NSGs, NAT gateways.                                        |
| `alz-020-aks-clusters`  | Deploys the AKS clusters and supporting services (e.g. AGC, Key Vault).                                              |
| `alz-030-aks-bootstrap` | Deploys the AKS configuration: namespaces, roles, service accounts and core apps (e.g. cert-manager, alb-controller) |
| `alz-040-front-door`    | Deploys Azure Front Door for global ingress and region-aware traffic routing.                                        |

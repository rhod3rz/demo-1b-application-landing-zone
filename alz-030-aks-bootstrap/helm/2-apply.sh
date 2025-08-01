# 2-apply.sh

#!/bin/bash
set -euo pipefail

# alb-controller
# https://artifacthub.io/packages/helm/azure-application-gateway-for-containers/alb-controller
echo "Installing alb-controller ..."
helm upgrade --install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller \
  --namespace azure-alb-system \
  --create-namespace \
  --version 1.7.9 \
  -f helm/alb-controller.yaml
echo

# cert-manager
# https://artifacthub.io/packages/helm/cert-manager/cert-manager
echo "Installing cert-manager ..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace 'cert-manager' \
  --create-namespace \
  --version v1.18.2 \
  -f helm/cert-manager.yaml
echo

# prometheus-stack
# https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
echo "Installing prometheus-stack ..."
helm upgrade --install prometheus-stack oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --version 75.15.1 \
  -f helm/prometheus-stack.yaml
echo

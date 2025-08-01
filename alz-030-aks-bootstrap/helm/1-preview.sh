# 1-preview.sh

#!/bin/bash
set -euo pipefail

# install helm-diff plugin
if ! helm plugin list | grep -q 'diff'; then
  echo "Installing helm-diff plugin ..."
  helm plugin install https://github.com/databus23/helm-diff
  echo
else
  echo "helm-diff plugin already installed ..."
  echo
fi

# preview function
preview_chart() {
  local release=$1
  local chart=$2
  local namespace=$3
  local version=$4
  local valuesFile=$5
  echo "Previewing changes for $release ..."
  if helm status "$release" -n "$namespace" >/dev/null 2>&1; then
    helm diff upgrade "$release" "$chart" \
      --namespace "$namespace" \
      --version "$version" \
      -f "$valuesFile"
  else
    echo "$release is not installed; skipping preview - this is the first run ..."
  fi
  echo
}

# alb-controller
preview_chart \
  "alb-controller" \
  "oci://mcr.microsoft.com/application-lb/charts/alb-controller" \
  "azure-alb-system" \
  "1.7.9" \
  "helm/alb-controller.yaml"

# cert-manager
helm repo add jetstack https://charts.jetstack.io --force-update
preview_chart \
  "cert-manager" \
  "jetstack/cert-manager" \
  "cert-manager" \
  "v1.18.2" \
  "helm/cert-manager.yaml"

# prometheus-stack
preview_chart \
  "prometheus-stack" \
  "oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack" \
  "monitoring" \
  "75.15.1" \
  "helm/prometheus-stack.yaml"

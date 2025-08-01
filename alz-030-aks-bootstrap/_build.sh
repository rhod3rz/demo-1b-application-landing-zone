# The bootstrap files needed for base configuration of the aks cluster.

# NAMESPACES
# This creates namespaces.
# - 1-namespaces.yaml

# CLUSTER ROLES & CLUSTERROLEBINDINGS
# This creates a custom cluster wide read-only role as there isnt a built in one that can be used | it applies to all namespaces.
# - 2a-cluster-roles.yaml
# This binds the custom role from 2a to the cluster.
# - 2b-cluster-role-bindings.yaml

# ROLEBINDINGS
# This binds existing roles (admin, view & edit), to specific namespaces.
# - 3a-role-bindings-ns-mango.yaml
# - 3a-role-bindings-ns-titan.yaml

# SERVICE ACCOUNTS
# This creates namespace specific service accounts tied to the aks uami.
# - 4-service-accounts.yaml

# KEY VAULT SECRET PROVIDER CLASSES
# This create key vault secret provider classes linked to specific key vaults.
# - 5-key-vaults.yaml

# PROMETHEUS CUSTOM RULES
# Sometimes the OOTB default rules for prometheus dont work as required.
# An example is 'kubernetesResources: false # disabled due to 'PrometheusRuleFailures' critical errors'.
# We do however want some rules out of here so we create a custom rule to apply them.
# - 6-promethus-custom-rules.yaml

# HELM CHARTS

# alb-controller
# https://artifacthub.io/packages/helm/azure-application-gateway-for-containers/alb-controller
helm upgrade --install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller `
  --namespace azure-alb-system `
  --create-namespace `
  --version 1.7.9 `
  -f helm/alb-controller.yaml
helm uninstall alb-controller -n azure-alb-system

# cert-manager
# https://artifacthub.io/packages/helm/cert-manager/cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade --install cert-manager jetstack/cert-manager `
  --namespace 'cert-manager' `
  --create-namespace `
  --version v1.18.2 `
  -f helm/cert-manager.yaml
helm uninstall cert-manager -n cert-manager

# prometheus-stack
# https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
helm upgrade --install prometheus-stack oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack `
  --namespace monitoring `
  --create-namespace `
  --version 75.15.1 `
  -f helm/prometheus-stack.yaml
helm uninstall prometheus-stack -n monitoring
# get grafana password (prom-operator)
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl --namespace monitoring get secrets prometheus-stack-grafana -o jsonpath="{.data.admin-password}")))
# prometheus
kubectl port-forward -n monitoring service/prometheus-stack-kube-prom-prometheus 9090:9090
# grafana
kubectl port-forward -n monitoring service/prometheus-stack-grafana 8080:80
# alert-manager
kubectl port-forward -n monitoring service/prometheus-stack-kube-prom-alertmanager 8081:9093

# list default alerts (requires 'choco install yq') | required for tweaking 'severity'.
kubectl get prometheusrules -A -o yaml | yq e '.items[] | .metadata.namespace as $ns | .spec.groups[] | .name as $group | .rules[] | select(.alert) | {"namespace": $ns, "group": $group, "alert": .alert, "severity": .labels.severity}' -P
$alerts = @()
$record = @{}
kubectl get prometheusrules -A -o yaml |
yq e '.items[] | .metadata.namespace as $ns | .spec.groups[] | .name as $group | .rules[] | select(.alert) | {"namespace": $ns, "group": $group, "alert": .alert, "severity": .labels.severity}' -P |
ForEach-Object {
  if ($_ -match '^(\w+):\s*(.+)$') {
    $key = $matches[1]
    $value = $matches[2]
    $record[$key] = $value
  }
  if ($record.Count -eq 4) {
    $alerts += [PSCustomObject]@{
      Namespace = $record.namespace
      Group     = $record.group
      Alert     = $record.alert
      Severity  = $record.severity
    }
    $record.Clear()
  }
}
$alerts | Export-Csv -Path prometheus-alerts.csv -NoTypeInformation

# to see rules
kubectl get PrometheusRule -n monitoring
kubectl get PrometheusRule -n monitoring prometheus-stack-kube-prom-kubernetes-apps -o yaml > kubernetes-apps.yaml                    # this one has 'severity' tweaked.
kubectl get PrometheusRule -n monitoring prometheus-stack-kube-prom-kubernetes-resources-custom -o yaml > kubernetes-resources-custom # this is a custom rule to replace kubernetes-resources.

# test-alert
kubectl apply -f helm/.defaults/test-alert.yaml
kubectl delete -f helm/.defaults/test-alert.yaml

# to test crashloopbackoff
kubectl apply -f helm/.defaults/test-alert-crashloop.yaml
kubectl delete -f helm/.defaults/test-alert-crashloop.yaml

# tuning pods
# set requests to 2x average
# set limits to 2-4x requests

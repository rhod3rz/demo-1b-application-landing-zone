# 9-delete.sh

#!/bin/bash
set -euo pipefail

# alb-controller
echo "Deleting alb-controller ..."
helm uninstall alb-controller -n azure-alb-system
echo

# cert-manager
echo "Deleting cert-manager ..."
helm uninstall cert-manager -n cert-manager
echo

# prometheus-stack
echo "Deleting prometheus-stack ..."
helm uninstall prometheus-stack -n monitoring
echo

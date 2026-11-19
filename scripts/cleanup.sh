#!/usr/bin/env bash
# Elimina todos los recursos de la demo (no toca minikube ni kubectl).
set -uo pipefail
cd "$(dirname "$0")/.."

kubectl delete -f loadtest/ --ignore-not-found
kubectl delete -f k8s/ --ignore-not-found
echo "Recursos eliminados."

#!/usr/bin/env bash
# Uso: ./scripts/load-test.sh start | stop | status
set -euo pipefail
cd "$(dirname "$0")/.."

case "${1:-}" in
  start)
    kubectl apply -f loadtest/load-generator.yaml
    echo "Carga iniciada. Observa el escalado con:  kubectl get hpa -w"
    ;;
  stop)
    kubectl delete -f loadtest/load-generator.yaml --ignore-not-found
    echo "Carga detenida. En ~1-2 minutos el HPA reducirá las réplicas."
    ;;
  status)
    kubectl get hpa
    echo
    kubectl get pods -l app=backend
    echo
    kubectl top pods 2>/dev/null || echo "(metrics-server aún no tiene datos)"
    ;;
  *)
    echo "Uso: $0 start | stop | status"
    exit 1
    ;;
esac

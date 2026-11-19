#!/usr/bin/env bash
# Prepara todo: minikube, metrics-server, imágenes y despliegue.
set -euo pipefail
cd "$(dirname "$0")/.."

echo ">> Iniciando minikube (si no está activo)..."
minikube status >/dev/null 2>&1 || minikube start --container-runtime=docker

echo ">> Habilitando metrics-server (necesario para el HPA)..."
minikube addons enable metrics-server

echo ">> Construyendo imágenes dentro de minikube..."
eval "$(minikube docker-env)"
docker build -t hpa-backend:1.0 ./backend
docker build -t hpa-frontend:1.0 ./frontend

echo ">> Aplicando manifiestos..."
kubectl apply -f k8s/

kubectl rollout status deployment/backend
kubectl rollout status deployment/frontend

echo
echo "Listo. Siguientes pasos:"
echo "  minikube service frontend          # abrir la app en el navegador"
echo "  kubectl get hpa -w                 # observar el autoscaler (otra terminal)"
echo "  ./scripts/load-test.sh start       # generar carga"
echo
echo "Nota: el HPA puede mostrar <unknown> durante ~1 minuto mientras metrics-server recoge datos."

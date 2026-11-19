# Demo de HPA (Horizontal Pod Autoscaler) en minikube

App de prueba con frontend (nginx) y backend (Flask) que escalan automáticamente según la CPU.

## Estructura

```
hpa-demo/
├── backend/
│   ├── app.py                  # API: /api/info (ligero) y /api/cpu (consume CPU)
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── index.html              # Muestra qué Pod responde cada petición
│   ├── nginx.conf              # Proxy /api -> backend
│   └── Dockerfile
├── k8s/
│   ├── 00-backend.yaml         # Deployment + Service (con resources requests/limits)
│   ├── 01-frontend.yaml        # Deployment + Service NodePort
│   ├── 02-hpa-backend.yaml     # HPA del backend (1-5 réplicas, CPU 50%)
│   └── 03-hpa-frontend.yaml    # HPA del frontend (1-3 réplicas, CPU 70%)
├── loadtest/
│   └── load-generator.yaml     # Pods que bombardean el backend (se aplica a mano)
└── scripts/
    ├── setup.sh                # Todo el despliegue
    ├── load-test.sh            # start | stop | status
    └── cleanup.sh              # Borra los recursos de la demo
```

## Requisitos del HPA (por qué funciona esta demo)

1. **metrics-server** activo: `minikube addons enable metrics-server`.
2. Los contenedores deben tener **`resources.requests`**: el HPA calcula el % de uso respecto a ese valor.
3. El Deployment **no debe fijar `replicas`**, para que `kubectl apply` no pise lo que decide el HPA.

## Paso a paso

```bash
./scripts/setup.sh                 # desplegar
minikube service frontend          # abrir la app en el navegador
```

En una segunda terminal:
```bash
kubectl get hpa -w                 # observar el autoscaler
```

En una tercera:
```bash
./scripts/load-test.sh start       # generar carga
kubectl get pods -w                # ver aparecer nuevos Pods
```

Resultado esperado: el HPA del backend pasa de 1 a varias réplicas (hasta 5) en 1-2 minutos y la tabla del navegador muestra los nuevos Pods.

Para ver la bajada:
```bash
./scripts/load-test.sh stop        # tras ~1-2 min las réplicas vuelven a 1
```

## Comandos útiles

```bash
kubectl top pods                   # CPU y memoria actuales
kubectl describe hpa backend-hpa   # eventos y decisiones del autoscaler
./scripts/load-test.sh status      # resumen rápido
```

## Problemas frecuentes

- **`<unknown>/50%` en el HPA:** metrics-server aún no tiene datos (espera ~1 minuto) o no está activado.
- **`ImagePullBackOff`:** las imágenes no se construyeron dentro de minikube; vuelve a ejecutar `setup.sh`.
- **El frontend no escala:** es normal; nginx sirviendo contenido estático consume muy poca CPU.

## Limpieza

```bash
./scripts/cleanup.sh
```

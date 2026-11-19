import os
import socket
import time

from flask import Flask, jsonify, request

app = Flask(__name__)

# En Kubernetes el hostname de un contenedor es el nombre de su Pod
POD = socket.gethostname()


@app.get("/api/health")
def health():
    return jsonify(status="ok")


@app.get("/api/info")
def info():
    """Respuesta ligera: sirve para ver qué Pod atiende cada petición."""
    return jsonify(pod=POD, version=os.getenv("APP_VERSION", "1.0"))


@app.get("/api/cpu")
def cpu():
    """
    Consume CPU a propósito durante 'ms' milisegundos (por defecto 100, máximo 1000).
    Es lo que hace subir el uso de CPU y dispara el HPA.
    """
    ms = min(max(request.args.get("ms", default=100, type=int), 1), 1000)
    fin = time.perf_counter() + ms / 1000
    total = 0
    while time.perf_counter() < fin:
        total += sum(i * i for i in range(1000))
    return jsonify(pod=POD, burned_ms=ms)

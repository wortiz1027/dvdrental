#!/usr/bin/env bash

# Detener el script inmediatamente ante cualquier error
set -euo pipefail

echo "🔍 Resolviendo versión actual de la imagen para auditoría..."

# 1. Obtener la versión más cercana de Git de forma idéntica al builder
GIT_VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "0.1.0-snapshot")
SEMVER_VERSION=$(echo "$GIT_VERSION" | sed 's/^v//')

echo "🛡️  Iniciando escaneo de Trivy sobre la imagen: dvd-rental-extreme:$SEMVER_VERSION"
echo "🚨 Filtro activo: Severidades ALTAS y CRÍTICAS únicamente."

# 2. Ejecutar el escáner nativo de Trivy
trivy image --severity CRITICAL,HIGH --exit-code 1 dvd-rental-extreme:"$SEMVER_VERSION"

echo "========================================================================="
echo "✅ Auditoría de imagen aprobada. Cero vulnerabilidades críticas encontradas."
echo "========================================================================="

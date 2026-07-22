#!/usr/bin/env bash

# Detener el script inmediatamente si ocurre algún error
set -euo pipefail

echo "🔍 Calculando versión dinámica del software mediante Git..."

# 1. Obtener la versión más cercana de Git o fallback inicial
GIT_VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "0.1.0-snapshot")

# 2. Limpiar el prefijo 'v' para cumplir estrictamente con SemVer
SEMVER_VERSION=$(echo "$GIT_VERSION" | sed 's/^v//')

echo "🏷️  Compilando y etiquetando imagen para versión: $SEMVER_VERSION"

# 3. Construir la imagen asignando el tag de la versión real y el tag latest en simultáneo
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg BUILD_VERSION="$SEMVER_VERSION" \
  -t dvd-rental-extreme:"$SEMVER_VERSION" \
  -t dvd-rental-extreme:latest .

echo "========================================================================="
echo "✅ Imagen empaquetada con éxito:"
echo "   👉 dvd-rental-extreme:$SEMVER_VERSION"
echo "   👉 dvd-rental-extreme:latest"
echo "========================================================================="

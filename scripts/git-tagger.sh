#!/usr/bin/env bash

# Detener el script inmediatamente ante errores o variables huérfanas
set -euo pipefail

MODE="${1:-patch}"

if [ "$MODE" = "patch" ]; then
  # 🚀 MODO AUTOMÁTICO: Incrementar el Patch (v1.0.0 -> v1.0.1)
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")

  VERSION_CLEAN=$(echo "$LAST_TAG" | sed 's/^v//')
  MAJOR=$(echo "$VERSION_CLEAN" | cut -d'.' -f1)
  MINOR=$(echo "$VERSION_CLEAN" | cut -d'.' -f2)
  PATCH=$(echo "$VERSION_CLEAN" | cut -d'.' -f3)

  NEW_PATCH=$((PATCH + 1))
  NEW_TAG="v${MAJOR}.${MINOR}.${NEW_PATCH}"

  echo "📍 Última versión detectada: $LAST_TAG"
  echo "🆕 Creando tag anotado automático: $NEW_TAG"

  git tag -a "$NEW_TAG" -m "Automated architecture baseline release $NEW_TAG"
  git push origin "$NEW_TAG" 2>/dev/null || echo "⚠️ Advertencia: No se pudo hacer push al remoto, tag creado localmente."

elif [ "$MODE" = "custom" ]; then
  # 🎛️ MODO MANUAL / CI-CD: Versión y mensaje personalizados
  if [ -z "${TAG_VERSION:-}" ]; then
    echo "❌ Error: Debes suministrar la variable TAG_VERSION."
    echo "👉 Ejemplo: TAG_VERSION=1.1.0 mise run git:tag-custom"
    exit 1
  fi

  MSG="${TAG_MSG:-Manual architecture baseline release v$TAG_VERSION}"
  VERSION_FORMATTED="v$(echo "$TAG_VERSION" | sed 's/^v//')"

  echo "🔖 Creando tag personalizado: $VERSION_FORMATTED"
  git tag -a "$VERSION_FORMATTED" -m "$MSG"
  git push origin "$VERSION_FORMATTED" 2>/dev/null || echo "⚠️ Tag creado localmente."

else
  echo "❌ Error: Modo desconocido '$MODE'. Usa 'patch' o 'custom'."
  exit 1
fi

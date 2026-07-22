#!/usr/bin/env bash

# Detener el script inmediatamente si ocurre algún error inesperado
set -euo pipefail

# 1. Git pasa la ruta del archivo temporal del mensaje como el primer argumento ($1)
COMMIT_MSG_FILE="${1:-}"

# Si se ejecuta manualmente sin argumentos, buscar el archivo por defecto de Git
if [ -z "$COMMIT_MSG_FILE" ]; then
  COMMIT_MSG_FILE=".git/COMMIT_EDITMSG"
fi

if [ ! -f "$COMMIT_MSG_FILE" ]; then
  echo "❌ Error: No se encontró el archivo de mensaje del commit ($COMMIT_MSG_FILE)."
  exit 1
fi

# 2. Leer el contenido del mensaje escrito por el desarrollador
MSG=$(cat "$COMMIT_MSG_FILE")

# 3. Expresión regular oficial de Conventional Commits (Inmutable y limpia)
REGEX='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9_-]+\))?!?:\ .+'

if [[ "$MSG" =~ $REGEX ]]; then
  echo "│"
  echo "├── ✅ [Conventional Commits]: ¡Mensaje aprobado con éxito!"
  echo "└── 📝 Contenido: '$MSG'"
  exit 0
else
  echo "│"
  echo "├── ❌ [Conventional Commits]: El mensaje NO cumple con el estándar corporativo."
  echo "├── 📝 Tu mensaje fue: '$MSG'"
  echo "├── 💡 Formato requerido: tipo(componente): descripción en minúsculas"
  echo "└── 🛠️  Tipos válidos: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
  exit 1
fi

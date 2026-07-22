#!/usr/bin/env bash

# Detener el script inmediatamente si ocurre algún error inesperado
set -euo pipefail

echo "🔍 Iniciando análisis estático de seguridad (SAST) con Semgrep..."

REPORT_DIR="./build/reports/sast"
mkdir -p "$REPORT_DIR"

# Ejecutar el escáner open-source de Semgrep usando el set de reglas de seguridad de Java
# El flag --error bloqueará el pipeline devolviendo código 1 si encuentra fallas críticas
semgrep scan \
  --config "p/java" \
  --config "p/dockerfile" \
  --config ".config/sast/semgrep/rules.yaml" \
  --config "p/owasp-top-ten" \
  --sarif \
  --sarif-output= "${REPORT_DIR}/report.sarif" \
  --error \
  --metrics=off \
  ./src/main/java

echo "========================================================================="
echo "✅ Análisis SAST aprobado. Cero vulnerabilidades detectadas en tu código."
echo "========================================================================="

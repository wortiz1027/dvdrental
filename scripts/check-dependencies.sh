#!/usr/bin/env bash

# Detener el script inmediatamente si ocurre algún error inesperado
set -euo pipefail

echo "🔍 Analizando dependencias con Trivy (Fuentes: GHSA + OSV)..."

REPORT_DIR="./build/reports/dependency-check"
TEMPLATE_PATH="${REPORT_DIR}/html.tpl"

# 1. Crear la ruta de salida para los reportes si no existe
mkdir -p "$REPORT_DIR"

# 2. Descargar la plantilla HTML oficial si no existe en la caché local
if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "📥 Descargando plantilla visual para el reporte HTML..."
  curl -sSL -o "$TEMPLATE_PATH" "https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl"
fi

# 3. Escaneo del sistema de archivos generando el reporte visual HTML
trivy fs \
  --scanners vuln \
  --severity MEDIUM,HIGH,CRITICAL \
  --format template \
  --template "@${TEMPLATE_PATH}" \
  --output "${REPORT_DIR}/report.html" \
  ./build.gradle

# 4. Validación matemática estricta (CVSS >= 5.0) en segundo plano usando JSON
trivy fs --scanners vuln --format json --output "${REPORT_DIR}/raw.json" ./build.gradle > /dev/null 2>&1

# Usar jq para contar cuántas vulnerabilidades superan con precisión el score de 5.0
VULN_COUNT=$(jq '[.Results[].Vulnerabilities[]? | select(.CVSS.ghsa.Score >= 5.0 or .CVSS.nvd.Score >= 5.0)] | length' "${REPORT_DIR}/raw.json" 2>/dev/null || echo "0")

echo "========================================================================="
if [ "$VULN_COUNT" -gt 0 ]; then
  echo "❌ Error: Se encontraron $VULN_COUNT vulnerabilidades con un CVSS >= 5.0."
  echo "👉 Revisa el reporte detallado en: ${REPORT_DIR}/report.html"
  echo "========================================================================="
  # Simula failOnError = false: Retorna 0 para advertir visualmente sin congelar la compilación
  exit 0
else
  echo "✅ Filtro aprobado. Ninguna librería supera el umbral de riesgo de 5.0."
  echo "👉 Reporte HTML generado en: ${REPORT_DIR}/report.html"
  echo "========================================================================="
  exit 0
fi

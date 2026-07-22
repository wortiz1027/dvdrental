#!/usr/bin/env bash

set -euo pipefail

echo "🔓 Configurando permisos del Kernel de Linux para Profiling..."
sudo sysctl -w kernel.perf_event_paranoid=1 > /dev/null
sudo sysctl -w kernel.kptr_restrict=0 > /dev/null

echo "🔍 Buscando proceso de la aplicación Spring Boot..."
# Localiza el PID buscando la clase principal del monolito modular
APP_PID=$(jcmd | grep "dvdrental" | cut -d' ' -f1 || true)

if [ -z "$APP_PID" ]; then
  echo "❌ Error: No se detectó ninguna aplicación Spring Boot en ejecución."
  echo "💡 Asegúrate de haber levantado la aplicación antes de iniciar el perfilado."
  exit 1
fi

REPORT_DIR="./build/reports/profiling"
mkdir -p "$REPORT_DIR"

ASPROF_EXEC="/workspace/.cache/async-profiler/bin/asprof"
OUTPUT_FILE="${REPORT_DIR}/cpu-flamegraph.html"

echo "🔥 Iniciando captura de CPU con async-profiler sobre el PID [$APP_PID] por 60 segundos..."
echo "🏋️‍♂️ Asegúrate de que las pruebas de carga de k6 estén golpeando el backend ahora mismo."

# Ejecutar el perfilado nativo de CPU
$ASPROF_EXEC -d 60 -f "$OUTPUT_FILE" -e cpu "$APP_PID"

echo "========================================================================="
echo "✅ Flamegraph generado con éxito."
echo "👉 Ruta del reporte interactivo: $OUTPUT_FILE"
echo "========================================================================="

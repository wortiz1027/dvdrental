#!/usr/bin/env bash

# 1. Forzar la carga de los archivos de configuración de tu usuario host
# Esto recupera tu $PATH real donde está instalado gopass o mise
[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
[[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc"

set -e
mkdir -p .devcontainer

#ENV_PATH=".devcontainer/.env.secrets"

# 1. Limpieza preventiva de ejecuciones colgadas anteriores
#rm -f "$ENV_PATH"

echo "🔐 Extrayendo secretos de gopass hacia archivo temporal..."

# 2. Si sigue sin encontrarlo en el PATH, buscar en rutas comunes por defecto
if ! command -v gopass &> /dev/null; then
    if [ -f "$HOME/.local/bin/gopass" ]; then
        alias gopass="$HOME/.local/bin/gopass"
    elif [ -f "/usr/local/bin/gopass" ]; then
        alias gopass="/usr/local/bin/gopass"
    else
        echo "❌ Error: gopass no se encontró en el PATH ni en rutas locales del host." >&2
        exit 1
    fi
fi

# Generar el archivo de secretos temporales
cat << EOF > .devcontainer/.env.secrets
API_SECRET_KEY=$(gopass show -o development/api/auth/secret-key)
DB_USERNAME=$(gopass show -o development/database/postgresql/username)
DB_PASSWORD=$(gopass show -o development/database/postgresql/password)
DB_HOSTNAME=$(gopass show -o development/database/postgresql/hostname)
DB_NAME=$(gopass show -o development/database/postgresql/database)
DB_SCHEMA=$(gopass show -o development/database/postgresql/schema)
EOF

#trap 'rm -f "$ENV_PATH"' EXIT
echo "✅ Archivo .devcontainer/.env.secrets generado con éxito."

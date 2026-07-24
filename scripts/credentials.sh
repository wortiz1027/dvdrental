#!/usr/bin/env bash

# Detener el script inmediatamente si ocurre algún error inesperado
set -euo pipefail

# Evitar que el script se ejecute directamente con './' para que impacte la terminal actual
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "❌ Error: Exec this script using 'source' o '.' to export variables to hte current terminal." >&2
    echo "👉 Use: source ./setup-env.sh" >&2
    exit 1
fi

echo "🔐 Extract credentials directly from VAULT to memory..."

# Definir las rutas en VAULT
VAULT_DB_USER_PATH="development/database/postgresql/username"
VAULT_DB_PASS_PATH="development/database/postgresql/password"
VAULT_DB_HOST_PATH="development/database/postgresql/hostname"
VAULT_DB_NAME_PATH="development/database/postgresql/database"
VAULT_DB_SCHEMA_PATH="development/database/postgresql/schema"
VAULT_API_AUTH_SECRET_KEY_PATH="development/api/auth/secret-key"

if ! command -v gopass &> /dev/null; then
    echo "❌ Error: gopass is not installed in the host machine." >&2
    return 1
fi

# Exportar directamente a las variables de entorno locales
export DB_USERNAME=$(gopass show -o "$VAULT_DB_USER_PATH")
export DB_PASSWORD=$(gopass show -o "$VAULT_DB_PASS_PATH")
export DB_HOSTNAME=$(gopass show -o "$VAULT_DB_HOST_PATH")
export DB_NAME=$(gopass show -o "$VAULT_DB_NAME_PATH")
export DB_SCHEMA=$(gopass show -o "$VAULT_DB_SCHEMA_PATH")
export API_SECRET_KEY=$(gopass show -o "$VAULT_API_AUTH_SECRET_KEY_PATH")

echo "✅ Variables [DB_USERNAME, DB_PASSWORD, DB_HOSTNAME, DB_NAME, DB_SCHEMA, API_SECRET_KEY] have been loaded succesfully in terminal environment..."

#!/usr/bin/env zsh

# 1. Asegurar la existencia de la carpeta contenedora
mkdir -p /home/vscode/.local/share/mise/installs/java

# 2. Calcular la ubicación del Java activo en este instante
CURRENT_JAVA="$(mise where java 2>/dev/null)"

# 3. Validar y actualizar el enlace simbólico dinámicamente
if [ -n "$CURRENT_JAVA" ] && [ "$(readlink /home/vscode/.local/share/mise/installs/java/latest)" != "$CURRENT_JAVA" ]; then
    rm -f /home/vscode/.local/share/mise/installs/java/latest
    ln -sf "$CURRENT_JAVA" /home/vscode/.local/share/mise/installs/java/latest
    echo "Mise redirigió reactivamente el enlace genérico a: $CURRENT_JAVA"
fi

# 4. Control inteligente para escribir una única vez en el .zshrc
grep -qF '$JAVA_HOME/bin:$GRADLE_HOME/bin' ~/.zshrc || echo 'export PATH="$PATH:$JAVA_HOME/bin:$GRADLE_HOME/bin"' >> ~/.zshrc
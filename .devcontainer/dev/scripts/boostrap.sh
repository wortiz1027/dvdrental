#!/bin/bash
set -e # Detiene el script si ocurre algún error

echo "Configurando repositorio oficial de gopass..."

# 1. Descargar e instalar la llave GPG del repositorio
curl -fsSL https://packages.gopass.pw/repos/gopass/gopass-archive-keyring.gpg | sudo tee /usr/share/keyrings/gopass-archive-keyring.gpg >/dev/null

# 2. Crear el archivo de fuentes con el formato deb822
cat << EOF | sudo tee /etc/apt/sources.list.d/gopass.sources
Types: deb
URIs: https://packages.gopass.pw/repos/gopass
Suites: stable
Architectures: all amd64 arm64 armhf
Components: main
Signed-By: /usr/share/keyrings/gopass-archive-keyring.gpg
EOF

# 3. Actualizar los repositorios e instalar el paquete oficial junto con dependencias necesarias
sudo apt-get update
sudo apt-get install -y gopass gnupg2 vim
echo "¡Gopass instalado con éxito!"

curl https://mise.run | sh && echo 'echo 'eval "$(mise activate zsh)"' >> ~/.zshrc' >> ~/.zshrc && /home/vscode/.local/bin/mise install && /home/vscode/.local/bin/mise run git:init

echo "🎯 Configurando alias personalizados de Unix..."

# Definir la lista de alias indispensables para este proyecto de alta carga
cat << 'EOF' >> ~/.zshrc

# --- Alias Personalizados DVD Rental ---
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias home="cd ~"

alias g="./gradlew"
alias gbuild="./gradlew clean build -x test"
alias grun="./gradlew bootRun"

alias gaa="git add -A"
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gd='$DOTLY_PATH/bin/dot git pretty-diff'
alias gs="git status -sb"
alias gf="git fetch --all -p"
alias gps="git push"
alias gpsf="git push --force"
alias gpl="git pull --rebase --autostash"
alias gb="git branch"
alias gl='$DOTLY_PATH/bin/dot git pretty-log'
alias glg="git log --oneline --graph --decorate"
# --------------------------------------
EOF

echo "✅ Alias inyectados con éxito."

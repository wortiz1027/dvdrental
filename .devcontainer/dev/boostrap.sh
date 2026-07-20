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
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y universe
sudo apt-get install -y gopass gnupg2 vim zsh
echo "¡Gopass instalado con éxito!"

sudo apt-get update
sudo apt-get install -y \
    intel-media-va-driver \
    mesa-va-drivers \
    vainfo \
    igt-gpu-tools

curl https://mise.run | sh && echo 'echo 'eval "$(mise activate zsh)"' >> ~/.zshrc' >> ~/.zshrc && /home/vscode/.local/bin/mise install && /home/vscode/.local/bin/mise run git:init


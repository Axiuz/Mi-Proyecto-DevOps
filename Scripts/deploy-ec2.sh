#!/usr/bin/env bash
# ============================================================
# deploy-ec2.sh
# Instala Docker + Docker Compose en una EC2 Amazon Linux 2 / Ubuntu
# y levanta el stack de Hunnab.Q
# ============================================================
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Detectando sistema operativo..."
if command -v apt-get &>/dev/null; then
  # Ubuntu / Debian
  sudo apt-get update -y
  sudo apt-get install -y docker.io docker-compose-plugin git
  sudo systemctl enable --now docker
elif command -v yum &>/dev/null; then
  # Amazon Linux 2
  sudo yum update -y
  sudo yum install -y docker git
  sudo systemctl enable --now docker
  # Docker Compose plugin
  DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
  mkdir -p "$DOCKER_CONFIG/cli-plugins"
  curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
    -o "$DOCKER_CONFIG/cli-plugins/docker-compose"
  chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"
fi

# Agregar usuario actual al grupo docker (evita usar sudo)
sudo usermod -aG docker "$USER" || true

echo "==> Construyendo y levantando contenedores..."
cd "$PROJECT_DIR"

# Asegúrate de que exista el .env en Hunnab/
if [ ! -f "Hunnab/.env" ]; then
  echo "ERROR: Falta Hunnab/.env — copia el .env.example y completa los valores."
  exit 1
fi

docker compose up --build -d

echo ""
echo "✓ Stack levantado. Servicios corriendo:"
docker compose ps
echo ""
echo "API disponible en: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):4000/health"

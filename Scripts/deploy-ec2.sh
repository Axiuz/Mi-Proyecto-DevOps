#!/usr/bin/env bash
# ============================================================
# deploy-ec2.sh
# Bootstrap completo para una EC2 Ubuntu nueva:
#   1. Instala Docker CE oficial
#   2. Genera Hunnab/.env desde .env.example
#   3. Levanta el stack con Docker Compose
#
# Uso (desde la raiz del repo clonado):
#   ./Scripts/deploy-ec2.sh
# ============================================================
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warning() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── 1. Docker ────────────────────────────────────────────────
if command -v docker &>/dev/null; then
  info "Docker ya instalado: $(docker --version)"
else
  info "Instalando Docker CE..."
  sudo apt-get update -y -qq
  sudo apt-get install -y -qq ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y -qq
  sudo apt-get install -y -qq \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  info "Docker instalado: $(sudo docker --version)"
fi

# ── 2. Generar .env ──────────────────────────────────────────
ENV_FILE="$PROJECT_DIR/Hunnab/.env"
ENV_EXAMPLE="$PROJECT_DIR/.env.example"

if [ -f "$ENV_FILE" ]; then
  warning "Hunnab/.env ya existe — se omite la generacion."
else
  [ -f "$ENV_EXAMPLE" ] || die "No se encontro .env.example en la raiz del proyecto."

  # Obtener IP publica de la instancia (metadata de EC2)
  PUBLIC_IP=$(curl -sf --max-time 3 http://169.254.169.254/latest/meta-data/public-ipv4 || echo "")

  cp "$ENV_EXAMPLE" "$ENV_FILE"

  if [ -n "$PUBLIC_IP" ]; then
    # Agregar la IP de la instancia a CORS_ORIGIN
    sed -i "s|CORS_ORIGIN=.*|&,http://${PUBLIC_IP}:4000|" "$ENV_FILE"
    info "Hunnab/.env generado — IP publica: $PUBLIC_IP"
  else
    info "Hunnab/.env generado (IP publica no disponible, CORS sin cambios)."
  fi
fi

# ── 3. Levantar contenedores ─────────────────────────────────
info "Levantando stack..."
cd "$PROJECT_DIR"
sudo docker compose down --remove-orphans 2>/dev/null || true
sudo docker compose up --build --force-recreate -d

info "Contenedores activos:"
sudo docker compose ps

# ── 4. Health check ──────────────────────────────────────────
PUBLIC_IP=$(curl -sf --max-time 3 http://169.254.169.254/latest/meta-data/public-ipv4 || echo "")
echo ""
echo "============================================"
echo "  Stack levantado"
echo "============================================"
if [ -n "$PUBLIC_IP" ]; then
  echo "  API:  http://${PUBLIC_IP}:4000/api/health"
  echo "  SSH:  ubuntu@${PUBLIC_IP}"
fi
echo ""
echo "Proximos pasos:"
echo "  1. Actualiza el secret EC2_HOST en GitHub con: ${PUBLIC_IP:-<ip-publica>}"
echo "  2. Haz push a main para activar el pipeline CI/CD"
echo "============================================"

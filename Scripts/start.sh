#!/usr/bin/env bash
# ============================================================
# start.sh  —  Corre en la instancia EC2 (Ubuntu)
#
# Uso:
#   export S3_BUCKET=hunnab-frontend-2026
#   cd ~/app && sudo -E ./Scripts/start.sh
# ============================================================
set -euo pipefail

# ── Rutas ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FRONTEND_DIR="$PROJECT_DIR/Hunnab"
REAL_USER="${SUDO_USER:-ubuntu}"

# ── Colores ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}==>${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── IP pública (IMDSv2 con fallback a ifconfig.me) ───────────
info "Obteniendo IP pública de la instancia..."
TOKEN=$(curl -fsSL --max-time 3 -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60" 2>/dev/null || echo "")
if [ -n "$TOKEN" ]; then
  PUBLIC_IP=$(curl -fsSL --max-time 3 \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    "http://169.254.169.254/latest/meta-data/public-ipv4" 2>/dev/null || echo "")
fi
if [ -z "${PUBLIC_IP:-}" ]; then
  PUBLIC_IP=$(curl -fsSL --max-time 5 ifconfig.me 2>/dev/null || echo "")
fi
[ -n "$PUBLIC_IP" ] && info "IP pública: $PUBLIC_IP" || warn "No se pudo obtener la IP pública."

# ════════════════════════════════════════════════════════════
# 1. NODE.JS 20
# ════════════════════════════════════════════════════════════
if ! command -v node &>/dev/null; then
  info "Instalando Node.js 20..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - > /dev/null
  sudo apt-get install -y -qq nodejs
fi
info "Node.js: $(node --version)"

# ════════════════════════════════════════════════════════════
# 2. MYSQL CLIENT
# ════════════════════════════════════════════════════════════
if ! command -v mysql &>/dev/null; then
  info "Instalando MySQL client..."
  sudo apt-get install -y -qq mysql-client
fi
info "MySQL client: $(mysql --version)"

# ════════════════════════════════════════════════════════════
# 3. AWS CLI
# ════════════════════════════════════════════════════════════
if ! command -v aws &>/dev/null; then
  info "Instalando AWS CLI..."
  sudo apt-get install -y -qq awscli
fi
info "AWS CLI: $(aws --version 2>&1 | head -1)"

# ════════════════════════════════════════════════════════════
# 4. DOCKER + COMPOSE (repo oficial)
# ════════════════════════════════════════════════════════════
install_docker() {
  info "Instalando Docker Engine desde repo oficial..."
  sudo apt-get update -y -qq
  sudo apt-get install -y -qq ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  CODENAME=$(lsb_release -cs)
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y -qq
  sudo apt-get install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$REAL_USER" || true
}

if ! command -v docker &>/dev/null; then
  install_docker
elif ! sudo docker compose version &>/dev/null 2>&1; then
  warn "Docker Compose no encontrado, reinstalando..."
  install_docker
fi
info "Docker: $(sudo docker --version)"
info "Compose: $(sudo docker compose version)"

# ════════════════════════════════════════════════════════════
# 5. VALIDAR .env
# ════════════════════════════════════════════════════════════
ENV_FILE="$FRONTEND_DIR/.env"
[ -f "$ENV_FILE" ] || error "No existe $ENV_FILE — copia .env.example y completa los valores."

check_var() {
  grep -qE "^${1}=.+" "$ENV_FILE" || error "Falta la variable ${1} en .env"
}
check_var "DB_HOST"
check_var "DB_USER"
check_var "DB_PASSWORD"
check_var "DB_NAME"
check_var "JWT_SECRET"
check_var "PAYPAL_CLIENT_ID"
check_var "PAYPAL_CLIENT_SECRET"
info ".env validado."

# ════════════════════════════════════════════════════════════
# 6. GENERAR .env.production con la IP actual
# ════════════════════════════════════════════════════════════
API_PORT=$(grep -E '^API_PORT=' "$ENV_FILE" | cut -d= -f2 | tr -d ' ' || echo "4000")
API_PORT="${API_PORT:-4000}"

if [ -n "$PUBLIC_IP" ]; then
  info "Generando .env.production con IP: $PUBLIC_IP"
  echo "REACT_APP_API_BASE=http://${PUBLIC_IP}:${API_PORT}" > "$FRONTEND_DIR/.env.production"
else
  warn ".env.production no se actualizó (no se pudo obtener la IP)."
fi

# ════════════════════════════════════════════════════════════
# 7. LEVANTAR BACKEND + BASE DE DATOS
# ════════════════════════════════════════════════════════════
info "Levantando contenedores..."
cd "$PROJECT_DIR"
sudo docker compose down --remove-orphans 2>/dev/null || true
sudo docker compose up --build --force-recreate -d

info "Esperando a que la API responda..."
for i in $(seq 1 40); do
  if curl -sf "http://localhost:${API_PORT}/api/health" -o /dev/null 2>/dev/null; then
    info "API lista en http://localhost:${API_PORT}/api/health"
    break
  fi
  [ "$i" -eq 40 ] && warn "La API no respondió. Revisa: sudo docker compose logs api"
  sleep 3
done

echo ""
info "Contenedores:"
sudo docker compose ps

# ════════════════════════════════════════════════════════════
# 7b. VERIFICAR E IMPORTAR SCHEMA SQL SI FALTAN DATOS
# ════════════════════════════════════════════════════════════
info "Verificando datos en la base de datos..."
sleep 5
DB_USER=$(grep -E '^DB_USER=' "$ENV_FILE" | cut -d= -f2 | tr -d ' ')
DB_PASS=$(grep -E '^DB_PASSWORD=' "$ENV_FILE" | cut -d= -f2 | tr -d ' ')
DB_NAME=$(grep -E '^DB_NAME=' "$ENV_FILE" | cut -d= -f2 | tr -d ' ')

USER_COUNT=$(sudo docker exec hunnab_db mysql -uroot -prootpass "$DB_NAME" \
  -se "SELECT COUNT(*) FROM usuario;" 2>/dev/null || echo "0")

if [ "$USER_COUNT" = "0" ] || [ -z "$USER_COUNT" ]; then
  warn "Base de datos vacía — importando schema y datos iniciales..."
  SQL_FILE="$FRONTEND_DIR/BD Hunnab.sql"
  if [ -f "$SQL_FILE" ]; then
    sudo cp "$SQL_FILE" /tmp/hunnab_schema.sql
    sudo docker cp /tmp/hunnab_schema.sql hunnab_db:/tmp/hunnab_schema.sql
    if sudo docker exec -i hunnab_db mysql -uroot -prootpass < /tmp/hunnab_schema.sql; then
      info "Schema importado correctamente."
    else
      warn "El import del schema tuvo errores — revisa manualmente."
    fi
  else
    warn "No se encontró $SQL_FILE — importa el schema manualmente."
  fi
else
  info "Base de datos OK — $USER_COUNT usuario(s) encontrado(s)."
fi

# ── Mostrar credenciales del superusuario ─────────────────────
sleep 2
ADMIN_USER=$(sudo docker exec hunnab_db mysql -uroot -prootpass "$DB_NAME" \
  -se "SELECT usuario FROM usuario WHERE tipo_usuario='ADMIN' LIMIT 1;" 2>/dev/null || echo "")

echo ""
echo "============================================"
echo "  Credenciales del administrador"
echo "============================================"
if [ -n "$ADMIN_USER" ]; then
  echo "  Usuario:    $ADMIN_USER"
  echo "  Contraseña: Admin2026!"
  echo "  Tipo:       ADMIN"
else
  warn "No se encontró un usuario ADMIN — verifica el import del schema."
  echo "  Si el import fue exitoso, las credenciales son:"
  echo "  Usuario:    superuser"
  echo "  Contraseña: Admin2026!"
fi
echo "============================================"
echo ""

# ════════════════════════════════════════════════════════════
# 8. BUILD Y DEPLOY DEL FRONTEND A S3
# ════════════════════════════════════════════════════════════
S3_BUCKET="${S3_BUCKET:-}"

if [ -z "$S3_BUCKET" ]; then
  warn "S3_BUCKET no definida — omitiendo deploy del frontend."
  warn "Para deployar: export S3_BUCKET=nombre-bucket && sudo -E ./Scripts/start.sh"
else
  info "Construyendo frontend React..."
  cd "$FRONTEND_DIR"

  # Corregir permisos y correr npm como usuario real
  chown -R "$REAL_USER":"$REAL_USER" "$FRONTEND_DIR" 2>/dev/null || true
  sudo -u "$REAL_USER" npm install --silent

  info "Compilando con REACT_APP_API_BASE=http://${PUBLIC_IP}:${API_PORT}"
  sudo -u "$REAL_USER" npm run build

  REGION="${AWS_DEFAULT_REGION:-us-east-1}"

  info "Subiendo a s3://$S3_BUCKET ..."
  # HTML sin caché
  aws s3 sync build/ "s3://$S3_BUCKET" \
    --exclude "*" --include "*.html" \
    --cache-control "no-cache, no-store, must-revalidate" \
    --delete

  # JS/CSS con caché larga
  aws s3 sync build/ "s3://$S3_BUCKET" \
    --exclude "*.html" \
    --cache-control "public, max-age=31536000, immutable" \
    --delete

  info "Frontend disponible en: http://${S3_BUCKET}.s3-website-${REGION}.amazonaws.com"
fi

# ════════════════════════════════════════════════════════════
# RESUMEN
# ════════════════════════════════════════════════════════════
echo ""
echo "============================================"
echo "  Hunnab.Q corriendo"
echo "============================================"
echo "  API:    http://${PUBLIC_IP:-<IP>}:${API_PORT}"
echo "  Health: http://${PUBLIC_IP:-<IP>}:${API_PORT}/api/health"
[ -n "$S3_BUCKET" ] && \
  echo "  Web:    http://${S3_BUCKET}.s3-website-${AWS_DEFAULT_REGION:-us-east-1}.amazonaws.com"
echo ""
echo "  Ver logs:    sudo docker compose logs -f api"
echo "  Detener:     sudo docker compose down"
echo "============================================"

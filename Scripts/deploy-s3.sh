#!/usr/bin/env bash
# ============================================================
# deploy-s3.sh
# Construye el frontend de React y lo despliega en S3.
#
# Requisitos previos:
#   - aws CLI instalado y configurado (aws configure)
#   - Tener creado el bucket en S3 (o dejar que este script lo cree)
#   - Hunnab/.env.production con REACT_APP_API_BASE=http://<IP-EC2>:4000
#
# Uso:
#   bash Scripts/deploy-s3.sh <nombre-del-bucket>
#   bash Scripts/deploy-s3.sh hunnab-frontend
# ============================================================
set -euo pipefail

BUCKET_NAME="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FRONTEND_DIR="$PROJECT_DIR/Hunnab"
BUILD_DIR="$FRONTEND_DIR/build"

# ── Validaciones ─────────────────────────────────────────────
if [ -z "$BUCKET_NAME" ]; then
  echo "ERROR: Debes pasar el nombre del bucket como argumento."
  echo "Uso: bash Scripts/deploy-s3.sh <nombre-del-bucket>"
  exit 1
fi

if ! command -v aws &>/dev/null; then
  echo "ERROR: aws CLI no encontrado. Instálalo con: pip install awscli"
  exit 1
fi

if [ ! -f "$FRONTEND_DIR/.env.production" ]; then
  echo "ERROR: Falta $FRONTEND_DIR/.env.production"
  echo "Copia .env.production.example y completa REACT_APP_API_BASE con la IP de tu EC2."
  exit 1
fi

# ── Build de React ────────────────────────────────────────────
echo "==> Construyendo React con .env.production..."
cd "$FRONTEND_DIR"
npm run build

# ── Crear bucket si no existe ─────────────────────────────────
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
echo "==> Verificando bucket S3: $BUCKET_NAME (región: $REGION)..."

if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "    Bucket no existe, creándolo..."
  if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
  else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi
fi

# ── Configurar bucket para hosting estático ───────────────────
echo "==> Configurando hosting estático..."
aws s3api put-bucket-website \
  --bucket "$BUCKET_NAME" \
  --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "index.html"}
  }'

# Deshabilitar bloqueo de acceso público
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Política de lectura pública
aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Sid\": \"PublicReadGetObject\",
      \"Effect\": \"Allow\",
      \"Principal\": \"*\",
      \"Action\": \"s3:GetObject\",
      \"Resource\": \"arn:aws:s3:::${BUCKET_NAME}/*\"
    }]
  }"

# ── Subir archivos ────────────────────────────────────────────
echo "==> Subiendo build/ a s3://$BUCKET_NAME ..."

# HTML: sin caché (para que siempre cargue la versión nueva)
aws s3 sync "$BUILD_DIR" "s3://$BUCKET_NAME" \
  --exclude "*" \
  --include "*.html" \
  --cache-control "no-cache, no-store, must-revalidate" \
  --delete

# JS/CSS/media: caché larga (CRA genera nombres únicos con hash)
aws s3 sync "$BUILD_DIR" "s3://$BUCKET_NAME" \
  --exclude "*.html" \
  --cache-control "public, max-age=31536000, immutable" \
  --delete

# ── URL final ────────────────────────────────────────────────
echo ""
echo "✓ Deploy completado."
echo "  URL del sitio: http://${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"
echo ""
echo "  Próximo paso opcional: conecta CloudFront a este bucket para HTTPS."

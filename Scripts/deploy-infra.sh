#!/usr/bin/env bash
# ============================================================
# deploy-infra.sh
# Despliega (o actualiza) los stacks de CloudFormation:
#   1. hunnab-s3   — Bucket S3 para el frontend
# ============================================================
set -euo pipefail

# ── Configuración ────────────────────────────────────────────
REGION="${AWS_REGION:-us-west-1}"
PROJECT="hunnab"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$SCRIPT_DIR/../infra"

S3_BUCKET_NAME="${S3_BUCKET:-hunnab-frontend-2026}"

# ── Colores ──────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warning() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Verificar AWS CLI ────────────────────────────────────────
command -v aws &>/dev/null || die "AWS CLI no instalado. Ejecuta: brew install awscli"
aws sts get-caller-identity --region "$REGION" &>/dev/null \
  || die "Credenciales AWS no configuradas. Ejecuta: aws configure"

# ── Función: crear o actualizar un stack ─────────────────────
deploy_stack() {
  local stack_name="$1"
  local template_file="$2"
  shift 2
  local params=("$@")

  local param_string=""
  for p in "${params[@]}"; do
    param_string+="ParameterKey=${p%%=*},ParameterValue=${p#*=} "
  done

  # Verificar si el stack ya existe
  local status
  status=$(aws cloudformation describe-stacks \
    --stack-name "$stack_name" \
    --region "$REGION" \
    --query "Stacks[0].StackStatus" \
    --output text 2>/dev/null || echo "DOES_NOT_EXIST")

  if [[ "$status" == "DOES_NOT_EXIST" ]]; then
    info "Creando stack '$stack_name'..."
    aws cloudformation create-stack \
      --stack-name "$stack_name" \
      --template-body "file://$template_file" \
      --parameters $param_string \
      --region "$REGION"

    info "Esperando a que '$stack_name' termine de crearse..."
    aws cloudformation wait stack-create-complete \
      --stack-name "$stack_name" \
      --region "$REGION"
    info "Stack '$stack_name' creado."

  elif [[ "$status" == "ROLLBACK_COMPLETE" ]]; then
    warning "Stack '$stack_name' en ROLLBACK_COMPLETE — eliminando antes de recrear..."
    aws cloudformation delete-stack --stack-name "$stack_name" --region "$REGION"
    aws cloudformation wait stack-delete-complete --stack-name "$stack_name" --region "$REGION"
    deploy_stack "$stack_name" "$template_file" "$@"

  else
    info "Actualizando stack '$stack_name' (estado: $status)..."
    if aws cloudformation update-stack \
      --stack-name "$stack_name" \
      --template-body "file://$template_file" \
      --parameters $param_string \
      --region "$REGION" 2>&1 | grep -q "No updates are to be performed"; then
      warning "Stack '$stack_name' sin cambios — nada que actualizar."
    else
      info "Esperando a que '$stack_name' termine de actualizarse..."
      aws cloudformation wait stack-update-complete \
        --stack-name "$stack_name" \
        --region "$REGION"
      info "Stack '$stack_name' actualizado."
    fi
  fi
}

# ── Función: obtener output de un stack ──────────────────────
get_output() {
  local stack_name="$1"
  local key="$2"
  aws cloudformation describe-stacks \
    --stack-name "$stack_name" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='$key'].OutputValue" \
    --output text
}

# ════════════════════════════════════════════════════════════
echo ""
echo "============================================"
echo "  Hunnab.Q — Deploy de infraestructura"
echo "  Region: $REGION"
echo "============================================"
echo ""

# ── 1. S3 ────────────────────────────────────────────────────
if aws s3api head-bucket --bucket "$S3_BUCKET_NAME" --region "$REGION" 2>/dev/null; then
  warning "Bucket '$S3_BUCKET_NAME' ya existe — saltando creación del stack S3."
  FRONTEND_URL="http://${S3_BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"
else
  deploy_stack "hunnab-s3" "$INFRA_DIR/s3-frontend.json" \
    "BucketName=$S3_BUCKET_NAME"
  FRONTEND_URL=$(get_output "hunnab-s3" "FrontendURL")
fi

# ── Resumen ──────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  Infraestructura lista"
echo "============================================"
echo "  Frontend URL: $FRONTEND_URL"
echo "============================================"
echo ""

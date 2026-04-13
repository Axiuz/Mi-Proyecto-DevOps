#!/usr/bin/env bash
# ============================================================
# backup.sh  —  Respaldos locales automáticos (cada 24 hrs)
#
# Qué respalda:
#   1. Dump completo de la base de datos MySQL (desde Docker)
#   2. Archivo .env (configuración sensible)
#
# Dónde guarda:
#   ~/backups/hunnab/YYYY-MM-DD_HH-MM-SS/
#
# Retención: últimos 7 respaldos (los anteriores se borran)
#
# Activar cron automático (una sola vez):
#   bash ~/app/Scripts/backup.sh --setup-cron
#
# Ejecutar manualmente:
#   bash ~/app/Scripts/backup.sh
# ============================================================
set -euo pipefail

# ── Configuración ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_DIR/Hunnab/.env"

BACKUP_ROOT="$HOME/backups/hunnab"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
KEEP_LAST=7                    # Número de respaldos a conservar
LOG_FILE="$BACKUP_ROOT/backup.log"

# Contenedor y base de datos (leídos desde .env)
DB_CONTAINER="hunnab_db"

# ── Colores ───────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[backup]${NC} $*" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${YELLOW}[backup][!]${NC} $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[backup][ERROR]${NC} $*" | tee -a "$LOG_FILE"; exit 1; }

# ── Modo --setup-cron ─────────────────────────────────────────
if [ "${1:-}" = "--setup-cron" ]; then
  CRON_CMD="0 3 * * * bash $SCRIPT_DIR/backup.sh >> $BACKUP_ROOT/backup.log 2>&1"

  # Evitar duplicados: borra la línea anterior del mismo script si existe
  (crontab -l 2>/dev/null | grep -v "backup.sh" ; echo "$CRON_CMD") | crontab -

  echo ""
  echo "============================================"
  echo "  Cron configurado correctamente"
  echo "============================================"
  echo "  Ejecución: todos los dias a las 03:00 AM"
  echo "  Log:       $BACKUP_ROOT/backup.log"
  echo "  Retención: últimos $KEEP_LAST respaldos"
  echo ""
  echo "  Verificar con:  crontab -l"
  echo "  Remover con:    crontab -l | grep -v backup.sh | crontab -"
  echo "============================================"
  echo ""
  exit 0
fi

# ── Inicio del respaldo ───────────────────────────────────────
mkdir -p "$BACKUP_DIR"
echo "" >> "$LOG_FILE"
info "========== Inicio: $TIMESTAMP =========="

# ── Leer variables desde .env ─────────────────────────────────
[ -f "$ENV_FILE" ] || error "No existe $ENV_FILE"

DB_NAME=$(grep -E '^DB_NAME=' "$ENV_FILE" | cut -d= -f2 | tr -d ' ')
DB_USER=$(grep -E '^DB_USER=' "$ENV_FILE" | cut -d= -f2 | tr -d ' ')
DB_PASS=$(grep -E '^DB_PASSWORD=' "$ENV_FILE" | cut -d= -f2 | tr -d ' ')

[ -n "$DB_NAME" ]  || error "DB_NAME no encontrado en .env"
[ -n "$DB_USER" ]  || error "DB_USER no encontrado en .env"
[ -n "$DB_PASS" ]  || error "DB_PASSWORD no encontrado en .env"

# ── 1. Dump de la base de datos ───────────────────────────────
info "Generando dump de MySQL ($DB_NAME)..."

DUMP_FILE="$BACKUP_DIR/db_${DB_NAME}_${TIMESTAMP}.sql.gz"

if sudo docker inspect "$DB_CONTAINER" &>/dev/null; then
  sudo docker exec "$DB_CONTAINER" \
    mysqldump -u"$DB_USER" -p"$DB_PASS" \
    --single-transaction --routines --triggers --events \
    "$DB_NAME" \
    | gzip > "$DUMP_FILE"

  DUMP_SIZE=$(du -sh "$DUMP_FILE" | cut -f1)
  info "Dump guardado: $(basename "$DUMP_FILE") ($DUMP_SIZE)"
else
  warn "Contenedor '$DB_CONTAINER' no está corriendo — dump omitido."
fi

# ── 2. Respaldo del .env ──────────────────────────────────────
info "Respaldando .env..."
cp "$ENV_FILE" "$BACKUP_DIR/.env.backup"
info ".env guardado."

# ── 3. Comprimir todo el respaldo ─────────────────────────────
info "Comprimiendo respaldo..."
ARCHIVE="$BACKUP_ROOT/hunnab_backup_${TIMESTAMP}.tar.gz"
tar -czf "$ARCHIVE" -C "$BACKUP_ROOT" "$TIMESTAMP"
rm -rf "$BACKUP_DIR"    # Eliminar carpeta temporal, ya está en el .tar.gz

ARCHIVE_SIZE=$(du -sh "$ARCHIVE" | cut -f1)
info "Archivo final: $(basename "$ARCHIVE") ($ARCHIVE_SIZE)"

# ── 4. Rotación: eliminar respaldos viejos ────────────────────
info "Aplicando retención (últimos $KEEP_LAST respaldos)..."
TOTAL=$(find "$BACKUP_ROOT" -maxdepth 1 -name "hunnab_backup_*.tar.gz" | wc -l)

if [ "$TOTAL" -gt "$KEEP_LAST" ]; then
  ELIMINAR=$(( TOTAL - KEEP_LAST ))
  find "$BACKUP_ROOT" -maxdepth 1 -name "hunnab_backup_*.tar.gz" \
    | sort | head -n "$ELIMINAR" \
    | while read -r old; do
        rm -f "$old"
        info "Eliminado: $(basename "$old")"
      done
else
  info "Respaldos actuales: $TOTAL / $KEEP_LAST — no se eliminó nada."
fi

# ── Resumen ───────────────────────────────────────────────────
echo ""
info "========== Respaldo completado =========="
info "Directorio: $BACKUP_ROOT"
info "Respaldos disponibles:"
find "$BACKUP_ROOT" -maxdepth 1 -name "hunnab_backup_*.tar.gz" \
  | sort | while read -r f; do
      echo "    $(basename "$f")  ($(du -sh "$f" | cut -f1))"
    done
info "========================================="
echo ""

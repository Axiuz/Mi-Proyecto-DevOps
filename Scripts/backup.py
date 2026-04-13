#!/usr/bin/env python3
import subprocess
import sys
import tarfile
from datetime import datetime
from pathlib import Path

SCRIPT_DIR   = Path(__file__).resolve().parent
PROJECT_DIR  = SCRIPT_DIR.parent
BACKUP_ROOT  = Path.home() / "backups" / "hunnab"
TIMESTAMP    = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
LOG_FILE     = BACKUP_ROOT / "backup.log"
KEEP_LAST    = 3


def log(msg: str, level: str = "INFO") -> None:
    line = f"[{level}] {msg}"
    print(line)
    with open(LOG_FILE, "a") as f:
        f.write(line + "\n")


def die(msg: str) -> None:
    log(msg, "ERROR")
    sys.exit(1)


def setup_cron() -> None:
    cron_cmd = f"0 3 * * * python3 {SCRIPT_DIR / 'backup.py'} >> {LOG_FILE} 2>&1"
    result   = subprocess.run(["crontab", "-l"], capture_output=True, text=True)
    lines    = [l for l in result.stdout.splitlines() if "backup.py" not in l]
    subprocess.run(["crontab", "-"], input="\n".join(lines + [cron_cmd]) + "\n",
                   text=True, check=True)
    print(f"Cron configurado — ejecución diaria 03:00 AM\nLog: {LOG_FILE}")


def main() -> None:
    if "--setup-cron" in sys.argv:
        setup_cron()
        return

    BACKUP_ROOT.mkdir(parents=True, exist_ok=True)
    log(f"Inicio: {TIMESTAMP}")

    # Comprimir toda la carpeta del proyecto
    archive = BACKUP_ROOT / f"hunnab_backup_{TIMESTAMP}.tar.gz"
    with tarfile.open(archive, "w:gz") as tar:
        tar.add(PROJECT_DIR, arcname=PROJECT_DIR.name)
    log(f"Archivo: {archive.name}")

    # Rotar: eliminar los más antiguos si hay más de KEEP_LAST
    archives = sorted(BACKUP_ROOT.glob("hunnab_backup_*.tar.gz"))
    for old in archives[: max(0, len(archives) - KEEP_LAST)]:
        old.unlink()
        log(f"Eliminado: {old.name}")

    log("Respaldo completado")
    print(f"BACKUP_PATH={archive}")


if __name__ == "__main__":
    main()

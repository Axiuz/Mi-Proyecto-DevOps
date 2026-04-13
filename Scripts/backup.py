#!/usr/bin/env python3

import shutil
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


def read_env(key: str) -> str:
    match = re.search(rf"^{key}=(.+)$", ENV_FILE.read_text(), re.MULTILINE)
    if not match:
        die(f"{key} no encontrado en .env")
    return match.group(1).strip()


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

    if not ENV_FILE.exists():
        die(f"No existe {ENV_FILE}")

    BACKUP_ROOT.mkdir(parents=True, exist_ok=True)
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    log(f"Inicio: {TIMESTAMP}")

    db_name = read_env("DB_NAME")
    db_user = read_env("DB_USER")
    db_pass = read_env("DB_PASSWORD")

    # Dump MySQL
    inspect = subprocess.run(["sudo", "docker", "inspect", DB_CONTAINER],
                             capture_output=True)
    if inspect.returncode != 0:
        log(f"Contenedor '{DB_CONTAINER}' no corre — dump omitido.", "WARN")
    else:
        proc = subprocess.run(
            ["sudo", "docker", "exec", DB_CONTAINER,
             "mysqldump", f"-u{db_user}", f"-p{db_pass}",
             "--single-transaction", "--routines", "--triggers", "--events",
             db_name],
            capture_output=True, check=True,
        )
        dump_file = BACKUP_DIR / f"db_{db_name}_{TIMESTAMP}.sql.gz"
        with gzip.open(dump_file, "wb") as gz:
            gz.write(proc.stdout)
        log(f"Dump guardado: {dump_file.name}")

    # Backup .env
    shutil.copy2(ENV_FILE, BACKUP_DIR / ".env.backup")
    log(".env respaldado")

    # Comprimir y limpiar carpeta temporal
    archive = BACKUP_ROOT / f"hunnab_backup_{TIMESTAMP}.tar.gz"
    with tarfile.open(archive, "w:gz") as tar:
        tar.add(BACKUP_DIR, arcname=TIMESTAMP)
    shutil.rmtree(BACKUP_DIR)
    log(f"Archivo: {archive.name}")

    # Rotar respaldos viejos
    archives = sorted(BACKUP_ROOT.glob("hunnab_backup_*.tar.gz"))
    for old in archives[: max(0, len(archives) - KEEP_LAST)]:
        old.unlink()
        log(f"Eliminado: {old.name}")

    log("Respaldo completado")


if __name__ == "__main__":
    main()

#!/bin/bash

REMOTE_URL="https://github.com/Axiuz/DevOps.git"
BRANCH="pruebas"

echo "=== Git Autocommit ==="
echo ""

read -p "Usuario de GitHub: " usuario
read -s -p "Token / Contraseña: " token
echo ""
read -p "Mensaje del commit (Enter = 'Automated commit'): " mensaje
mensaje="${mensaje:-Automated commit}"

url_con_credenciales="https://${usuario}:${token}@github.com/Axiuz/DevOps.git"

if git remote get-url origin > /dev/null 2>&1; then
    echo ""
    echo "[!] Remote ya existe, actualizando URL..."
    git remote set-url origin "$url_con_credenciales"
else
    echo ""
    echo "[+] Añadiendo remote origin..."
    git remote add origin "$url_con_credenciales"
fi

echo "[+] Agregando archivos..."
git add .

echo "[+] Commit: '$mensaje'"
git commit -m "$mensaje"

echo "[+] Subiendo cambios..."
git push -u origin "$BRANCH"

echo ""
echo "[✔] ¡Listo!"
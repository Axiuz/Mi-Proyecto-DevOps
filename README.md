# Hunnab.Q

> Plataforma web fullstack construida con React, Node/Express y MySQL, desplegada en AWS (EC2 + S3).

---

## Estructura del proyecto

```
Mi-Proyecto-DevOps-2/
├── Hunnab/                  # Código fuente principal
│   ├── public/              # Assets estáticos
│   ├── src/                 # Frontend React
│   ├── server/              # API Node/Express
│   │   └── db.mjs           # Conexión MySQL con mysql2/promise
│   ├── build/               # Build de producción (generado)
│   ├── BD Hunnab.sql        # Schema e datos iniciales de la base de datos
│   ├── Dockerfile           # Imagen Docker del backend
│   ├── .env                 # Variables de entorno (NO subir a git)
│   ├── .env.example         # Plantilla de variables de entorno
│   └── package.json
├── Scripts/
│   ├── start.sh             # Script principal de despliegue en EC2
│   ├── deploy-ec2.sh        # Script de deploy al servidor EC2
│   └── deploy-s3.sh         # Script de deploy del frontend a S3
├── docker-compose.yml       # Orquestación de contenedores (API + MySQL)
└── README.md
```

---

## Stack tecnológico

| Capa           | Tecnología                        |
|----------------|-----------------------------------|
| Frontend       | React (desplegado en S3)          |
| Backend        | Node.js + Express (Docker en EC2) |
| Base de datos  | MySQL 8 (Docker en EC2)           |
| Infraestructura| AWS EC2 + S3                      |
| Contenedores   | Docker + Docker Compose           |

---

## Despliegue en una nueva instancia EC2

### Prerrequisitos

- Instancia EC2 con Ubuntu (recomendado: Ubuntu 22.04 LTS)
- Par de claves `.pem` para acceso SSH
- Usuario IAM con permisos sobre S3 (para el deploy del frontend)
- Bucket S3 configurado como sitio web estático
- Repositorio clonado localmente

---

### 1. Abrir el puerto 4000 en el Security Group

En la consola de AWS, edita el Security Group de la instancia y agrega una **Inbound Rule**:

| Campo       | Valor            |
|-------------|------------------|
| Type        | Custom TCP       |
| Port range  | 4000             |
| Source      | 0.0.0.0/0        |

---

### 2. Conectarse a la instancia por SSH

```bash
ssh -i ~/<PATH>/<ARCHIVO.pem> ubuntu@<PUBLIC_IP>
```

---

### 3. Instalar AWS CLI en la instancia

```bash
sudo apt update
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

---

### 4. Configurar credenciales de AWS

```bash
aws configure
```

Ingresa cuando se solicite:
- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region name** (ej. `us-east-1`)
- **Default output format** (ej. `json`)

---

### 5. Sincronizar el repositorio local con la instancia

Desde tu **terminal local**, ejecuta:

```bash
rsync -avz --exclude 'node_modules' --exclude '.git' \
  -e "ssh -i ~/<PATH>/<ARCHIVO.pem>" \
  . ubuntu@<PUBLIC_IP>:~/app
```

Reemplaza:
- `<PATH>/<ARCHIVO.pem>` con la ruta a tu llave SSH
- `<PUBLIC_IP>` con la IP pública de tu instancia EC2

Verifica que la carpeta se creó correctamente en la instancia:

```bash
ls ~/app
```

---

### 6. Configurar el archivo `.env`

El script valida que exista `Hunnab/.env` antes de ejecutar. Copia la plantilla y completa los valores:

```bash
cp ~/app/Hunnab/.env.example ~/app/Hunnab/.env
nano ~/app/Hunnab/.env
```

Variables requeridas:

```env
DB_HOST=db
DB_PORT=3306
DB_USER=appuser
DB_PASSWORD=tu_password
DB_NAME=Hunnab_Q

API_PORT=4000
CORS_ORIGIN=http://localhost:3000,http://<S3_BUCKET>.s3-website-us-east-1.amazonaws.com
FRONTEND_BASE_URL=http://<S3_BUCKET>.s3-website-us-east-1.amazonaws.com

JWT_SECRET=tu_jwt_secret
JWT_EXPIRES_IN_SECONDS=86400
JWT_ISSUER=hunnab-api
JWT_AUDIENCE=hunnab-web

PAYPAL_ENV=sandbox
PAYPAL_CLIENT_ID=tu_paypal_client_id
PAYPAL_CLIENT_SECRET=tu_paypal_client_secret
PAYPAL_CURRENCY=MXN

EMAILJS_SERVICE_ID=tu_service_id
EMAILJS_TEMPLATE_ID=tu_template_id
EMAILJS_PUBLIC_KEY=tu_public_key
EMAILJS_PRIVATE_KEY=tu_private_key
```

---

### 7. Ejecutar el script de despliegue

Desde la instancia EC2:

```bash
export S3_BUCKET=hunnab-frontend-2026
cd ~/app && sudo -E ./Scripts/start.sh
```

El script se encarga automáticamente de:

1. Detectar la IP pública de la instancia
2. Instalar Node.js 20, MySQL client, AWS CLI y Docker (si no están instalados)
3. Validar que todas las variables requeridas estén en `.env`
4. Generar `.env.production` con la IP actual para el frontend
5. Levantar los contenedores de API y MySQL con Docker Compose
6. Esperar a que la API responda en `/api/health`
7. Importar el schema SQL si la base de datos está vacía
8. Hacer el build del frontend React y subirlo al bucket S3

---

### 8. Verificar el despliegue

Al finalizar el script verás un resumen similar a este:

```
============================================
  Hunnab.Q corriendo
============================================
  API:    http://<IP>:4000
  Health: http://<IP>:4000/api/health
  Web:    http://hunnab-frontend-2026.s3-website-us-east-1.amazonaws.com
============================================
```

**Credenciales del administrador por defecto:**

| Campo      | Valor       |
|------------|-------------|
| Usuario    | superuser   |
| Contraseña | Admin2026!  |
| Tipo       | ADMIN       |

---

## Comandos útiles

```bash
# Ver logs de la API en tiempo real
sudo docker compose logs -f api

# Ver logs de la base de datos
sudo docker compose logs -f db

# Ver estado de los contenedores
sudo docker compose ps

# Detener todos los contenedores
sudo docker compose down

# Redesplegar tras cambios (desde ~/app)
export S3_BUCKET=hunnab-frontend-2026
cd ~/app && sudo -E ./Scripts/start.sh
```

---

## Desarrollo local

### Prerrequisitos

- Node.js v18 o superior
- Docker y Docker Compose
- Git

### Levantar el entorno local

```bash
# 1. Clonar el repositorio
git clone https://github.com/Axiuz/Hunnab.Q.git
cd Mi-Proyecto-DevOps-2

# 2. Configurar variables de entorno
cp Hunnab/.env.example Hunnab/.env
# Edita Hunnab/.env con tus valores locales

# 3. Levantar contenedores (API + MySQL)
docker compose up --build -d

# 4. En otra terminal, iniciar el frontend en modo desarrollo
cd Hunnab && npm install && npm start
```

| Servicio  | URL                   |
|-----------|-----------------------|
| Frontend  | http://localhost:3000 |
| API REST  | http://localhost:4000 |

---

## Respaldos automáticos

El script `Scripts/backup.sh` genera respaldos locales en la instancia EC2 de forma totalmente independiente del stack principal.

**Qué respalda:**
- Dump completo de MySQL (comprimido con gzip)
- Archivo `.env`

**Dónde los guarda:** `~/backups/hunnab/`

**Retención:** últimos 7 respaldos (los más antiguos se eliminan automáticamente)

### Activar el cron (una sola vez)

```bash
bash ~/app/Scripts/backup.sh --setup-cron
```

Esto programa el script para ejecutarse **todos los días a las 3:00 AM**. Para verificarlo:

```bash
crontab -l
```

### Ejecutar un respaldo manual

```bash
bash ~/app/Scripts/backup.sh
```

### Gestión del cron

```bash
# Ver el cron activo
crontab -l

# Desactivar el respaldo automático
crontab -l | grep -v backup.sh | crontab -
```

### Ver el historial de respaldos

```bash
ls -lh ~/backups/hunnab/
cat ~/backups/hunnab/backup.log
```

---

## Autocommit

El script `Hunnab/autocommit.sh` automatiza el flujo `add → commit → push`.

```bash
chmod +x Hunnab/autocommit.sh
./Hunnab/autocommit.sh
```

Requiere un **Personal Access Token** de GitHub con scope `repo`. Generarlo en:  
**Settings → Developer settings → Personal access tokens → Tokens (classic)**

---

## Contribuciones

Las contribuciones son bienvenidas. Por favor abre un _issue_ antes de enviar un _pull request_ con cambios significativos.

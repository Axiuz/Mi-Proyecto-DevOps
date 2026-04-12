# Hunnab.Q

> Plataforma web fullstack construida con React, Node/Express y MySQL.

---

## Estructura del proyecto

```
Hunnab.Q/
├── public/          # Assets estáticos
├── src/             # Frontend React
├── server/          # API Node/Express
│   └── db.mjs       # Conexión MySQL con mysql2/promise
├── build/           # Build de producción
├── BD Hunnab.sql    # Script de base de datos
├── .env.example     # Variables de entorno de ejemplo
├── autocommit.sh    # Script de autocommit para Git
└── package.json
```

---

## Requisitos previos

- [Node.js](https://nodejs.org/) v18 o superior
- [MySQL](https://www.mysql.com/) v8 o superior
- npm
- Git instalado y configurado
- Cuenta de GitHub con acceso al repositorio

---

## 1. Clonar el repositorio

```bash
git clone https://github.com/Axiuz/Hunnab.Q.git
cd Hunnab.Q
```

---

## 2. Instalar dependencias

```bash
npm install
```

---

## 3. Configurar variables de entorno

```bash
cp .env.example .env
```

Edita el archivo `.env` con tus credenciales de MySQL y demás configuración necesaria:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=tu_usuario
DB_PASSWORD=tu_contraseña
DB_NAME=hunnab
PORT=4000
```

---

## 4. Crear la base de datos

Ejecuta el script SQL en tu servidor MySQL:

```bash
mysql -u tu_usuario -p < "BD Hunnab.sql"
```

---

## 5. Levantar el proyecto en desarrollo

Necesitas dos terminales corriendo simultáneamente:

**Terminal 1 — API (Puerto 4000)**

```bash
npm run api
```

**Terminal 2 — Frontend (Puerto 3000)**

```bash
npm start
```

| Servicio  | URL                        |
|-----------|----------------------------|
| Frontend  | http://localhost:3000       |
| API REST  | http://localhost:4000       |

---

## 6. Build de producción (opcional)

Cuando el proyecto esté listo para producción:

```bash
npm run build
```

Los archivos compilados quedarán en la carpeta `/build`.

---

## 7. Crear un Token de GitHub (antes del primer commit)

El script de autocommit requiere autenticación mediante un **Personal Access Token (PAT)** en lugar de tu contraseña.

**Pasos para generarlo:**

1. Inicia sesión en [github.com](https://github.com)
2. Ve a **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
3. Haz clic en **"Generate new token (classic)"**
4. Configura el token:
   - **Note:** ponle un nombre descriptivo, por ejemplo `hunnab-autocommit`
   - **Expiration:** elige la vigencia que prefieras (recomendado: 90 días)
   - **Scopes:** selecciona los siguientes permisos:
     - ✅ `repo` — acceso completo a repositorios privados y públicos
5. Haz clic en **"Generate token"**
6. **Copia el token inmediatamente** — GitHub no lo mostrará de nuevo

> ⚠️ Guarda el token en un lugar seguro (gestor de contraseñas). Si lo pierdes, tendrás que generar uno nuevo.

---

## 8. Hacer commit con el script de Autocommit

Una vez que hayas hecho cambios en el proyecto, usa `autocommit.sh` para automatizar el flujo de `add → commit → push`.

### Dar permisos de ejecución (solo la primera vez)

```bash
chmod +x autocommit.sh
```

### Uso

```bash
./autocommit.sh
```

El script te pedirá de forma interactiva:

| Prompt | Descripción |
|--------|-------------|
| `Usuario de GitHub` | Tu nombre de usuario en GitHub |
| `Token / Contraseña` | El Personal Access Token generado en el paso anterior (se oculta al escribir) |
| `Mensaje del commit` | Descripción del cambio. Si presionas Enter, usa `"Automated commit"` por defecto |

### ¿Qué hace el script?

1. Configura (o actualiza) el remote `origin` con tus credenciales
2. Ejecuta `git add .` — agrega todos los archivos modificados
3. Ejecuta `git commit -m "tu mensaje"`
4. Ejecuta `git push`

> ⚠️ **Seguridad:** el token se incrusta temporalmente en la URL del remote. Se recomienda no dejar sesiones abiertas en equipos compartidos y rotar el token periódicamente.

---

## Stack tecnológico

| Capa       | Tecnología                      |
|------------|---------------------------------|
| Frontend   | React                           |
| Backend    | Node.js + Express               |
| Base de datos | MySQL + `mysql2/promise`     |
| Estilos    | CSS                             |

---

## Scripts disponibles

| Comando           | Descripción                              |
|-------------------|------------------------------------------|
| `npm start`       | Inicia el frontend en modo desarrollo    |
| `npm run api`     | Inicia el servidor Express               |
| `npm run build`   | Genera el build de producción            |
| `./autocommit.sh` | Automatiza add, commit y push a GitHub   |

---

## Contribuciones

Las contribuciones son bienvenidas. Por favor abre un _issue_ antes de enviar un _pull request_ con cambios significativos.



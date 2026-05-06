CREATE DATABASE IF NOT EXISTS Hunnab_Q
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE Hunnab_Q;

-- -----------------------------------------------
--  2. Usuario de aplicación y privilegios
-- -----------------------------------------------
-- '%' es necesario para que el contenedor Docker de la API pueda conectarse
CREATE USER IF NOT EXISTS 'appuser'@'%'         IDENTIFIED BY 'AppPass_123!';
CREATE USER IF NOT EXISTS 'appuser'@'localhost'  IDENTIFIED BY 'AppPass_123!';
CREATE USER IF NOT EXISTS 'appuser'@'127.0.0.1' IDENTIFIED BY 'AppPass_123!';

GRANT ALL PRIVILEGES ON Hunnab_Q.* TO 'appuser'@'%';
GRANT ALL PRIVILEGES ON Hunnab_Q.* TO 'appuser'@'localhost';
GRANT ALL PRIVILEGES ON Hunnab_Q.* TO 'appuser'@'127.0.0.1';
FLUSH PRIVILEGES;

-- -----------------------------------------------
--  3. Tablas
-- -----------------------------------------------

-- USUARIO
CREATE TABLE IF NOT EXISTS usuario (
  id_usuario    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80)  NOT NULL,
  correo        VARCHAR(150) NOT NULL,
  usuario       VARCHAR(80)  NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  tipo_usuario  ENUM('CUENTA','INVITADO','ADMIN') NOT NULL DEFAULT 'CUENTA',
  fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_usuario_correo  UNIQUE (correo),
  CONSTRAINT uq_usuario_usuario UNIQUE (usuario)
) ENGINE=InnoDB;

-- PRODUCTO
CREATE TABLE IF NOT EXISTS producto (
  id_producto    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre         VARCHAR(150) NOT NULL,
  descripcion    TEXT NULL,
  precio         DECIMAL(10,2) NOT NULL,
  stock          INT UNSIGNED NOT NULL DEFAULT 0,
  categoria      ENUM(
    'ANILLO',
    'COLLAR_MUJER',
    'COLLAR_HOMBRE',
    'PULSERA_MUJER',
    'PULSERA_HOMBRE',
    'ARETE'
  ) NOT NULL,
  fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- PEDIDOS
CREATE TABLE IF NOT EXISTS pedidos (
  id_pedido       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario      INT UNSIGNED NOT NULL,
  id_producto     INT UNSIGNED NOT NULL,
  cantidad        INT UNSIGNED NOT NULL DEFAULT 1,
  talla           VARCHAR(10) NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal        DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
  estado          ENUM('PENDIENTE','EN PREPARACION','ENVIADO') NOT NULL DEFAULT 'PENDIENTE',
  fecha_creacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_pedidos_usuario  FOREIGN KEY (id_usuario)  REFERENCES usuario(id_usuario)  ON DELETE CASCADE,
  CONSTRAINT fk_pedidos_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------
--  4. Índices (seguros ante re-ejecución)
-- -----------------------------------------------
SELECT IF(
  EXISTS(SELECT 1 FROM information_schema.STATISTICS
         WHERE table_schema='Hunnab_Q' AND table_name='usuario' AND index_name='idx_usuario_correo'),
  'SELECT ''idx_usuario_correo ya existe, omitiendo.'';',
  'CREATE INDEX idx_usuario_correo ON usuario(correo);'
) INTO @sql; PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(
  EXISTS(SELECT 1 FROM information_schema.STATISTICS
         WHERE table_schema='Hunnab_Q' AND table_name='producto' AND index_name='idx_producto_categoria'),
  'SELECT ''idx_producto_categoria ya existe, omitiendo.'';',
  'CREATE INDEX idx_producto_categoria ON producto(categoria);'
) INTO @sql; PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(
  EXISTS(SELECT 1 FROM information_schema.STATISTICS
         WHERE table_schema='Hunnab_Q' AND table_name='pedidos' AND index_name='idx_pedidos_usuario_estado'),
  'SELECT ''idx_pedidos_usuario_estado ya existe, omitiendo.'';',
  'CREATE INDEX idx_pedidos_usuario_estado ON pedidos(id_usuario, estado);'
) INTO @sql; PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- -----------------------------------------------
--  5. Datos iniciales
-- -----------------------------------------------

-- Super usuario administrador
INSERT IGNORE INTO usuario (nombre, correo, usuario, password_hash, tipo_usuario)
VALUES (
  'Super User',
  'super@hunnab.com',
  'superuser',
  '$2b$10$Mde/zGg/DYuAaI.uVyW21OSVJRLzDue8ysNI3D5DcYp5Pknk8vtLq', -- Admin2026!
  'ADMIN'
);

-- Catálogo de productos
INSERT INTO producto (nombre, descripcion, precio, stock, categoria)
SELECT s.nombre, s.descripcion, s.precio, s.stock, s.categoria
FROM (
  SELECT 'Collar Aquamarina'         AS nombre, 'Collar de la coleccion base Hunnab.Q.'  AS descripcion, 250.00 AS precio, 15 AS stock, 'COLLAR_HOMBRE'  AS categoria
  UNION ALL SELECT 'Collar Nautilus',         'Collar de la coleccion base Hunnab.Q.',  270.00, 12, 'COLLAR_HOMBRE'
  UNION ALL SELECT 'Collar Libelula',         'Collar de la coleccion base Hunnab.Q.',  170.00, 18, 'COLLAR_HOMBRE'
  UNION ALL SELECT 'Collar Amatista',         'Collar de la coleccion base Hunnab.Q.',  280.00, 10, 'COLLAR_MUJER'
  UNION ALL SELECT 'Collar Oro',              'Collar de la coleccion base Hunnab.Q.',  310.00,  8, 'COLLAR_MUJER'
  UNION ALL SELECT 'Arracadas Clasicas',      'Arete de la coleccion base Hunnab.Q.',   260.00, 14, 'ARETE'
  UNION ALL SELECT 'Arracadas Chunky',        'Arete de la coleccion base Hunnab.Q.',   320.00,  9, 'ARETE'
  UNION ALL SELECT 'Anillo Modelo',           'Anillo de la coleccion base Hunnab.Q.',  290.00, 11, 'ANILLO'
  UNION ALL SELECT 'Anillo Muestra',          'Anillo de la coleccion base Hunnab.Q.',  260.00, 16, 'ANILLO'
  UNION ALL SELECT 'Pulsera Piedra Volcanica','Pulsera de la coleccion base Hunnab.Q.', 180.00, 20, 'PULSERA_HOMBRE'
  UNION ALL SELECT 'Pulsera Onyx',            'Pulsera de la coleccion base Hunnab.Q.', 210.00, 13, 'PULSERA_MUJER'
) AS s
LEFT JOIN producto p ON p.nombre = s.nombre
WHERE p.id_producto IS NULL;

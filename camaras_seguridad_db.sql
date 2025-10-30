CREATE DATABASE camaras_seguridad_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;
USE camaras_seguridad_db;

-- Cambié 'roles' -> 'tipo_usuario' y 'id_rol' -> 'id_tipo_usuario'
CREATE TABLE tipo_usuario (
  id_tipo_usuario TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255),
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_tipo_usuario),
  CHECK (is_deleted IN (0,1)),
  CHECK (CHAR_LENGTH(nombre) > 0)
);

CREATE TABLE usuarios (
  id_usuario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre_usuario VARCHAR(100) NOT NULL UNIQUE,
  contrasena_hash VARCHAR(255) NOT NULL,
  nombre_completo VARCHAR(200) NOT NULL,
  correo VARCHAR(150),
  id_tipo_usuario TINYINT UNSIGNED NOT NULL,
  telefono VARCHAR(30),
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_usuario),
  CONSTRAINT fk_usuarios_tipo_usuario FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuario(id_tipo_usuario),
  CHECK (is_deleted IN (0,1))
);

CREATE TABLE sectores (
  id_sector INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(150) NOT NULL,
  descripcion VARCHAR(255),
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_sector),
  CHECK (is_deleted IN (0,1))
);

CREATE TABLE plazas (
  id_plaza INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(150) NOT NULL,
  id_sector INT UNSIGNED NOT NULL,
  direccion VARCHAR(255),
  latitud VARCHAR(50),
  longitud VARCHAR(50),
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_plaza),
  CONSTRAINT fk_plazas_sectores FOREIGN KEY (id_sector) REFERENCES sectores(id_sector),
  CHECK (is_deleted IN (0,1))
);

CREATE TABLE camaras (
  id_camara INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_plaza INT UNSIGNED NOT NULL,
  -- reemplazado 'identificador' por 'numero_serie' para evitar confusión con 'modelo'
  numero_serie VARCHAR(100) NOT NULL UNIQUE,
  modelo VARCHAR(100),
  direccion_ip VARCHAR(45),
  fecha_instalacion DATE,
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_camara),
  CONSTRAINT fk_camaras_plazas FOREIGN KEY (id_plaza) REFERENCES plazas(id_plaza),
  CHECK (is_deleted IN (0,1))
);

CREATE TABLE tipos_reportes (
  id_tipo_reporte INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(50) NOT NULL UNIQUE,
  nombre VARCHAR(120) NOT NULL,
  descripcion VARCHAR(255),
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_tipo_reporte),
  CHECK (is_deleted IN (0,1))
);

CREATE TABLE tipos_eventos (
  id_tipo_evento INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(50) NOT NULL UNIQUE,
  nombre VARCHAR(120) NOT NULL,
  descripcion VARCHAR(255),
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_tipo_evento),
  CHECK (is_deleted IN (0,1))
);

CREATE TABLE reportes (
  id_reporte INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_tipo_reporte INT UNSIGNED NOT NULL,
  reportado_por INT UNSIGNED NOT NULL,
  descripcion_reporte VARCHAR(1000),
  fecha_hora_reporte DATETIME NOT NULL,
  nivel_gravedad TINYINT UNSIGNED NOT NULL DEFAULT 1,
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_reporte),
  CONSTRAINT fk_reportes_tipos FOREIGN KEY (id_tipo_reporte) REFERENCES tipos_reportes(id_tipo_reporte),
  CONSTRAINT fk_reportes_usuarios FOREIGN KEY (reportado_por) REFERENCES usuarios(id_usuario),
  CHECK (is_deleted IN (0,1)),
  CHECK (nivel_gravedad BETWEEN 1 AND 5)
);

CREATE TABLE reportes_plazas (
  id_reporte INT UNSIGNED NOT NULL,
  id_plaza INT UNSIGNED NOT NULL,
  especificacion VARCHAR(255),
  PRIMARY KEY (id_reporte, id_plaza),
  CONSTRAINT fk_reportes_plazas_reporte FOREIGN KEY (id_reporte) REFERENCES reportes(id_reporte),
  CONSTRAINT fk_reportes_plazas_plaza FOREIGN KEY (id_plaza) REFERENCES plazas(id_plaza)
);

CREATE TABLE reportes_camaras (
  id_reporte INT UNSIGNED NOT NULL,
  id_camara INT UNSIGNED NOT NULL,
  especificacion VARCHAR(255),
  PRIMARY KEY (id_reporte, id_camara),
  CONSTRAINT fk_reportes_camaras_reporte FOREIGN KEY (id_reporte) REFERENCES reportes(id_reporte),
  CONSTRAINT fk_reportes_camaras_camara FOREIGN KEY (id_camara) REFERENCES camaras(id_camara)
);

CREATE TABLE accesos_usuarios (
  id_acceso INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario INT UNSIGNED NOT NULL,
  id_plaza INT UNSIGNED NOT NULL,
  otorgado_por INT,
  fecha_otorgado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  revocado_por INT,
  fecha_revocado DATETIME,
  activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
  created_by INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT,
  deleted_at DATETIME,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_acceso),
  CONSTRAINT fk_accesos_usuarios_usuarios FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
  CONSTRAINT fk_accesos_usuarios_plazas FOREIGN KEY (id_plaza) REFERENCES plazas(id_plaza),
  CHECK (is_deleted IN (0,1)),
  CHECK (activo IN (0,1))
);

CREATE TABLE eventos_camara (
  id_evento INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_camara INT UNSIGNED NOT NULL,
  id_tipo_evento INT UNSIGNED DEFAULT NULL,
  descripcion_evento VARCHAR(1000) DEFAULT NULL,
  fecha_hora_evento DATETIME NOT NULL,
  nivel_confianza TINYINT UNSIGNED NOT NULL DEFAULT 0,
  created_by INT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_by INT DEFAULT NULL,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_by INT DEFAULT NULL,
  deleted_at DATETIME DEFAULT NULL,
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_evento),
  CONSTRAINT fk_eventos_camara_camaras FOREIGN KEY (id_camara) REFERENCES camaras(id_camara),
  CONSTRAINT fk_eventos_camara_tipos FOREIGN KEY (id_tipo_evento) REFERENCES tipos_eventos(id_tipo_evento),
  CHECK (is_deleted IN (0,1)),
  CHECK (nivel_confianza BETWEEN 0 AND 100),
  CHECK (modified_at IS NULL OR modified_at >= created_at)
);

INSERT INTO tipo_usuario (id_tipo_usuario, nombre, descripcion, created_by, created_at, modified_by, modified_at, deleted_by, deleted_at, is_deleted)
VALUES
(1, 'administrador', 'Acceso completo al sistema', NULL, '2024-01-10 09:00:00', NULL, '2024-01-10 09:00:00', NULL, NULL, 0),
(2, 'vecino', 'Usuario residente de la comuna', NULL, '2024-01-10 09:05:00', NULL, '2024-01-10 09:05:00', NULL, NULL, 0),
(3, 'operador', 'Operador encargado de revisar eventos', NULL, '2024-02-01 08:30:00', NULL, '2024-02-01 08:30:00', NULL, NULL, 0),
(4, 'seguridad', 'Equipo de seguridad local', NULL, '2024-03-15 10:00:00', NULL, '2024-03-15 10:00:00', NULL, NULL, 0);

-- USUARIOS (cambiado id_rol -> id_tipo_usuario)
INSERT INTO usuarios (id_usuario, nombre_usuario, contrasena_hash, nombre_completo, correo, id_tipo_usuario, telefono, created_by, created_at, modified_by, modified_at, deleted_by, deleted_at, is_deleted)
VALUES
(1, 'juan.perez', '$2y$10$hashdemojuan', 'Juan Pérez', 'juan.perez@example.com', 2, '+56-9-7123-4567', NULL, '2024-04-01 12:00:00', NULL, '2024-04-01 12:00:00', NULL, NULL, 0),
(2, 'admin.sys', '$2y$10$hashadmin', 'Administrador Sistema', 'admin@demo.local', 1, '+56-2-2345-6789', NULL, '2024-01-11 09:10:00', NULL, '2024-01-11 09:10:00', NULL, NULL, 0),
(3, 'maria.lopez', '$2y$10$hashmaria', 'María López', 'maria.lopez@example.com', 2, '+56-9-7211-3344', NULL, '2024-05-05 15:20:00', NULL, '2024-05-06 10:00:00', NULL, NULL, 0),
(4, 'carlos.op', '$2y$10$hashcarlos', 'Carlos Operador', 'carlos.op@example.com', 3, '+56-9-7000-1111', NULL, '2024-02-10 08:00:00', NULL, '2024-02-10 08:00:00', NULL, NULL, 0),
(5, 'seguridad1', '$2y$10$hashseg', 'Equipo Seguridad 1', 'seguridad1@example.org', 4, '+56-9-7555-2222', NULL, '2024-03-20 07:30:00', NULL, '2024-03-20 07:30:00', NULL, NULL, 0),
(6, 'usuario.borrado', '$2y$10$hashx', 'Usuario Borrado', 'borrado@example.com', 2, '+56-9-7000-9999', NULL, '2024-06-10 09:00:00', NULL, '2024-07-01 10:00:00', NULL, '2024-07-01 10:00:00', 1);

-- SECTORES
INSERT INTO sectores (id_sector, nombre, descripcion, created_by, created_at, modified_by, modified_at, deleted_by, deleted_at, is_deleted)
VALUES
(1, 'Sector Centro', 'Zona céntrica con alto tránsito', NULL, '2024-01-05 08:00:00', NULL, '2024-01-05 08:00:00', NULL, NULL, 0),
(2, 'Sector Norte', 'Barrios residenciales norte', NULL, '2024-01-20 10:00:00', NULL, '2024-01-20 10:00:00', NULL, NULL, 0),
(3, 'Sector Sur', 'Parques y áreas verdes al sur', NULL, '2024-02-15 11:30:00', NULL, '2024-02-15 11:30:00', NULL, NULL, 0);

-- PLAZAS
INSERT INTO plazas (id_plaza, nombre, id_sector, direccion, latitud, longitud, created_by, created_at, modified_by, modified_at, deleted_by, deleted_at, is_deleted)
VALUES
(1, 'Plaza Central', 1, 'Av. Principal 100', '-33.4489', '-70.6693', NULL, '2024-01-06 09:00:00', NULL, '2024-01-06 09:00:00', NULL, NULL, 0),
(2, 'Plaza Norte', 2, 'Calle Norte 45', '-33.4400', '-70.6600', NULL, '2024-02-01 10:00:00', NULL, '2024-02-01 10:00:00', NULL, NULL, 0),
(3, 'Parque del Sur', 3, 'Ruta Sur 200', '-33.4600', '-70.6800', NULL, '2024-03-01 11:00:00', NULL, '2024-03-01 11:00:00', NULL, NULL, 0),
(4, 'Plaza Pequeña', 1, 'Pasaje 12', '-33.4495', '-70.6680', NULL, '2024-05-10 09:30:00', NULL, '2024-05-10 09:30:00', NULL, NULL, 0),
(5, 'Plaza Cerrada', 2, 'Cerrada 5', '-33.4420', '-70.6620', NULL, '2024-06-01 08:00:00', NULL, '2024-06-01 08:00:00', NULL, '2024-09-01 12:00:00', 1);

-- CAMARAS: reemplazado campo 'identificador' por 'numero_serie'
INSERT INTO camaras (id_camara, id_plaza, numero_serie, modelo, direccion_ip, fecha_instalacion, created_by, created_at, modified_by, modified_at, deleted_by, deleted_at, is_deleted)
VALUES
(1, 1, 'CAM-PRIN-01', 'AXIS-Q6000', '192.168.1.10', '2024-01-15', NULL, '2024-01-15 08:00:00', NULL, '2024-01-15 08:00:00', NULL, NULL, 0),
(2, 1, 'CAM-PRIN-02', 'AXIS-Q6000', '192.168.1.11', '2024-01-16', NULL, '2024-01-16 08:00:00', NULL, '2024-01-16 08:00:00', NULL, NULL, 0),
(3, 2, 'CAM-NORTE-01', 'Hikvision-DS', '10.0.0.12', '2024-02-05', NULL, '2024-02-05 09:00:00', NULL, '2024-02-05 09:00:00', NULL, NULL, 0),
(4, 3, 'CAM-SUR-01', 'Dahua-X', '2001:0db8:85a3::8a2e:0370:7334', '2024-03-20', NULL, '2024-03-20 10:00:00', NULL, '2024-03-20 10:00:00', NULL, NULL, 0),
(5, 4, 'CAM-PEQ-01', 'Model-P', '172.16.5.21', '2024-05-12', NULL, '2024-05-12 09:10:00', NULL, '2024-05-12 09:10:00', NULL, NULL, 0);

-- TIPOS DE REPORTES
INSERT INTO tipos_reportes (id_tipo_reporte, codigo, nombre, descripcion, created_by, created_at)
VALUES
(1, 'INCID', 'Incidente', 'Hechos que requieren atención del equipo', NULL, '2024-01-10 09:00:00'),
(2, 'VAND', 'Vandalismo', 'Daños a infraestructura pública', NULL, '2024-02-12 10:00:00'),
(3, 'SOS', 'Emergencia', 'Situación de urgencia', NULL, '2024-03-01 11:00:00');

-- TIPOS DE EVENTOS (detección automática)
INSERT INTO tipos_eventos (id_tipo_evento, codigo, nombre, descripcion, created_by, created_at)
VALUES
(1, 'MOV', 'Movimiento', 'Detección automática de movimiento', NULL, '2024-01-20 09:00:00'),
(2, 'OBJ', 'Objetos Extraños', 'Detección de objetos abandonados', NULL, '2024-02-20 09:00:00'),
(3, 'SND', 'Sonido fuerte', 'Detección de sonido anómalo', NULL, '2024-03-15 09:30:00');

-- REPORTES (cabeceras) - nivel_gravedad entre 1 y 5, fechas en el pasado
INSERT INTO reportes (id_reporte, id_tipo_reporte, reportado_por, descripcion_reporte, fecha_hora_reporte, nivel_gravedad, created_by, created_at, modified_by, modified_at, deleted_by, deleted_at, is_deleted)
VALUES
(1, 1, 1, 'Persona sospechosa merodeando cerca del kiosco', '2025-10-05 18:30:00', 2, NULL, '2025-10-05 18:31:00', NULL, '2025-10-05 18:31:00', NULL, NULL, 0),
(2, 2, 3, 'Graffiti en el muro norte de la plaza', '2025-09-20 07:15:00', 3, NULL, '2025-09-20 07:20:00', NULL, '2025-09-20 07:20:00', NULL, NULL, 0),
(3, 3, 1, 'Persona con heridas que requiere ambulancia', '2025-08-10 22:05:00', 5, NULL, '2025-08-10 22:06:00', NULL, '2025-08-10 22:06:00', NULL, NULL, 0),
(4, 1, 6, 'Reporte antiguo de prueba (usuario borrado)', '2024-07-01 09:00:00', 1, NULL, '2024-07-01 09:00:00', NULL, '2024-07-01 09:00:00', NULL, '2024-07-02 10:00:00', 1);

-- ASOCIACIONES REPORTES - PLAZAS
INSERT INTO reportes_plazas (id_reporte, id_plaza, especificacion)
VALUES
(1, 1, 'Sector kiosco'),
(2, 1, 'Muro norte'),
(3, 3, 'Entrada sur'),
(4, 2, 'Plaza Norte (registro antiguo)');

-- ASOCIACIONES REPORTES - CAMARAS
INSERT INTO reportes_camaras (id_reporte, id_camara, especificacion)
VALUES
(1, 1, 'Captado a las 18:29'),
(1, 2, 'Otra cámara con ángulo complementario'),
(2, 3, 'Registro parcial de vandalismo'),
(3, 4, 'Ambulancia llegó luego');

-- ACCESOS USUARIOS
INSERT INTO accesos_usuarios (id_acceso, id_usuario, id_plaza, otorgado_por, fecha_otorgado, revocado_por, fecha_revocado, activo, created_by, created_at, modified_by, modified_at, deleted_by, deleted_at, is_deleted)
VALUES
(1, 1, 1, 2, '2024-04-02 09:00:00', NULL, NULL, 1, NULL, '2024-04-02 09:00:00', NULL, '2024-04-02 09:00:00', NULL, NULL, 0),
(2, 3, 1, 2, '2024-05-06 10:00:00', NULL, NULL, 1, NULL, '2024-05-06 10:00:00', NULL, '2024-05-06 10:00:00', NULL, NULL, 0),
(3, 4, 1, 2, '2024-02-11 08:15:00', NULL, NULL, 1, NULL, '2024-02-11 08:15:00', NULL, '2024-02-11 08:15:00', NULL, NULL, 0),
(4, 6, 2, 2, '2024-06-11 09:00:00', 2, '2024-07-02 11:00:00', 0, NULL, '2024-06-11 09:00:00', NULL, '2024-07-02 11:00:00', NULL, NULL, 0);

-- EVENTOS CAMARA (fechas <= NOW(), nivel_confianza 0..100)
INSERT INTO eventos_camara (id_evento, id_camara, id_tipo_evento, descripcion_evento, fecha_hora_evento, nivel_confianza, created_by, created_at, modified_by, modified_at, deleted_by, deleted_at, is_deleted)
VALUES
(1, 1, 1, 'Movimiento breve frente a la fuente', '2025-10-05 18:29:10', 85, NULL, '2025-10-05 18:29:30', NULL, '2025-10-05 18:29:30', NULL, NULL, 0),
(2, 2, 2, 'Objeto detectado en vía peatonal', '2025-09-18 12:10:05', 72, NULL, '2025-09-18 12:11:00', NULL, '2025-09-18 12:11:00', NULL, NULL, 0),
(3, 3, 1, 'Movimiento prolongado en sector norte', '2025-09-01 23:45:00', 60, NULL, '2025-09-01 23:46:00', NULL, '2025-09-01 23:46:00', NULL, NULL, 0),
(4, 4, 3, 'Ruido fuerte detectado cerca de la cancha', '2025-08-20 03:20:10', 40, NULL, '2025-08-20 03:21:00', NULL, '2025-08-20 03:21:00', NULL, NULL, 0),
(5, 5, NULL, 'Evento test sin tipo de evento asignado', '2025-07-10 14:00:00', 10, NULL, '2025-07-10 14:00:10', NULL, '2025-07-10 14:00:10', NULL, '2025-09-01 12:00:00', 1);

-- Procedimientos almacenados completos para la base camaras_seguridad_db
-- Instrucciones: ejecutar este script (por ejemplo en MySQL Workbench o desde consola).
-- Asegúrate de usar la base correcta: USE camaras_seguridad_db;
-- El script borra procedimientos previos (si existen) y crea todos los CRUD para cada tabla.

USE camaras_seguridad_db;

-- ============================================================
-- Procedimientos almacenados completos (CRUD) para la base:
--    camaras_seguridad_db
-- Listos para copiar y pegar en MySQL (8.x).
-- Incluye: DROP IF EXISTS + CREATE para TODAS las tablas.
-- Convención: sp_<tabla>_<accion>  |  acciones: leer, leer_por_id, insertar, actualizar, eliminar
-- Notas:
--  - En tablas con columna is_deleted: "eliminar" realiza borrado lógico (is_deleted=1, deleted_at=NOW()).
--  - En tablas de unión (claves compuestas) sin is_deleted: "eliminar" realiza DELETE físico.
--  - Para INSERT se retorna LAST_INSERT_ID() cuando aplica (tabla con AUTO_INCREMENT).
-- ============================================================

USE camaras_seguridad_db;

-- =========================
-- LIMPIEZA (DROP PROCEDURES)
-- =========================
DROP PROCEDURE IF EXISTS sp_tipo_usuario_leer;
DROP PROCEDURE IF EXISTS sp_tipo_usuario_leer_por_id;
DROP PROCEDURE IF EXISTS sp_tipo_usuario_insertar;
DROP PROCEDURE IF EXISTS sp_tipo_usuario_actualizar;
DROP PROCEDURE IF EXISTS sp_tipo_usuario_eliminar;

DROP PROCEDURE IF EXISTS sp_usuarios_leer;
DROP PROCEDURE IF EXISTS sp_usuarios_leer_por_id;
DROP PROCEDURE IF EXISTS sp_usuarios_insertar;
DROP PROCEDURE IF EXISTS sp_usuarios_actualizar;
DROP PROCEDURE IF EXISTS sp_usuarios_eliminar;

DROP PROCEDURE IF EXISTS sp_sectores_leer;
DROP PROCEDURE IF EXISTS sp_sectores_leer_por_id;
DROP PROCEDURE IF EXISTS sp_sectores_insertar;
DROP PROCEDURE IF EXISTS sp_sectores_actualizar;
DROP PROCEDURE IF EXISTS sp_sectores_eliminar;

DROP PROCEDURE IF EXISTS sp_plazas_leer;
DROP PROCEDURE IF EXISTS sp_plazas_leer_por_id;
DROP PROCEDURE IF EXISTS sp_plazas_insertar;
DROP PROCEDURE IF EXISTS sp_plazas_actualizar;
DROP PROCEDURE IF EXISTS sp_plazas_eliminar;

DROP PROCEDURE IF EXISTS sp_camaras_leer;
DROP PROCEDURE IF EXISTS sp_camaras_leer_por_id;
DROP PROCEDURE IF EXISTS sp_camaras_insertar;
DROP PROCEDURE IF EXISTS sp_camaras_actualizar;
DROP PROCEDURE IF EXISTS sp_camaras_eliminar;

DROP PROCEDURE IF EXISTS sp_tipos_reportes_leer;
DROP PROCEDURE IF EXISTS sp_tipos_reportes_leer_por_id;
DROP PROCEDURE IF EXISTS sp_tipos_reportes_insertar;
DROP PROCEDURE IF EXISTS sp_tipos_reportes_actualizar;
DROP PROCEDURE IF EXISTS sp_tipos_reportes_eliminar;

DROP PROCEDURE IF EXISTS sp_tipos_eventos_leer;
DROP PROCEDURE IF EXISTS sp_tipos_eventos_leer_por_id;
DROP PROCEDURE IF EXISTS sp_tipos_eventos_insertar;
DROP PROCEDURE IF EXISTS sp_tipos_eventos_actualizar;
DROP PROCEDURE IF EXISTS sp_tipos_eventos_eliminar;

DROP PROCEDURE IF EXISTS sp_reportes_leer;
DROP PROCEDURE IF EXISTS sp_reportes_leer_por_id;
DROP PROCEDURE IF EXISTS sp_reportes_insertar;
DROP PROCEDURE IF EXISTS sp_reportes_actualizar;
DROP PROCEDURE IF EXISTS sp_reportes_eliminar;

DROP PROCEDURE IF EXISTS sp_reportes_plazas_leer;
DROP PROCEDURE IF EXISTS sp_reportes_plazas_leer_por_id;
DROP PROCEDURE IF EXISTS sp_reportes_plazas_insertar;
DROP PROCEDURE IF EXISTS sp_reportes_plazas_actualizar;
DROP PROCEDURE IF EXISTS sp_reportes_plazas_eliminar;

DROP PROCEDURE IF EXISTS sp_reportes_camaras_leer;
DROP PROCEDURE IF EXISTS sp_reportes_camaras_leer_por_id;
DROP PROCEDURE IF EXISTS sp_reportes_camaras_insertar;
DROP PROCEDURE IF EXISTS sp_reportes_camaras_actualizar;
DROP PROCEDURE IF EXISTS sp_reportes_camaras_eliminar;

DROP PROCEDURE IF EXISTS sp_accesos_usuarios_leer;
DROP PROCEDURE IF EXISTS sp_accesos_usuarios_leer_por_id;
DROP PROCEDURE IF EXISTS sp_accesos_usuarios_insertar;
DROP PROCEDURE IF EXISTS sp_accesos_usuarios_actualizar;
DROP PROCEDURE IF EXISTS sp_accesos_usuarios_eliminar;

DROP PROCEDURE IF EXISTS sp_eventos_camara_leer;
DROP PROCEDURE IF EXISTS sp_eventos_camara_leer_por_id;
DROP PROCEDURE IF EXISTS sp_eventos_camara_insertar;
DROP PROCEDURE IF EXISTS sp_eventos_camara_actualizar;
DROP PROCEDURE IF EXISTS sp_eventos_camara_eliminar;

-- =========================
-- CREACIÓN
-- =========================
DELIMITER $$

/* ============================================================
   TABLA: tipo_usuario
   PK: id_tipo_usuario (TINYINT UNSIGNED, AI)
   Campos relevantes: nombre, descripcion, is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_tipo_usuario_leer()
BEGIN
  SELECT *
  FROM tipo_usuario
  WHERE is_deleted = 0;
END$$

CREATE PROCEDURE sp_tipo_usuario_leer_por_id(IN p_id_tipo_usuario TINYINT UNSIGNED)
BEGIN
  SELECT *
  FROM tipo_usuario
  WHERE id_tipo_usuario = p_id_tipo_usuario;
END$$

CREATE PROCEDURE sp_tipo_usuario_insertar(
  IN p_nombre VARCHAR(50),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO tipo_usuario (nombre, descripcion)
  VALUES (p_nombre, p_descripcion);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_tipo_usuario_actualizar(
  IN p_id_tipo_usuario TINYINT UNSIGNED,
  IN p_nombre VARCHAR(50),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  UPDATE tipo_usuario
  SET nombre = p_nombre,
      descripcion = p_descripcion,
      modified_at = CURRENT_TIMESTAMP
  WHERE id_tipo_usuario = p_id_tipo_usuario;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_tipo_usuario_eliminar(IN p_id_tipo_usuario TINYINT UNSIGNED)
BEGIN
  UPDATE tipo_usuario
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_tipo_usuario = p_id_tipo_usuario;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: usuarios
   PK: id_usuario (INT UNSIGNED, AI)
   Campos: nombre_usuario, contrasena_hash, nombre_completo, correo, id_tipo_usuario, telefono
           is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_usuarios_leer()
BEGIN
  SELECT *
  FROM usuarios
  WHERE is_deleted = 0;
END$$

CREATE PROCEDURE sp_usuarios_leer_por_id(IN p_id_usuario INT UNSIGNED)
BEGIN
  SELECT *
  FROM usuarios
  WHERE id_usuario = p_id_usuario;
END$$

CREATE PROCEDURE sp_usuarios_insertar(
  IN p_nombre_usuario VARCHAR(100),
  IN p_contrasena_hash VARCHAR(255),
  IN p_nombre_completo VARCHAR(200),
  IN p_correo VARCHAR(150),
  IN p_id_tipo_usuario TINYINT UNSIGNED,
  IN p_telefono VARCHAR(30)
)
BEGIN
  INSERT INTO usuarios (nombre_usuario, contrasena_hash, nombre_completo, correo, id_tipo_usuario, telefono)
  VALUES (p_nombre_usuario, p_contrasena_hash, p_nombre_completo, p_correo, p_id_tipo_usuario, p_telefono);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_usuarios_actualizar(
  IN p_id_usuario INT UNSIGNED,
  IN p_nombre_usuario VARCHAR(100),
  IN p_contrasena_hash VARCHAR(255),
  IN p_nombre_completo VARCHAR(200),
  IN p_correo VARCHAR(150),
  IN p_id_tipo_usuario TINYINT UNSIGNED,
  IN p_telefono VARCHAR(30)
)
BEGIN
  UPDATE usuarios
  SET nombre_usuario   = p_nombre_usuario,
      contrasena_hash  = p_contrasena_hash,
      nombre_completo  = p_nombre_completo,
      correo           = p_correo,
      id_tipo_usuario  = p_id_tipo_usuario,
      telefono         = p_telefono,
      modified_at      = CURRENT_TIMESTAMP
  WHERE id_usuario = p_id_usuario;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_usuarios_eliminar(IN p_id_usuario INT UNSIGNED)
BEGIN
  UPDATE usuarios
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_usuario = p_id_usuario;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: sectores
   PK: id_sector (INT UNSIGNED, AI)
   Campos: nombre, descripcion, is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_sectores_leer()
BEGIN
  SELECT *
  FROM sectores
  WHERE is_deleted = 0;
END$$

CREATE PROCEDURE sp_sectores_leer_por_id(IN p_id_sector INT UNSIGNED)
BEGIN
  SELECT *
  FROM sectores
  WHERE id_sector = p_id_sector;
END$$

CREATE PROCEDURE sp_sectores_insertar(
  IN p_nombre VARCHAR(150),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO sectores (nombre, descripcion)
  VALUES (p_nombre, p_descripcion);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_sectores_actualizar(
  IN p_id_sector INT UNSIGNED,
  IN p_nombre VARCHAR(150),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  UPDATE sectores
  SET nombre = p_nombre,
      descripcion = p_descripcion,
      modified_at = CURRENT_TIMESTAMP
  WHERE id_sector = p_id_sector;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_sectores_eliminar(IN p_id_sector INT UNSIGNED)
BEGIN
  UPDATE sectores
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_sector = p_id_sector;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: plazas
   PK: id_plaza (INT UNSIGNED, AI)
   Campos: nombre, id_sector, direccion, latitud (VARCHAR), longitud (VARCHAR), is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_plazas_leer()
BEGIN
  SELECT p.*, s.nombre AS nombre_sector
  FROM plazas p
  LEFT JOIN sectores s ON p.id_sector = s.id_sector
  WHERE p.is_deleted = 0;
END$$

CREATE PROCEDURE sp_plazas_leer_por_id(IN p_id_plaza INT UNSIGNED)
BEGIN
  SELECT p.*, s.nombre AS nombre_sector
  FROM plazas p
  LEFT JOIN sectores s ON p.id_sector = s.id_sector
  WHERE p.id_plaza = p_id_plaza;
END$$

CREATE PROCEDURE sp_plazas_insertar(
  IN p_nombre VARCHAR(150),
  IN p_id_sector INT UNSIGNED,
  IN p_direccion VARCHAR(255),
  IN p_latitud VARCHAR(50),
  IN p_longitud VARCHAR(50)
)
BEGIN
  INSERT INTO plazas (nombre, id_sector, direccion, latitud, longitud)
  VALUES (p_nombre, p_id_sector, p_direccion, p_latitud, p_longitud);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_plazas_actualizar(
  IN p_id_plaza INT UNSIGNED,
  IN p_nombre VARCHAR(150),
  IN p_id_sector INT UNSIGNED,
  IN p_direccion VARCHAR(255),
  IN p_latitud VARCHAR(50),
  IN p_longitud VARCHAR(50)
)
BEGIN
  UPDATE plazas
  SET nombre = p_nombre,
      id_sector = p_id_sector,
      direccion = p_direccion,
      latitud = p_latitud,
      longitud = p_longitud,
      modified_at = CURRENT_TIMESTAMP
  WHERE id_plaza = p_id_plaza;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_plazas_eliminar(IN p_id_plaza INT UNSIGNED)
BEGIN
  UPDATE plazas
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_plaza = p_id_plaza;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: camaras
   PK: id_camara (INT UNSIGNED, AI)
   Campos: id_plaza, numero_serie (UNIQUE), modelo, direccion_ip, fecha_instalacion (DATE), is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_camaras_leer()
BEGIN
  SELECT c.*, p.nombre AS nombre_plaza
  FROM camaras c
  LEFT JOIN plazas p ON c.id_plaza = p.id_plaza
  WHERE c.is_deleted = 0;
END$$

CREATE PROCEDURE sp_camaras_leer_por_id(IN p_id_camara INT UNSIGNED)
BEGIN
  SELECT c.*, p.nombre AS nombre_plaza
  FROM camaras c
  LEFT JOIN plazas p ON c.id_plaza = p.id_plaza
  WHERE c.id_camara = p_id_camara;
END$$

CREATE PROCEDURE sp_camaras_insertar(
  IN p_id_plaza INT UNSIGNED,
  IN p_numero_serie VARCHAR(100),
  IN p_modelo VARCHAR(100),
  IN p_direccion_ip VARCHAR(45),
  IN p_fecha_instalacion DATE
)
BEGIN
  INSERT INTO camaras (id_plaza, numero_serie, modelo, direccion_ip, fecha_instalacion)
  VALUES (p_id_plaza, p_numero_serie, p_modelo, p_direccion_ip, p_fecha_instalacion);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_camaras_actualizar(
  IN p_id_camara INT UNSIGNED,
  IN p_id_plaza INT UNSIGNED,
  IN p_numero_serie VARCHAR(100),
  IN p_modelo VARCHAR(100),
  IN p_direccion_ip VARCHAR(45),
  IN p_fecha_instalacion DATE
)
BEGIN
  UPDATE camaras
  SET id_plaza = p_id_plaza,
      numero_serie = p_numero_serie,
      modelo = p_modelo,
      direccion_ip = p_direccion_ip,
      fecha_instalacion = p_fecha_instalacion,
      modified_at = CURRENT_TIMESTAMP
  WHERE id_camara = p_id_camara;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_camaras_eliminar(IN p_id_camara INT UNSIGNED)
BEGIN
  UPDATE camaras
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_camara = p_id_camara;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: tipos_reportes
   PK: id_tipo_reporte (INT UNSIGNED, AI)
   Campos: codigo (UNIQUE), nombre, descripcion, is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_tipos_reportes_leer()
BEGIN
  SELECT *
  FROM tipos_reportes
  WHERE is_deleted = 0;
END$$

CREATE PROCEDURE sp_tipos_reportes_leer_por_id(IN p_id_tipo_reporte INT UNSIGNED)
BEGIN
  SELECT *
  FROM tipos_reportes
  WHERE id_tipo_reporte = p_id_tipo_reporte;
END$$

CREATE PROCEDURE sp_tipos_reportes_insertar(
  IN p_codigo VARCHAR(50),
  IN p_nombre VARCHAR(120),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO tipos_reportes (codigo, nombre, descripcion)
  VALUES (p_codigo, p_nombre, p_descripcion);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_tipos_reportes_actualizar(
  IN p_id_tipo_reporte INT UNSIGNED,
  IN p_codigo VARCHAR(50),
  IN p_nombre VARCHAR(120),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  UPDATE tipos_reportes
  SET codigo = p_codigo,
      nombre = p_nombre,
      descripcion = p_descripcion,
      modified_at = CURRENT_TIMESTAMP
  WHERE id_tipo_reporte = p_id_tipo_reporte;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_tipos_reportes_eliminar(IN p_id_tipo_reporte INT UNSIGNED)
BEGIN
  UPDATE tipos_reportes
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_tipo_reporte = p_id_tipo_reporte;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: tipos_eventos
   PK: id_tipo_evento (INT UNSIGNED, AI)
   Campos: codigo (UNIQUE), nombre, descripcion, is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_tipos_eventos_leer()
BEGIN
  SELECT *
  FROM tipos_eventos
  WHERE is_deleted = 0;
END$$

CREATE PROCEDURE sp_tipos_eventos_leer_por_id(IN p_id_tipo_evento INT UNSIGNED)
BEGIN
  SELECT *
  FROM tipos_eventos
  WHERE id_tipo_evento = p_id_tipo_evento;
END$$

CREATE PROCEDURE sp_tipos_eventos_insertar(
  IN p_codigo VARCHAR(50),
  IN p_nombre VARCHAR(120),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO tipos_eventos (codigo, nombre, descripcion)
  VALUES (p_codigo, p_nombre, p_descripcion);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_tipos_eventos_actualizar(
  IN p_id_tipo_evento INT UNSIGNED,
  IN p_codigo VARCHAR(50),
  IN p_nombre VARCHAR(120),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  UPDATE tipos_eventos
  SET codigo = p_codigo,
      nombre = p_nombre,
      descripcion = p_descripcion,
      modified_at = CURRENT_TIMESTAMP
  WHERE id_tipo_evento = p_id_tipo_evento;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_tipos_eventos_eliminar(IN p_id_tipo_evento INT UNSIGNED)
BEGIN
  UPDATE tipos_eventos
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_tipo_evento = p_id_tipo_evento;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: reportes
   PK: id_reporte (INT UNSIGNED, AI)
   Campos: id_tipo_reporte (FK), reportado_por (FK usuarios), descripcion_reporte,
           fecha_hora_reporte (DATETIME), nivel_gravedad (TINYINT UNSIGNED),
           is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_reportes_leer()
BEGIN
  SELECT r.*,
         tr.nombre AS nombre_tipo_reporte,
         u.nombre_completo AS nombre_reportado_por
  FROM reportes r
  LEFT JOIN tipos_reportes tr ON r.id_tipo_reporte = tr.id_tipo_reporte
  LEFT JOIN usuarios u ON r.reportado_por = u.id_usuario
  WHERE r.is_deleted = 0;
END$$

CREATE PROCEDURE sp_reportes_leer_por_id(IN p_id_reporte INT UNSIGNED)
BEGIN
  SELECT r.*,
         tr.nombre AS nombre_tipo_reporte,
         u.nombre_completo AS nombre_reportado_por
  FROM reportes r
  LEFT JOIN tipos_reportes tr ON r.id_tipo_reporte = tr.id_tipo_reporte
  LEFT JOIN usuarios u ON r.reportado_por = u.id_usuario
  WHERE r.id_reporte = p_id_reporte;
END$$

CREATE PROCEDURE sp_reportes_insertar(
  IN p_id_tipo_reporte INT UNSIGNED,
  IN p_reportado_por INT UNSIGNED,
  IN p_descripcion_reporte VARCHAR(1000),
  IN p_fecha_hora_reporte DATETIME,
  IN p_nivel_gravedad TINYINT UNSIGNED
)
BEGIN
  INSERT INTO reportes (id_tipo_reporte, reportado_por, descripcion_reporte, fecha_hora_reporte, nivel_gravedad)
  VALUES (p_id_tipo_reporte, p_reportado_por, p_descripcion_reporte, p_fecha_hora_reporte, p_nivel_gravedad);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_reportes_actualizar(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_tipo_reporte INT UNSIGNED,
  IN p_reportado_por INT UNSIGNED,
  IN p_descripcion_reporte VARCHAR(1000),
  IN p_fecha_hora_reporte DATETIME,
  IN p_nivel_gravedad TINYINT UNSIGNED
)
BEGIN
  UPDATE reportes
  SET id_tipo_reporte     = p_id_tipo_reporte,
      reportado_por       = p_reportado_por,
      descripcion_reporte = p_descripcion_reporte,
      fecha_hora_reporte  = p_fecha_hora_reporte,
      nivel_gravedad      = p_nivel_gravedad,
      modified_at         = CURRENT_TIMESTAMP
  WHERE id_reporte = p_id_reporte;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_reportes_eliminar(IN p_id_reporte INT UNSIGNED)
BEGIN
  UPDATE reportes
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_reporte = p_id_reporte;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: reportes_plazas  (PK compuesta: id_reporte, id_plaza)
   Campos: especificacion
   ============================================================ */
CREATE PROCEDURE sp_reportes_plazas_leer()
BEGIN
  SELECT rp.*,
         p.nombre AS nombre_plaza
  FROM reportes_plazas rp
  LEFT JOIN plazas p ON rp.id_plaza = p.id_plaza;
END$$

CREATE PROCEDURE sp_reportes_plazas_leer_por_id(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_plaza INT UNSIGNED
)
BEGIN
  SELECT rp.*,
         p.nombre AS nombre_plaza
  FROM reportes_plazas rp
  LEFT JOIN plazas p ON rp.id_plaza = p.id_plaza
  WHERE rp.id_reporte = p_id_reporte
    AND rp.id_plaza   = p_id_plaza;
END$$

CREATE PROCEDURE sp_reportes_plazas_insertar(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_plaza INT UNSIGNED,
  IN p_especificacion VARCHAR(255)
)
BEGIN
  INSERT INTO reportes_plazas (id_reporte, id_plaza, especificacion)
  VALUES (p_id_reporte, p_id_plaza, p_especificacion);
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_reportes_plazas_actualizar(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_plaza INT UNSIGNED,
  IN p_especificacion VARCHAR(255)
)
BEGIN
  UPDATE reportes_plazas
  SET especificacion = p_especificacion
  WHERE id_reporte = p_id_reporte
    AND id_plaza   = p_id_plaza;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_reportes_plazas_eliminar(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_plaza INT UNSIGNED
)
BEGIN
  DELETE FROM reportes_plazas
  WHERE id_reporte = p_id_reporte
    AND id_plaza   = p_id_plaza;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: reportes_camaras (PK compuesta: id_reporte, id_camara)
   Campos: especificacion
   ============================================================ */
CREATE PROCEDURE sp_reportes_camaras_leer()
BEGIN
  SELECT rc.*,
         c.numero_serie AS numero_serie_camara
  FROM reportes_camaras rc
  LEFT JOIN camaras c ON rc.id_camara = c.id_camara;
END$$

CREATE PROCEDURE sp_reportes_camaras_leer_por_id(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_camara INT UNSIGNED
)
BEGIN
  SELECT rc.*,
         c.numero_serie AS numero_serie_camara
  FROM reportes_camaras rc
  LEFT JOIN camaras c ON rc.id_camara = c.id_camara
  WHERE rc.id_reporte = p_id_reporte
    AND rc.id_camara  = p_id_camara;
END$$

CREATE PROCEDURE sp_reportes_camaras_insertar(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_camara INT UNSIGNED,
  IN p_especificacion VARCHAR(255)
)
BEGIN
  INSERT INTO reportes_camaras (id_reporte, id_camara, especificacion)
  VALUES (p_id_reporte, p_id_camara, p_especificacion);
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_reportes_camaras_actualizar(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_camara INT UNSIGNED,
  IN p_especificacion VARCHAR(255)
)
BEGIN
  UPDATE reportes_camaras
  SET especificacion = p_especificacion
  WHERE id_reporte = p_id_reporte
    AND id_camara  = p_id_camara;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_reportes_camaras_eliminar(
  IN p_id_reporte INT UNSIGNED,
  IN p_id_camara INT UNSIGNED
)
BEGIN
  DELETE FROM reportes_camaras
  WHERE id_reporte = p_id_reporte
    AND id_camara  = p_id_camara;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: accesos_usuarios
   PK: id_acceso (INT UNSIGNED, AI)
   Campos: id_usuario, id_plaza, otorgado_por, fecha_otorgado,
           revocado_por, fecha_revocado, activo, is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_accesos_usuarios_leer()
BEGIN
  SELECT au.*,
         u.nombre_completo AS nombre_usuario,
         p.nombre          AS nombre_plaza
  FROM accesos_usuarios au
  LEFT JOIN usuarios u ON au.id_usuario = u.id_usuario
  LEFT JOIN plazas p   ON au.id_plaza   = p.id_plaza
  WHERE au.is_deleted = 0;
END$$

CREATE PROCEDURE sp_accesos_usuarios_leer_por_id(IN p_id_acceso INT UNSIGNED)
BEGIN
  SELECT au.*,
         u.nombre_completo AS nombre_usuario,
         p.nombre          AS nombre_plaza
  FROM accesos_usuarios au
  LEFT JOIN usuarios u ON au.id_usuario = u.id_usuario
  LEFT JOIN plazas p   ON au.id_plaza   = p.id_plaza
  WHERE au.id_acceso = p_id_acceso;
END$$

CREATE PROCEDURE sp_accesos_usuarios_insertar(
  IN p_id_usuario INT UNSIGNED,
  IN p_id_plaza INT UNSIGNED,
  IN p_otorgado_por INT,
  IN p_fecha_otorgado DATETIME,
  IN p_revocado_por INT,
  IN p_fecha_revocado DATETIME,
  IN p_activo TINYINT UNSIGNED
)
BEGIN
  INSERT INTO accesos_usuarios (id_usuario, id_plaza, otorgado_por, fecha_otorgado, revocado_por, fecha_revocado, activo)
  VALUES (p_id_usuario, p_id_plaza, p_otorgado_por, p_fecha_otorgado, p_revocado_por, p_fecha_revocado, p_activo);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_accesos_usuarios_actualizar(
  IN p_id_acceso INT UNSIGNED,
  IN p_id_usuario INT UNSIGNED,
  IN p_id_plaza INT UNSIGNED,
  IN p_otorgado_por INT,
  IN p_fecha_otorgado DATETIME,
  IN p_revocado_por INT,
  IN p_fecha_revocado DATETIME,
  IN p_activo TINYINT UNSIGNED
)
BEGIN
  UPDATE accesos_usuarios
  SET id_usuario      = p_id_usuario,
      id_plaza        = p_id_plaza,
      otorgado_por    = p_otorgado_por,
      fecha_otorgado  = p_fecha_otorgado,
      revocado_por    = p_revocado_por,
      fecha_revocado  = p_fecha_revocado,
      activo          = p_activo,
      modified_at     = CURRENT_TIMESTAMP
  WHERE id_acceso = p_id_acceso;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_accesos_usuarios_eliminar(IN p_id_acceso INT UNSIGNED)
BEGIN
  UPDATE accesos_usuarios
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_acceso = p_id_acceso;
  SELECT ROW_COUNT() AS affected_rows;
END$$


/* ============================================================
   TABLA: eventos_camara
   PK: id_evento (INT UNSIGNED, AI)
   Campos: id_camara (FK), id_tipo_evento (FK, puede ser NULL),
           descripcion_evento, fecha_hora_evento (DATETIME),
           nivel_confianza (TINYINT UNSIGNED), is_deleted, deleted_at, modified_at
   ============================================================ */
CREATE PROCEDURE sp_eventos_camara_leer()
BEGIN
  SELECT e.*,
         c.numero_serie AS numero_serie_camara,
         te.nombre      AS nombre_tipo_evento
  FROM eventos_camara e
  LEFT JOIN camaras       c  ON e.id_camara      = c.id_camara
  LEFT JOIN tipos_eventos te ON e.id_tipo_evento = te.id_tipo_evento
  WHERE e.is_deleted = 0;
END$$

CREATE PROCEDURE sp_eventos_camara_leer_por_id(IN p_id_evento INT UNSIGNED)
BEGIN
  SELECT e.*,
         c.numero_serie AS numero_serie_camara,
         te.nombre      AS nombre_tipo_evento
  FROM eventos_camara e
  LEFT JOIN camaras       c  ON e.id_camara      = c.id_camara
  LEFT JOIN tipos_eventos te ON e.id_tipo_evento = te.id_tipo_evento
  WHERE e.id_evento = p_id_evento;
END$$

CREATE PROCEDURE sp_eventos_camara_insertar(
  IN p_id_camara INT UNSIGNED,
  IN p_id_tipo_evento INT UNSIGNED,
  IN p_descripcion_evento VARCHAR(1000),
  IN p_fecha_hora_evento DATETIME,
  IN p_nivel_confianza TINYINT UNSIGNED
)
BEGIN
  INSERT INTO eventos_camara (id_camara, id_tipo_evento, descripcion_evento, fecha_hora_evento, nivel_confianza)
  VALUES (p_id_camara, p_id_tipo_evento, p_descripcion_evento, p_fecha_hora_evento, p_nivel_confianza);
  SELECT LAST_INSERT_ID() AS inserted_id;
END$$

CREATE PROCEDURE sp_eventos_camara_actualizar(
  IN p_id_evento INT UNSIGNED,
  IN p_id_camara INT UNSIGNED,
  IN p_id_tipo_evento INT UNSIGNED,
  IN p_descripcion_evento VARCHAR(1000),
  IN p_fecha_hora_evento DATETIME,
  IN p_nivel_confianza TINYINT UNSIGNED
)
BEGIN
  UPDATE eventos_camara
  SET id_camara           = p_id_camara,
      id_tipo_evento      = p_id_tipo_evento,
      descripcion_evento  = p_descripcion_evento,
      fecha_hora_evento   = p_fecha_hora_evento,
      nivel_confianza     = p_nivel_confianza,
      modified_at         = CURRENT_TIMESTAMP
  WHERE id_evento = p_id_evento;
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_eventos_camara_eliminar(IN p_id_evento INT UNSIGNED)
BEGIN
  UPDATE eventos_camara
  SET is_deleted = 1,
      deleted_at = CURRENT_TIMESTAMP
  WHERE id_evento = p_id_evento;
  SELECT ROW_COUNT() AS affected_rows;
END$$

DELIMITER ;

-- ============================================================
-- FIN DEL SCRIPT
-- Sugerencias de prueba rápida:
--   CALL sp_usuarios_leer();
--   CALL sp_usuarios_insertar('user.demo','hash','Nombre Demo','demo@local',2,'+56-9-0000-0000');
--   CALL sp_usuarios_actualizar(1,'juan.perez','$2y$10$hash','Juan Pérez','juan@ejemplo.cl',2,'+56-9-7123-4567');
--   CALL sp_usuarios_eliminar(6);
-- ============================================================

SELECT * FROM tipo_usuario;
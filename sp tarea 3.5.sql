-- =======================================================
-- SCRIPT: Creación DB, tablas + procedimientos de inserción y borrado lógico
-- Proyecto: Sistema de Reservas de Vuelos (3FN)
-- =======================================================

-- Crear DB y seleccionarla
CREATE DATABASE IF NOT EXISTS sistema_reservas
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sistema_reservas;

-- =========================
-- TABLA: UBICACION
-- =========================
CREATE TABLE IF NOT EXISTS ubicacion (
  id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
  ciudad VARCHAR(100) NOT NULL,
  region VARCHAR(100),
  pais VARCHAR(100) NOT NULL,
  codigo_postal VARCHAR(20),
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_codigo_postal CHECK (codigo_postal IS NULL OR CHAR_LENGTH(codigo_postal) >= 4)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: AEROPUERTO
-- =========================
CREATE TABLE IF NOT EXISTS aeropuerto (
  id_aeropuerto INT AUTO_INCREMENT PRIMARY KEY,
  codigo_iata CHAR(3) NOT NULL UNIQUE,
  nombre VARCHAR(150) NOT NULL,
  id_ubicacion INT NOT NULL,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_aeropuerto_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES ubicacion(id_ubicacion)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_codigo_iata CHECK (CHAR_LENGTH(codigo_iata) = 3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: AVION
-- =========================
CREATE TABLE IF NOT EXISTS avion (
  id_avion INT AUTO_INCREMENT PRIMARY KEY,
  fabricante VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  capacidad_total INT NOT NULL,
  matricula VARCHAR(50) UNIQUE,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_capacidad CHECK (capacidad_total > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: CLASE
-- =========================
CREATE TABLE IF NOT EXISTS clase (
  id_clase INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255),
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: VUELO
-- =========================
CREATE TABLE IF NOT EXISTS vuelo (
  id_vuelo INT AUTO_INCREMENT PRIMARY KEY,
  numero_vuelo VARCHAR(20) NOT NULL,
  id_avion INT NOT NULL,
  id_aeropuerto_origen INT NOT NULL,
  id_aeropuerto_destino INT NOT NULL,
  fecha_salida DATETIME NOT NULL,
  fecha_llegada DATETIME NOT NULL,
  duracion_minutos INT,
  distancia_km INT,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_vuelo_avion FOREIGN KEY (id_avion) REFERENCES avion(id_avion)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_vuelo_origen FOREIGN KEY (id_aeropuerto_origen) REFERENCES aeropuerto(id_aeropuerto)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_vuelo_destino FOREIGN KEY (id_aeropuerto_destino) REFERENCES aeropuerto(id_aeropuerto)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_fechas_vuelo CHECK (fecha_llegada > fecha_salida)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: ASIENTO
-- =========================
CREATE TABLE IF NOT EXISTS asiento (
  id_asiento INT AUTO_INCREMENT PRIMARY KEY,
  id_vuelo INT NOT NULL,
  id_clase INT NOT NULL,
  fila VARCHAR(5),
  columna CHAR(1),
  codigo_asiento VARCHAR(10) NOT NULL,
  estado ENUM('disponible','reservado','vendido') DEFAULT 'disponible',
  precio DECIMAL(10,2) NOT NULL,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_asiento_vuelo FOREIGN KEY (id_vuelo) REFERENCES vuelo(id_vuelo)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_asiento_clase FOREIGN KEY (id_clase) REFERENCES clase(id_clase)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE (id_vuelo, codigo_asiento),
  CONSTRAINT chk_precio_asiento CHECK (precio >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: USUARIO
-- =========================
CREATE TABLE IF NOT EXISTS usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  telefono VARCHAR(30),
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: RESERVA
-- =========================
CREATE TABLE IF NOT EXISTS reserva (
  id_reserva INT AUTO_INCREMENT PRIMARY KEY,
  codigo_reserva VARCHAR(30) NOT NULL UNIQUE,
  id_usuario INT,
  fecha_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('pendiente','confirmada','cancelada','completada') DEFAULT 'pendiente',
  total DECIMAL(12,2) DEFAULT 0.00,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_reserva_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_total_reserva CHECK (total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: PASAJERO
-- =========================
CREATE TABLE IF NOT EXISTS pasajero (
  id_pasajero INT AUTO_INCREMENT PRIMARY KEY,
  id_reserva INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  tipo_documento VARCHAR(20),
  numero_documento VARCHAR(50),
  fecha_nacimiento DATE,
  nacionalidad VARCHAR(80),
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pasajero_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: ASIGNACION_ASIENTO
-- =========================
CREATE TABLE IF NOT EXISTS asignacion_asiento (
  id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
  id_pasajero INT NOT NULL,
  id_asiento INT NOT NULL,
  fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_asignacion_pasajero FOREIGN KEY (id_pasajero) REFERENCES pasajero(id_pasajero)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_asignacion_asiento FOREIGN KEY (id_asiento) REFERENCES asiento(id_asiento)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE (id_pasajero, id_asiento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: PAGO
-- =========================
CREATE TABLE IF NOT EXISTS pago (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_reserva INT NOT NULL,
  metodo_pago VARCHAR(50) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
  referencia_pago VARCHAR(150),
  estado_pago ENUM('pendiente','exitoso','fallido','reembolsado') DEFAULT 'pendiente',
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_monto_pago CHECK (monto > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- TABLA: TARIFA_VUELO_CLASE
-- =========================
CREATE TABLE IF NOT EXISTS tarifa_vuelo_clase (
  id_tarifa INT AUTO_INCREMENT PRIMARY KEY,
  id_vuelo INT NOT NULL,
  id_clase INT NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_tarifa_vuelo FOREIGN KEY (id_vuelo) REFERENCES vuelo(id_vuelo)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_tarifa_clase FOREIGN KEY (id_clase) REFERENCES clase(id_clase)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE (id_vuelo, id_clase),
  CONSTRAINT chk_precio_tarifa CHECK (precio >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =======================================================
-- PROCEDIMIENTOS ALMACENADOS: sp_insertar_* y sp_borrado_logico_*
-- Usamos DELIMITER para delimitar correctamente los procedimientos.
-- =======================================================

DELIMITER $$

-- =========== UBICACION ===========
CREATE PROCEDURE sp_insertar_ubicacion (
  IN p_ciudad VARCHAR(100),
  IN p_region VARCHAR(100),
  IN p_pais VARCHAR(100),
  IN p_codigo_postal VARCHAR(20)
)
BEGIN
  INSERT INTO ubicacion (ciudad, region, pais, codigo_postal)
  VALUES (p_ciudad, p_region, p_pais, p_codigo_postal);
END$$

CREATE PROCEDURE sp_borrado_logico_ubicacion (IN p_id INT)
BEGIN
  UPDATE ubicacion SET deleted = 1 WHERE id_ubicacion = p_id;
END$$

-- =========== AEROPUERTO ===========
CREATE PROCEDURE sp_insertar_aeropuerto (
  IN p_codigo_iata CHAR(3),
  IN p_nombre VARCHAR(150),
  IN p_id_ubicacion INT
)
BEGIN
  INSERT INTO aeropuerto (codigo_iata, nombre, id_ubicacion)
  VALUES (p_codigo_iata, p_nombre, p_id_ubicacion);
END$$

CREATE PROCEDURE sp_borrado_logico_aeropuerto (IN p_id INT)
BEGIN
  UPDATE aeropuerto SET deleted = 1 WHERE id_aeropuerto = p_id;
END$$

-- =========== AVION ===========
CREATE PROCEDURE sp_insertar_avion (
  IN p_fabricante VARCHAR(100),
  IN p_modelo VARCHAR(100),
  IN p_capacidad_total INT,
  IN p_matricula VARCHAR(50)
)
BEGIN
  INSERT INTO avion (fabricante, modelo, capacidad_total, matricula)
  VALUES (p_fabricante, p_modelo, p_capacidad_total, p_matricula);
END$$

CREATE PROCEDURE sp_borrado_logico_avion (IN p_id INT)
BEGIN
  UPDATE avion SET deleted = 1 WHERE id_avion = p_id;
END$$

-- =========== CLASE ===========
CREATE PROCEDURE sp_insertar_clase (
  IN p_nombre VARCHAR(50),
  IN p_descripcion VARCHAR(255)
)
BEGIN
  INSERT INTO clase (nombre, descripcion)
  VALUES (p_nombre, p_descripcion);
END$$

CREATE PROCEDURE sp_borrado_logico_clase (IN p_id INT)
BEGIN
  UPDATE clase SET deleted = 1 WHERE id_clase = p_id;
END$$

-- =========== VUELO ===========
CREATE PROCEDURE sp_insertar_vuelo (
  IN p_numero_vuelo VARCHAR(20),
  IN p_id_avion INT,
  IN p_id_origen INT,
  IN p_id_destino INT,
  IN p_fecha_salida DATETIME,
  IN p_fecha_llegada DATETIME,
  IN p_duracion_minutos INT,
  IN p_distancia_km INT
)
BEGIN
  INSERT INTO vuelo (numero_vuelo, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, fecha_salida, fecha_llegada, duracion_minutos, distancia_km)
  VALUES (p_numero_vuelo, p_id_avion, p_id_origen, p_id_destino, p_fecha_salida, p_fecha_llegada, p_duracion_minutos, p_distancia_km);
END$$

CREATE PROCEDURE sp_borrado_logico_vuelo (IN p_id INT)
BEGIN
  UPDATE vuelo SET deleted = 1 WHERE id_vuelo = p_id;
END$$

-- =========== ASIENTO ===========
CREATE PROCEDURE sp_insertar_asiento (
  IN p_id_vuelo INT,
  IN p_id_clase INT,
  IN p_fila VARCHAR(5),
  IN p_columna CHAR(1),
  IN p_codigo_asiento VARCHAR(10),
  IN p_estado ENUM('disponible','reservado','vendido'),
  IN p_precio DECIMAL(10,2)
)
BEGIN
  INSERT INTO asiento (id_vuelo, id_clase, fila, columna, codigo_asiento, estado, precio)
  VALUES (p_id_vuelo, p_id_clase, p_fila, p_columna, p_codigo_asiento, p_estado, p_precio);
END$$

CREATE PROCEDURE sp_borrado_logico_asiento (IN p_id INT)
BEGIN
  UPDATE asiento SET deleted = 1 WHERE id_asiento = p_id;
END$$

-- =========== USUARIO ===========
CREATE PROCEDURE sp_insertar_usuario (
  IN p_nombre VARCHAR(100),
  IN p_apellido VARCHAR(100),
  IN p_email VARCHAR(150),
  IN p_telefono VARCHAR(30)
)
BEGIN
  INSERT INTO usuario (nombre, apellido, email, telefono)
  VALUES (p_nombre, p_apellido, p_email, p_telefono);
END$$

CREATE PROCEDURE sp_borrado_logico_usuario (IN p_id INT)
BEGIN
  UPDATE usuario SET deleted = 1 WHERE id_usuario = p_id;
END$$

-- =========== RESERVA ===========
CREATE PROCEDURE sp_insertar_reserva (
  IN p_codigo_reserva VARCHAR(30),
  IN p_id_usuario INT,
  IN p_estado ENUM('pendiente','confirmada','cancelada','completada'),
  IN p_total DECIMAL(12,2)
)
BEGIN
  INSERT INTO reserva (codigo_reserva, id_usuario, estado, total)
  VALUES (p_codigo_reserva, p_id_usuario, p_estado, p_total);
END$$

CREATE PROCEDURE sp_borrado_logico_reserva (IN p_id INT)
BEGIN
  UPDATE reserva SET deleted = 1 WHERE id_reserva = p_id;
END$$

-- =========== PASAJERO ===========
CREATE PROCEDURE sp_insertar_pasajero (
  IN p_id_reserva INT,
  IN p_nombre VARCHAR(100),
  IN p_apellido VARCHAR(100),
  IN p_tipo_documento VARCHAR(20),
  IN p_numero_documento VARCHAR(50),
  IN p_fecha_nacimiento DATE,
  IN p_nacionalidad VARCHAR(80)
)
BEGIN
  INSERT INTO pasajero (id_reserva, nombre, apellido, tipo_documento, numero_documento, fecha_nacimiento, nacionalidad)
  VALUES (p_id_reserva, p_nombre, p_apellido, p_tipo_documento, p_numero_documento, p_fecha_nacimiento, p_nacionalidad);
END$$

CREATE PROCEDURE sp_borrado_logico_pasajero (IN p_id INT)
BEGIN
  UPDATE pasajero SET deleted = 1 WHERE id_pasajero = p_id;
END$$

-- =========== ASIGNACION_ASIENTO ===========
CREATE PROCEDURE sp_insertar_asignacion_asiento (
  IN p_id_pasajero INT,
  IN p_id_asiento INT
)
BEGIN
  INSERT INTO asignacion_asiento (id_pasajero, id_asiento)
  VALUES (p_id_pasajero, p_id_asiento);
END$$

CREATE PROCEDURE sp_borrado_logico_asignacion_asiento (IN p_id INT)
BEGIN
  UPDATE asignacion_asiento SET deleted = 1 WHERE id_asignacion = p_id;
END$$

-- =========== PAGO ===========
CREATE PROCEDURE sp_insertar_pago (
  IN p_id_reserva INT,
  IN p_metodo_pago VARCHAR(50),
  IN p_monto DECIMAL(12,2),
  IN p_referencia_pago VARCHAR(150),
  IN p_estado_pago ENUM('pendiente','exitoso','fallido','reembolsado')
)
BEGIN
  INSERT INTO pago (id_reserva, metodo_pago, monto, referencia_pago, estado_pago)
  VALUES (p_id_reserva, p_metodo_pago, p_monto, p_referencia_pago, p_estado_pago);
END$$

CREATE PROCEDURE sp_borrado_logico_pago (IN p_id INT)
BEGIN
  UPDATE pago SET deleted = 1 WHERE id_pago = p_id;
END$$

-- =========== TARIFA_VUELO_CLASE ===========
CREATE PROCEDURE sp_insertar_tarifa_vuelo_clase (
  IN p_id_vuelo INT,
  IN p_id_clase INT,
  IN p_precio DECIMAL(10,2)
)
BEGIN
  INSERT INTO tarifa_vuelo_clase (id_vuelo, id_clase, precio)
  VALUES (p_id_vuelo, p_id_clase, p_precio);
END$$

CREATE PROCEDURE sp_borrado_logico_tarifa_vuelo_clase (IN p_id INT)
BEGIN
  UPDATE tarifa_vuelo_clase SET deleted = 1 WHERE id_tarifa = p_id;
END$$

DELIMITER ;

-- =======================================================
-- EJEMPLOS DE PRUEBA: LLAMADAS A PROCEDIMIENTOS (CALL) y CONSULTAS DE VERIFICACIÓN
-- Ejecuta las llamadas y luego las SELECT para comprobar.
-- =======================================================

-- 1) Insertar ubicaciones
CALL sp_insertar_ubicacion('Santiago', 'Región Metropolitana', 'Chile', '8320000');
CALL sp_insertar_ubicacion('Buenos Aires', 'Buenos Aires', 'Argentina', '1000');

-- 2) Insertar aeropuertos (usar id_ubicacion 1 y 2 según inserts previos)
CALL sp_insertar_aeropuerto('SCL', 'Aeropuerto Arturo Merino Benítez', 1);
CALL sp_insertar_aeropuerto('EZE', 'Aeropuerto Internacional de Ezeiza', 2);

-- 3) Insertar aviones
CALL sp_insertar_avion('Airbus', 'A320', 180, 'CC-ABC');
CALL sp_insertar_avion('Boeing', '737-800', 189, 'CC-XYZ');

-- 4) Insertar clases
CALL sp_insertar_clase('Económica', 'Clase económica estándar');
CALL sp_insertar_clase('Business', 'Clase ejecutiva');

-- 5) Insertar usuarios
CALL sp_insertar_usuario('Cristofer', 'Vergara', 'cristoferv@example.com', '+56911111111');
CALL sp_insertar_usuario('Ana', 'Pérez', 'ana.perez@example.com', '+54911111111');

-- 6) Insertar vuelos (usa ids de avion y aeropuertos ya insertados)
CALL sp_insertar_vuelo('LA100', 1, 1, 2, '2025-11-10 08:00:00', '2025-11-10 10:00:00', 120, 1150);
CALL sp_insertar_vuelo('LA200', 2, 2, 1, '2025-11-12 09:00:00', '2025-11-12 11:10:00', 130, 1150);

-- 7) Insertar asientos
CALL sp_insertar_asiento(1, 1, '12', 'A', '12A', 'disponible', 120.00);
CALL sp_insertar_asiento(1, 1, '12', 'B', '12B', 'disponible', 120.00);

-- 8) Insertar reservas
CALL sp_insertar_reserva('RSV001', 1, 'confirmada', 240.00);
CALL sp_insertar_reserva('RSV002', 2, 'pendiente', 180.00);

-- 9) Insertar pasajeros
CALL sp_insertar_pasajero(1, 'Cristofer', 'Vergara', 'DNI', '12345678-9', '1995-01-01', 'Chilena');
CALL sp_insertar_pasajero(2, 'Ana', 'Pérez', 'DNI', '98765432-1', '1992-05-05', 'Argentina');

-- 10) Asignaciones de asiento
CALL sp_insertar_asignacion_asiento(1, 1); -- pasajero 1 -> asiento 1
CALL sp_insertar_asignacion_asiento(2, 2); -- pasajero 2 -> asiento 2

-- 11) Insertar pagos
CALL sp_insertar_pago(1, 'Tarjeta de Crédito', 240.00, 'TXN12345', 'exitoso');
CALL sp_insertar_pago(2, 'Transferencia', 180.00, 'TRF67890', 'pendiente');

-- 12) Insertar tarifas por vuelo/clase
CALL sp_insertar_tarifa_vuelo_clase(1, 1, 120.00);
CALL sp_insertar_tarifa_vuelo_clase(1, 2, 350.00);

-- =======================================================
-- EJEMPLOS DE BORRADO LÓGICO (CALL)
-- =======================================================
-- Marcar ubicacion id=2 como borrado lógico
CALL sp_borrado_logico_ubicacion(2);

-- Marcar usuario id=2 como borrado lógico
CALL sp_borrado_logico_usuario(2);

-- Marcar asiento id=2 como borrado lógico
CALL sp_borrado_logico_asiento(2);

-- =======================================================
-- CONSULTAS DE VERIFICACIÓN
-- =======================================================

-- Ver todos los registros (incluye deleted = 1)
SELECT * FROM ubicacion;
SELECT * FROM usuario;
SELECT * FROM asiento;

-- Ver solo activos (deleted = 0)
SELECT * FROM ubicacion WHERE deleted = 0;
SELECT * FROM usuario WHERE deleted = 0;
SELECT * FROM asiento WHERE deleted = 0;

-- Validar relación usuario -> reserva
SELECT u.id_usuario, u.nombre, r.id_reserva, r.codigo_reserva, r.estado, r.deleted
FROM usuario u
LEFT JOIN reserva r ON u.id_usuario = r.id_usuario;

-- Validar que CHECKs se cumplen:
-- Montos mayores que cero en pagos
SELECT * FROM pago WHERE monto <= 0;

-- Validar asignaciones activas (clientes activos y asientos no borrados)
SELECT a.id_asignacion, p.nombre AS pasajero, s.codigo_asiento, a.deleted
FROM asignacion_asiento a
JOIN pasajero p ON a.id_pasajero = p.id_pasajero
JOIN asiento s ON a.id_asiento = s.id_asiento
WHERE a.deleted = 0 AND p.deleted = 0 AND s.deleted = 0;

-- FIN DEL SCRIPT

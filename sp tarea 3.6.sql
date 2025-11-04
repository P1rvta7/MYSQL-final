-- =======================================================
-- SISTEMA DE RESERVAS DE VUELOS
-- Proyecto completo: Creación de BD, Tablas, Datos y Procedimientos
-- Autor: Cristofer Vergara
-- =======================================================

-- =======================================================
-- SCRIPT 1: CREACIÓN DE BASE DE DATOS Y TABLAS NORMALIZADAS
-- =======================================================

DROP DATABASE IF EXISTS sistema_reservas;
CREATE DATABASE sistema_reservas
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistema_reservas;

-- =======================================================
-- TABLA: UBICACION
-- Contiene información sobre ciudades, regiones y países
-- =======================================================
CREATE TABLE ubicacion (
  id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
  ciudad VARCHAR(100) NOT NULL,
  region VARCHAR(100),
  pais VARCHAR(100) NOT NULL,
  codigo_postal VARCHAR(20),
  deleted TINYINT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CHECK (CHAR_LENGTH(codigo_postal) >= 4)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================================
-- TABLA: AEROPUERTO
-- Define los aeropuertos y su ubicación
-- =======================================================
CREATE TABLE aeropuerto (
  id_aeropuerto INT AUTO_INCREMENT PRIMARY KEY,
  codigo_iata CHAR(3) NOT NULL UNIQUE,
  nombre VARCHAR(150) NOT NULL,
  id_ubicacion INT NOT NULL,
  deleted TINYINT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_ubicacion) REFERENCES ubicacion(id_ubicacion)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CHECK (CHAR_LENGTH(codigo_iata) = 3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================================
-- TABLA: AVION
-- Contiene la información técnica de los aviones
-- =======================================================
CREATE TABLE avion (
  id_avion INT AUTO_INCREMENT PRIMARY KEY,
  fabricante VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  capacidad_total INT NOT NULL,
  matricula VARCHAR(50) UNIQUE,
  deleted TINYINT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CHECK (capacidad_total > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================================
-- TABLA: CLASE
-- Registra los tipos de clase disponibles en los vuelos
-- =======================================================
CREATE TABLE clase (
  id_clase INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255),
  deleted TINYINT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================================
-- TABLA: USUARIO
-- Contiene los datos de los clientes registrados
-- =======================================================
CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  telefono VARCHAR(30),
  deleted TINYINT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================================
-- TABLA: RESERVA
-- Registra las reservas realizadas por los usuarios
-- =======================================================
CREATE TABLE reserva (
  id_reserva INT AUTO_INCREMENT PRIMARY KEY,
  codigo_reserva VARCHAR(30) NOT NULL UNIQUE,
  id_usuario INT NOT NULL,
  fecha_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('pendiente','confirmada','cancelada','completada') DEFAULT 'pendiente',
  total DECIMAL(12,2) DEFAULT 0.00,
  deleted TINYINT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================================
-- TABLA: PAGO
-- Registra los pagos asociados a las reservas
-- =======================================================
CREATE TABLE pago (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_reserva INT NOT NULL,
  metodo_pago VARCHAR(50) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado_pago ENUM('pendiente','exitoso','fallido','reembolsado') DEFAULT 'pendiente',
  deleted TINYINT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CHECK (monto > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================================
-- SCRIPT 2: INSERCIÓN DE DATOS Y CONSULTAS DE PRUEBA
-- =======================================================

INSERT INTO ubicacion (ciudad, region, pais, codigo_postal) VALUES
('Santiago', 'RM', 'Chile', '8320000'),
('Buenos Aires', 'BA', 'Argentina', '1000');

INSERT INTO aeropuerto (codigo_iata, nombre, id_ubicacion) VALUES
('SCL', 'Aeropuerto Arturo Merino Benítez', 1),
('EZE', 'Aeropuerto Internacional de Ezeiza', 2);

INSERT INTO avion (fabricante, modelo, capacidad_total, matricula) VALUES
('Airbus', 'A320', 180, 'CC-ABC'),
('Boeing', '737-800', 189, 'CC-XYZ');

INSERT INTO clase (nombre, descripcion) VALUES
('Económica', 'Asientos estándar con servicio básico'),
('Business', 'Asientos amplios y servicio premium');

INSERT INTO usuario (nombre, apellido, email, telefono) VALUES
('Cristofer', 'Vergara', 'cristoferv@example.com', '+56911111111'),
('Ana', 'Pérez', 'ana.perez@example.com', '+54911111111');

INSERT INTO reserva (codigo_reserva, id_usuario, estado, total) VALUES
('RSV001', 1, 'confirmada', 250.00),
('RSV002', 2, 'pendiente', 180.00);

INSERT INTO pago (id_reserva, metodo_pago, monto, estado_pago) VALUES
(1, 'Tarjeta de Crédito', 250.00, 'exitoso'),
(2, 'Transferencia', 180.00, 'pendiente');

-- Consultas de prueba
SELECT * FROM usuario;
SELECT * FROM usuario WHERE deleted = 0;

-- =======================================================
-- SCRIPT 3: PROCEDIMIENTOS ALMACENADOS
-- =======================================================
DELIMITER //

-- UBICACION
CREATE PROCEDURE sp_insertar_ubicacion(
  IN p_ciudad VARCHAR(100),
  IN p_region VARCHAR(100),
  IN p_pais VARCHAR(100),
  IN p_codigo_postal VARCHAR(20)
)
BEGIN
  INSERT INTO ubicacion (ciudad, region, pais, codigo_postal)
  VALUES (p_ciudad, p_region, p_pais, p_codigo_postal);
END //

CREATE PROCEDURE sp_borrado_logico_ubicacion(IN p_id INT)
BEGIN
  UPDATE ubicacion SET deleted = 1 WHERE id_ubicacion = p_id;
END //

CREATE PROCEDURE sp_mostrar_activos_ubicacion()
BEGIN
  SELECT * FROM ubicacion WHERE deleted = 0;
END //

CREATE PROCEDURE sp_mostrar_todos_ubicacion()
BEGIN
  SELECT * FROM ubicacion;
END //

-- USUARIO
CREATE PROCEDURE sp_insertar_usuario(
  IN p_nombre VARCHAR(100),
  IN p_apellido VARCHAR(100),
  IN p_email VARCHAR(150),
  IN p_telefono VARCHAR(30)
)
BEGIN
  INSERT INTO usuario (nombre, apellido, email, telefono)
  VALUES (p_nombre, p_apellido, p_email, p_telefono);
END //

CREATE PROCEDURE sp_borrado_logico_usuario(IN p_id INT)
BEGIN
  UPDATE usuario SET deleted = 1 WHERE id_usuario = p_id;
END //

CREATE PROCEDURE sp_mostrar_activos_usuario()
BEGIN
  SELECT * FROM usuario WHERE deleted = 0;
END //

CREATE PROCEDURE sp_mostrar_todos_usuario()
BEGIN
  SELECT * FROM usuario;
END //

-- RESERVA
CREATE PROCEDURE sp_insertar_reserva(
  IN p_codigo VARCHAR(30),
  IN p_id_usuario INT,
  IN p_estado VARCHAR(20),
  IN p_total DECIMAL(12,2)
)
BEGIN
  INSERT INTO reserva (codigo_reserva, id_usuario, estado, total)
  VALUES (p_codigo, p_id_usuario, p_estado, p_total);
END //

CREATE PROCEDURE sp_borrado_logico_reserva(IN p_id INT)
BEGIN
  UPDATE reserva SET deleted = 1 WHERE id_reserva = p_id;
END //

CREATE PROCEDURE sp_mostrar_activos_reserva()
BEGIN
  SELECT * FROM reserva WHERE deleted = 0;
END //

CREATE PROCEDURE sp_mostrar_todos_reserva()
BEGIN
  SELECT * FROM reserva;
END //

-- PAGO
CREATE PROCEDURE sp_insertar_pago(
  IN p_id_reserva INT,
  IN p_metodo_pago VARCHAR(50),
  IN p_monto DECIMAL(12,2),
  IN p_estado VARCHAR(20)
)
BEGIN
  INSERT INTO pago (id_reserva, metodo_pago, monto, estado_pago)
  VALUES (p_id_reserva, p_metodo_pago, p_monto, p_estado);
END //

CREATE PROCEDURE sp_borrado_logico_pago(IN p_id INT)
BEGIN
  UPDATE pago SET deleted = 1 WHERE id_pago = p_id;
END //

CREATE PROCEDURE sp_mostrar_activos_pago()
BEGIN
  SELECT * FROM pago WHERE deleted = 0;
END //

CREATE PROCEDURE sp_mostrar_todos_pago()
BEGIN
  SELECT * FROM pago;
END //

DELIMITER ;

-- =======================================================
-- PRUEBAS DE PROCEDIMIENTOS
-- =======================================================
CALL sp_insertar_usuario('Pedro', 'López', 'pedro@example.com', '+56922222222');
CALL sp_borrado_logico_usuario(2);
CALL sp_mostrar_activos_usuario();
CALL sp_mostrar_todos_usuario();

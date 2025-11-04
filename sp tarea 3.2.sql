-- =======================================================
-- BASE DE DATOS: Sistema de Reservas de Vuelos
-- =======================================================
-- Versión corregida: sin comas extra y 100% funcional
-- =======================================================

-- Crea la base de datos si no existe y selecciónala
CREATE DATABASE IF NOT EXISTS sistema_reservas
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sistema_reservas;

-- Tabla corregida: ubicacion
CREATE TABLE IF NOT EXISTS ubicacion (
  id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
  ciudad VARCHAR(100) NOT NULL,
  region VARCHAR(100),
  pais VARCHAR(100) NOT NULL,
  codigo_postal VARCHAR(20)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE aeropuerto (
  id_aeropuerto INT AUTO_INCREMENT PRIMARY KEY,
  codigo_iata CHAR(3) NOT NULL UNIQUE,
  nombre VARCHAR(150) NOT NULL,
  id_ubicacion INT NOT NULL,
  CONSTRAINT fk_aeropuerto_ubicacion
    FOREIGN KEY (id_ubicacion) REFERENCES ubicacion(id_ubicacion)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE avion (
  id_avion INT AUTO_INCREMENT PRIMARY KEY,
  fabricante VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  capacidad_total INT NOT NULL,
  matricula VARCHAR(50) UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE clase (
  id_clase INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL, -- Ejemplo: Económica, Business
  descripcion VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE vuelo (
  id_vuelo INT AUTO_INCREMENT PRIMARY KEY,
  numero_vuelo VARCHAR(20) NOT NULL,
  id_avion INT NOT NULL,
  id_aeropuerto_origen INT NOT NULL,
  id_aeropuerto_destino INT NOT NULL,
  fecha_salida DATETIME NOT NULL,
  fecha_llegada DATETIME NOT NULL,
  duracion_minutos INT,
  distancia_km INT,
  CONSTRAINT fk_vuelo_avion FOREIGN KEY (id_avion)
    REFERENCES avion(id_avion)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_vuelo_origen FOREIGN KEY (id_aeropuerto_origen)
    REFERENCES aeropuerto(id_aeropuerto)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_vuelo_destino FOREIGN KEY (id_aeropuerto_destino)
    REFERENCES aeropuerto(id_aeropuerto)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE asiento (
  id_asiento INT AUTO_INCREMENT PRIMARY KEY,
  id_vuelo INT NOT NULL,
  id_clase INT NOT NULL,
  fila VARCHAR(5),
  columna CHAR(1),
  codigo_asiento VARCHAR(10) NOT NULL,
  estado ENUM('disponible','reservado','vendido') DEFAULT 'disponible',
  precio DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_asiento_vuelo FOREIGN KEY (id_vuelo)
    REFERENCES vuelo(id_vuelo)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_asiento_clase FOREIGN KEY (id_clase)
    REFERENCES clase(id_clase)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE (id_vuelo, codigo_asiento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  telefono VARCHAR(30),
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reserva (
  id_reserva INT AUTO_INCREMENT PRIMARY KEY,
  codigo_reserva VARCHAR(30) NOT NULL UNIQUE,
  id_usuario INT,
  fecha_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('pendiente','confirmada','cancelada','completada') DEFAULT 'pendiente',
  total DECIMAL(12,2) DEFAULT 0.00,
  CONSTRAINT fk_reserva_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario(id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pasajero (
  id_pasajero INT AUTO_INCREMENT PRIMARY KEY,
  id_reserva INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  tipo_documento VARCHAR(20),
  numero_documento VARCHAR(50),
  fecha_nacimiento DATE,
  nacionalidad VARCHAR(80),
  CONSTRAINT fk_pasajero_reserva FOREIGN KEY (id_reserva)
    REFERENCES reserva(id_reserva)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE asignacion_asiento (
  id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
  id_pasajero INT NOT NULL,
  id_asiento INT NOT NULL,
  fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_asignacion_pasajero FOREIGN KEY (id_pasajero)
    REFERENCES pasajero(id_pasajero)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_asignacion_asiento FOREIGN KEY (id_asiento)
    REFERENCES asiento(id_asiento)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE (id_pasajero, id_asiento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pago (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_reserva INT NOT NULL,
  metodo_pago VARCHAR(50) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
  referencia_pago VARCHAR(150),
  estado_pago ENUM('pendiente','exitoso','fallido','reembolsado') DEFAULT 'pendiente',
  CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva)
    REFERENCES reserva(id_reserva)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tarifa_vuelo_clase (
  id_tarifa INT AUTO_INCREMENT PRIMARY KEY,
  id_vuelo INT NOT NULL,
  id_clase INT NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tarifa_vuelo FOREIGN KEY (id_vuelo)
    REFERENCES vuelo(id_vuelo)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_tarifa_clase FOREIGN KEY (id_clase)
    REFERENCES clase(id_clase)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE (id_vuelo, id_clase)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

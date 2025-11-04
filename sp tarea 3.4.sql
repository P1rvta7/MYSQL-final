-- =======================================================
-- SCRIPT 2: INSERCIONES Y CONSULTAS DE PRUEBA
-- Proyecto: Sistema de Reservas de Vuelos
-- =======================================================

USE sistema_reservas;

-- 🔹 Inserciones en tablas base
INSERT INTO ubicacion (ciudad, region, pais, codigo_postal)
VALUES 
('Santiago', 'RM', 'Chile', '8320000'),
('Buenos Aires', 'BA', 'Argentina', '1000');

INSERT INTO aeropuerto (codigo_iata, nombre, id_ubicacion)
VALUES 
('SCL', 'Aeropuerto Arturo Merino Benítez', 1),
('EZE', 'Aeropuerto Internacional de Ezeiza', 2);

INSERT INTO avion (fabricante, modelo, capacidad_total, matricula)
VALUES 
('Airbus', 'A320', 180, 'CC-ABC'),
('Boeing', '737-800', 189, 'CC-XYZ');

INSERT INTO clase (nombre, descripcion)
VALUES 
('Económica', 'Asientos estándar con servicio básico'),
('Business', 'Asientos amplios y servicio premium');

INSERT INTO usuario (nombre, apellido, email, telefono)
VALUES 
('Cristofer', 'Vergara', 'cristoferv@example.com', '+56911111111'),
('Ana', 'Pérez', 'ana.perez@example.com', '+54911111111');

-- 🔹 Vuelos
INSERT INTO vuelo (numero_vuelo, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, fecha_salida, fecha_llegada, duracion_minutos, distancia_km)
VALUES 
('LA100', 1, 1, 2, '2025-11-10 08:00:00', '2025-11-10 10:00:00', 120, 1150),
('LA200', 2, 2, 1, '2025-11-12 09:00:00', '2025-11-12 11:10:00', 130, 1150);

-- 🔹 Reservas
INSERT INTO reserva (codigo_reserva, id_usuario, estado, total)
VALUES 
('RSV001', 1, 'confirmada', 250.00),
('RSV002', 2, 'pendiente', 180.00);

-- 🔹 Pasajeros
INSERT INTO pasajero (id_reserva, nombre, apellido, tipo_documento, numero_documento, nacionalidad)
VALUES 
(1, 'Cristofer', 'Vergara', 'DNI', '12345678-9', 'Chilena'),
(2, 'Ana', 'Pérez', 'DNI', '98765432-1', 'Argentina');

-- 🔹 Pagos
INSERT INTO pago (id_reserva, metodo_pago, monto, estado_pago)
VALUES 
(1, 'Tarjeta de Crédito', 250.00, 'exitoso'),
(2, 'Transferencia', 180.00, 'pendiente');

-- =======================================================
-- CONSULTAS DE VERIFICACIÓN
-- =======================================================

-- Ver todos los registros
SELECT * FROM usuario;
SELECT * FROM reserva;
SELECT * FROM pago;

-- Mostrar solo registros activos
SELECT * FROM usuario WHERE deleted = 0;

-- Validar relación usuario-reserva
SELECT u.nombre, r.codigo_reserva, r.estado
FROM usuario u
JOIN reserva r ON u.id_usuario = r.id_usuario;

-- Validar CHECK (monto > 0)
SELECT * FROM pago WHERE monto <= 0;  -- Debe retornar vacío si está correcto

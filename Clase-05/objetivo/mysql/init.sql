CREATE DATABASE IF NOT EXISTS qhapaq;
USE qhapaq;
CREATE TABLE clientes (id INT, nombre VARCHAR(80), ruc VARCHAR(20));
INSERT INTO clientes VALUES (1,'Minera Andina SAC','20100000001'),(2,'Textiles del Sur','20100000002');
CREATE TABLE secretos (clave VARCHAR(120));
INSERT INTO secretos VALUES ('QHAPAQ{50a-mysql-credenciales-en-tabla}');
-- Cuenta de aplicacion con privilegio FILE (mala practica) y clave debil
CREATE USER 'webapp'@'%' IDENTIFIED BY 'W3bApp#2023';
GRANT ALL PRIVILEGES ON qhapaq.* TO 'webapp'@'%';
GRANT FILE ON *.* TO 'webapp'@'%';
FLUSH PRIVILEGES;

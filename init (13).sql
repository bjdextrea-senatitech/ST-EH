CREATE DATABASE IF NOT EXISTS qhapaq_erp;
USE qhapaq_erp;
CREATE TABLE IF NOT EXISTS flags (id INT PRIMARY KEY, valor VARCHAR(100));
INSERT IGNORE INTO flags VALUES (18, 'QHAPAQ{18-credenciales-en-un-share-dan-la-base-de-datos}');
CREATE TABLE IF NOT EXISTS accesos_remotos (id INT AUTO_INCREMENT PRIMARY KEY, sistema VARCHAR(40), host VARCHAR(40), usuario VARCHAR(40), clave VARCHAR(60), nota VARCHAR(120));
INSERT INTO accesos_remotos (sistema, host, usuario, clave, nota) VALUES
 ('Escritorio remoto gerencia', '10.40.0.38', 'gerencia', 'Gerencia#2025', 'RDP para el gerente cuando viaja'),
 ('Router borde', '10.40.0.5', 'admin', 'cisco', 'cambiar algún día');
CREATE TABLE IF NOT EXISTS clientes (id INT AUTO_INCREMENT PRIMARY KEY, ruc VARCHAR(11), razon_social VARCHAR(80));
INSERT INTO clientes (ruc, razon_social) VALUES ('20100000001','Andes Ficticios SAC'),('20100000002','Inca Demo EIRL'),('20100000003','Pacha Pruebas SRL');
CREATE USER IF NOT EXISTS 'webapp'@'%' IDENTIFIED BY 'W3bApp#2023';
GRANT ALL PRIVILEGES ON qhapaq_erp.* TO 'webapp'@'%';
GRANT FILE ON *.* TO 'webapp'@'%';
CREATE USER IF NOT EXISTS 'backup'@'%' IDENTIFIED BY 'backup123';
GRANT SELECT ON qhapaq_erp.clientes TO 'backup'@'%';
FLUSH PRIVILEGES;

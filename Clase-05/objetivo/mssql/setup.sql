-- Habilita xp_cmdshell (mala practica); el sa con clave debil permite RCE
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
CREATE DATABASE erp;
GO
USE erp;
CREATE TABLE secretos (clave VARCHAR(100));
INSERT INTO secretos VALUES ('QHAPAQ{52-mssql-sa-debil-xp-cmdshell}');
GO

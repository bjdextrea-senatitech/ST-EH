IF DB_ID('qhapaq_contable') IS NULL CREATE DATABASE qhapaq_contable;
GO
USE qhapaq_contable;
GO
IF OBJECT_ID('dbo.flags') IS NULL
BEGIN
  CREATE TABLE dbo.flags (id INT PRIMARY KEY, valor NVARCHAR(100));
  INSERT INTO dbo.flags VALUES (22, N'QHAPAQ{22-mssql-sa-con-clave-de-politica}');
  CREATE TABLE dbo.planilla (dni CHAR(8), nombre NVARCHAR(60), sueldo INT);
  INSERT INTO dbo.planilla VALUES ('00000001', N'Empleado Ficticio Uno', 3500), ('00000002', N'Empleado Ficticio Dos', 4200);
END
GO

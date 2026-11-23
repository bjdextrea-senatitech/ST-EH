#!/bin/bash
# Arranca SQL Server, espera a que acepte conexiones y carga los datos de la práctica
/opt/mssql/bin/sqlservr &
for _ in $(seq 1 60); do
  /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" >/dev/null 2>&1 && break
  sleep 2
done
/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -i /opt/qhapaq/init.sql
wait

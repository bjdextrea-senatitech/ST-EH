#!/bin/bash
/opt/mssql/bin/sqlservr &
for i in $(seq 1 50); do /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" >/dev/null 2>&1 && break; sleep 2; done
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -i /setup.sql 2>/dev/null
echo 'QHAPAQ{52b-mssql-rce-xp-cmdshell}' > /tmp/flag-mssql.txt
wait

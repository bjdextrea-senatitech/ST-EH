#!/bin/bash
PGBIN=$(ls -d /usr/lib/postgresql/*/bin)
DATA=/var/lib/postgresql/data
chown -R postgres:postgres $DATA
if [ ! -f "$DATA/PG_VERSION" ]; then
  su postgres -c "$PGBIN/initdb -D $DATA" >/dev/null 2>&1
  echo "host all all 0.0.0.0/0 md5" >> $DATA/pg_hba.conf
  echo "listen_addresses='*'" >> $DATA/postgresql.conf
  su postgres -c "$PGBIN/pg_ctl -D $DATA -w start" >/dev/null 2>&1
  su postgres -c "psql -c \"CREATE USER appsql WITH SUPERUSER PASSWORD 'Postgr3s#2024';\"" >/dev/null 2>&1
  su postgres -c "psql -c \"CREATE DATABASE erp OWNER appsql;\"" >/dev/null 2>&1
  su postgres -c "psql -d erp -c \"CREATE TABLE facturas(id int, monto numeric); INSERT INTO facturas VALUES (1,1500.50);\"" >/dev/null 2>&1
  su postgres -c "$PGBIN/pg_ctl -D $DATA -w stop" >/dev/null 2>&1
fi
echo 'QHAPAQ{51-postgres-copy-from-program-rce}' > /opt/flag-pg.txt; chmod 644 /opt/flag-pg.txt
exec su postgres -c "$PGBIN/postgres -D $DATA"

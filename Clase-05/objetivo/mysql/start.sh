#!/bin/bash
service apache2 start 2>/dev/null
mysqld_safe --user=mysql >/dev/null 2>&1 &
for i in $(seq 1 30); do mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done
mysql < /docker-entrypoint-initdb.d/init.sql 2>/dev/null
tail -F /dev/null

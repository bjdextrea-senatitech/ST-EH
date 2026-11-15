#!/bin/sh
/usr/local/bin/qhapaq-sync --server 10.30.0.60 --user svc_backup --password 'Backup2026!' &
exec snmpd -f -Lo -C -c /etc/snmp/snmpd.conf

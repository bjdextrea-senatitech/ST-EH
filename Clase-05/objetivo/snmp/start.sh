#!/bin/bash
echo 'QHAPAQ{57-snmp-comunidad-rw-y-extend-rce}' > /opt/flag-snmp.txt
exec /usr/sbin/snmpd -f -Lo -C -c /etc/snmp/snmpd.conf

# qx-snmp · snmpd con comunidad de LECTURA 'public' y de ESCRITURA 'private'.
# La comunidad RW permite inyectar un EXTEND nuevo = ejecucion de comandos (RCE).
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends snmpd snmp && rm -rf /var/lib/apt/lists/*
COPY snmpd.conf /etc/snmp/snmpd.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

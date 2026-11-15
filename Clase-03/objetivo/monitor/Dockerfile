FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends snmpd \
 && rm -rf /var/lib/apt/lists/*
COPY snmpd.conf /etc/snmp/snmpd.conf
COPY qhapaq-sync /usr/local/bin/qhapaq-sync
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/qhapaq-sync /entrypoint.sh
EXPOSE 161/udp
CMD ["/entrypoint.sh"]

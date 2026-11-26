# qx-ftp · ProFTPD 1.3.5 con mod_copy habilitado (CVE-2015-3306)
# SITE CPFR/CPTO permiten copiar archivos SIN autenticarse -> lectura/escritura arbitraria
FROM ubuntu:14.04
ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty main universe' > /etc/apt/sources.list && \
    apt-get update && apt-get install -y --force-yes proftpd-basic && rm -rf /var/lib/apt/lists/*
RUN echo 'LoadModule mod_copy.c' >> /etc/proftpd/modules.conf && \
    printf 'ServerName "FTP Qhapaq"\nDefaultRoot ~\n<Anonymous /var/ftp>\n  User ftp\n  Group nogroup\n  UserAlias anonymous ftp\n  RequireValidShell off\n  <Limit LOGIN>\n    AllowAll\n  </Limit>\n  AnonRequirePassword off\n  <Directory *>\n    <Limit WRITE>\n      DenyAll\n    </Limit>\n  </Directory>\n</Anonymous>\n' >> /etc/proftpd/proftpd.conf && \
    mkdir -p /var/ftp/pub /var/ftp/incoming && echo 'Comparticion publica de Qhapaq. Solo lectura.' > /var/ftp/pub/aviso.txt && \
    useradd -d /var/ftp -s /bin/bash ftp 2>/dev/null; usermod -d /var/ftp -s /bin/bash ftp 2>/dev/null; chown -R ftp:nogroup /var/ftp && chmod 777 /var/ftp/incoming && \
    mkdir -p /opt/respaldos && echo 'QHAPAQ{47-proftpd-mod-copy-cpfr-cpto}' > /opt/respaldos/config.bak && chmod 644 /opt/respaldos/config.bak
CMD ["proftpd","--nodaemon"]

# qx-mgmt · "Servidor de gestion" Linux con OMI (WS-Management, puertos de WinRM 5985/5986)
# OMI 1.6.6 + proveedor SCX (como en las VMs Linux de Azure). OMI 1.6.6 es vulnerable a OMIGOD (CVE-2021-38647): RCE como root sin autenticacion
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl libssl1.1 libpam0g openssl procps && \
    curl -fsSL -o /tmp/omi.deb https://github.com/microsoft/omi/releases/download/v1.6.6-0/omi-1.6.6-0.ssl_110.ulinux.x64.deb && \
    curl -fsSL -o /tmp/scx.deb https://github.com/microsoft/SCXcore/releases/download/v1.6.8-1/scx-1.6.8-1.ssl_110.ulinux.x64.deb && \
    (dpkg -i /tmp/omi.deb || true) && (dpkg -i /tmp/scx.deb || true) && rm -f /tmp/*.deb && rm -rf /var/lib/apt/lists/*
# Ajuste de laboratorio: el proveedor SCX publicado mas antiguo (1.6.8) declara la version 1.6.8 y OMI 1.6.6
# se niega a cargarlo; se parchea 1 byte (0x10608 -> 0x10606) de la version declarada en MI_Main.
RUN L=/opt/microsoft/scx/lib/libSCXCoreProviderModule.so && \
    printf '\006' | dd of=$L bs=1 seek=$((0x124334)) conv=notrunc status=none
RUN sed -i 's/^#\?\s*httpport=.*/httpport=5985/; s/^#\?\s*httpsport=.*/httpsport=5986/' /etc/opt/omi/conf/omiserver.conf && \
    echo 'QHAPAQ{41-omigod-winrm-sin-autenticacion}' > /root/bandera.txt && chmod 600 /root/bandera.txt && \
    printf 'Servidor de gestion QHAPAQ - agente OMI para monitoreo Azure\n' > /etc/motd
CMD ["/bin/bash","-c","/opt/omi/bin/omiserver -d; sleep 2; exec tail -F /var/opt/omi/log/omiserver.log"]

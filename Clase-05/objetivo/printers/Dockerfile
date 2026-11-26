# qx-printers · CUPS 2.3 con panel IPP expuesto a la red (631) + puerto de impresion cruda 9100 (PJL/PS).
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends cups cups-ipp-utils cups-client netcat-openbsd && rm -rf /var/lib/apt/lists/*
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

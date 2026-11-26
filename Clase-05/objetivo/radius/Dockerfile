# qx-radius · FreeRADIUS 3.0 con secreto compartido por defecto 'testing123' y PAP.
# Con el secreto debil un atacante valida credenciales y monta un cliente NAS falso.
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends freeradius freeradius-utils && rm -rf /var/lib/apt/lists/*
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

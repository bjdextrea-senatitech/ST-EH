# qx-postgres · PostgreSQL 12 con cuenta de aplicacion SUPERUSER y clave debil.
# COPY ... FROM PROGRAM ejecuta comandos del SO como el usuario postgres (CVE-2019-9193).
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends postgresql postgresql-client && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/lib/postgresql/data && chown postgres:postgres /var/lib/postgresql/data
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

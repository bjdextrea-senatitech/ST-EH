FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends samba \
 && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /srv/publico /srv/rrhh \
 && useradd -M -s /usr/sbin/nologin rrhh \
 && echo "Planillas 2026 - acceso restringido" > /srv/rrhh/LEEME.txt
COPY smb.conf /etc/samba/smb.conf
COPY publico/ /srv/publico/
RUN chmod -R a+rX /srv/publico && testparm -s >/dev/null
EXPOSE 139 445
CMD ["smbd", "--foreground", "--no-process-group", "--debug-stdout"]

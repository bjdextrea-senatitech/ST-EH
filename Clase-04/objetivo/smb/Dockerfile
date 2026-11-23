# qs-files · Samba (SMB2/3) con credenciales débiles y un share de TI con secretos
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends samba \
    && rm -rf /var/lib/apt/lists/* \
    && for u in jdiaz mquispe rhuaman soporte gerencia; do useradd -M -s /usr/sbin/nologin "$u"; done \
    && mkdir -p /srv/ti/respaldos /srv/ti/config /srv/publico
COPY smb.conf /etc/samba/smb.conf
COPY id_ed25519_deploy /srv/ti/respaldos/id_ed25519_deploy
COPY erp-db.conf /srv/ti/config/erp-db.conf
COPY flag.txt /srv/ti/flag.txt
COPY bienvenida.txt /srv/publico/bienvenida.txt
COPY start.sh /start.sh
RUN chmod +x /start.sh && chmod -R a+rX /srv
EXPOSE 445
CMD ["/start.sh"]

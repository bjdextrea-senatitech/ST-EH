# qx-rdp · xrdp con usuario de gerencia y credencial debil (fuerza bruta RDP con hydra/crowbar).
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends xrdp xterm xfonts-base dbus-x11 && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash gerencia && echo 'gerencia:Gerencia#2025' | chpasswd && \
    echo 'xterm' > /home/gerencia/.xsession && chown gerencia:gerencia /home/gerencia/.xsession && \
    adduser xrdp ssl-cert 2>/dev/null; echo ok
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

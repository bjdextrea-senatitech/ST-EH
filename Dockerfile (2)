# qs-rdp · escritorio remoto (xrdp) del gerente. En un Windows real sería el 3389 de Terminal Services.
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends xrdp xorgxrdp openbox xterm dbus-x11 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash gerencia && echo 'gerencia:Gerencia#2025' | chpasswd \
    && echo 'openbox-session' > /home/gerencia/.xsession \
    && mkdir -p /home/gerencia/.config/openbox \
    && echo 'xterm -geometry 100x30+20+20 -e "cat ~/Escritorio/flag.txt; bash" &' > /home/gerencia/.config/openbox/autostart \
    && mkdir -p /home/gerencia/Escritorio
COPY flag.txt /home/gerencia/Escritorio/flag.txt
RUN chown -R gerencia:gerencia /home/gerencia && chmod 600 /home/gerencia/Escritorio/flag.txt
COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 3389
CMD ["/start.sh"]

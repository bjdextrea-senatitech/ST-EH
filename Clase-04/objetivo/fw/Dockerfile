# qs-fw · "gimnasio" de nmap: firewall con reglas para practicar estados de puerto y evasión
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      iptables python3 tftpd-hpa openssh-server socat \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --set iptables /usr/sbin/iptables-legacy \
    && mkdir -p /srv/tftp /var/www /run/sshd
COPY index.html /var/www/index.html
COPY config-router.txt /srv/tftp/config-router.txt
COPY panel.txt /opt/panel.txt
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

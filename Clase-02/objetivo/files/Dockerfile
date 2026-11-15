FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      vsftpd openssh-server sudo findutils \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /run/sshd /var/run/vsftpd/empty /srv/ftp/pub \
 && ssh-keygen -A

# Usuario de soporte con contraseña débil (la misma que aparece en el instructivo)
RUN useradd -m -s /bin/bash soporte \
 && echo 'soporte:Qhapaq2025!' | chpasswd \
 && echo 'soporte ALL=(root) NOPASSWD: /usr/bin/find' > /etc/sudoers.d/limpieza-logs \
 && chmod 440 /etc/sudoers.d/limpieza-logs

COPY vsftpd.conf /etc/vsftpd.conf
COPY ftp/ /srv/ftp/pub/
COPY datos/user.txt /home/soporte/user.txt
COPY datos/clientes-2025.csv /home/soporte/backups/clientes-2025.csv
COPY datos/root.txt /root/root.txt
COPY entrypoint.sh /entrypoint.sh
RUN chown -R root:root /srv/ftp && chmod -R a+rX /srv/ftp \
 && chown -R soporte:soporte /home/soporte \
 && chmod 600 /root/root.txt && chmod +x /entrypoint.sh

EXPOSE 21 22 21100-21110
CMD ["/entrypoint.sh"]

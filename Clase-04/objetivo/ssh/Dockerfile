# qs-ssh · servidor Linux "legado" (Ubuntu 20.04 SIN parches: OpenSSH 8.2p1, polkit 0.105-26ubuntu1 → PwnKit)
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
# Solo el pocket "focal" original: así se instalan las versiones vulnerables de 2020
RUN sed -i '/focal-updates\|focal-security\|focal-backports/d' /etc/apt/sources.list \
    && apt-get update && apt-get install -y --no-install-recommends \
       openssh-server=1:8.2p1-4 openssh-sftp-server=1:8.2p1-4 policykit-1=0.105-26ubuntu1 \
    && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i '/^auth.*pam_unix.so/ s/$/ nodelay/' /etc/pam.d/common-auth \
    && sed -i 's/^#\?MaxStartups.*/MaxStartups 30:30:100/' /etc/ssh/sshd_config
# Usuarios descubiertos en la Clase 03 (VRFY de SMTP). Solo rhuaman sigue la política débil.
RUN for u in jdiaz mquispe rhuaman soporte gerencia deploy; do useradd -m -s /bin/bash "$u"; done \
    && echo 'rhuaman:Qhapaq2024#'        | chpasswd \
    && echo 'jdiaz:Vf8#kLq2!zRw9pXe'      | chpasswd \
    && echo 'mquispe:Tz4$hNw7@cQe1mBv'    | chpasswd \
    && echo 'soporte:Gk2!pYs8#rLd5uWn'    | chpasswd \
    && echo 'gerencia:Hq7@vMx3$eKt6jZa'   | chpasswd \
    && usermod -p '*' deploy
COPY deploy.pub /home/deploy/.ssh/authorized_keys
COPY flag-rhuaman.txt /home/rhuaman/flag.txt
COPY flag-deploy.txt  /home/deploy/flag.txt
COPY flag-root.txt    /root/flag.txt
RUN chown -R deploy:deploy /home/deploy && chmod 700 /home/deploy/.ssh && chmod 600 /home/deploy/.ssh/authorized_keys /home/deploy/flag.txt \
    && chown rhuaman:rhuaman /home/rhuaman/flag.txt && chmod 600 /home/rhuaman/flag.txt \
    && chmod 600 /root/flag.txt
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]

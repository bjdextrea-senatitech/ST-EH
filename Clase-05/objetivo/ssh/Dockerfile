# qx-ssh · OpenSSH 8.2p1: credencial debil (fuerza bruta dirigida) + escalada sudo tar (GTFOBins)
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo && rm -rf /var/lib/apt/lists/*
RUN for u in jdiaz mquispe soporte deploy; do useradd -m -s /bin/bash $u; done && \
    echo 'soporte:verano2025' | chpasswd && \
    echo 'jdiaz:S3gur1dad.Fuerte!2026' | chpasswd && \
    echo 'mquispe:M4ria.Quispe#77' | chpasswd && \
    echo 'deploy:Deploy-Str0ng-2026#' | chpasswd && \
    echo 'soporte ALL=(root) NOPASSWD: /usr/bin/tar' > /etc/sudoers.d/soporte && chmod 440 /etc/sudoers.d/soporte && \
    sed -i 's/^#\?MaxStartups.*/MaxStartups 60:30:120/; s/^#\?LoginGraceTime.*/LoginGraceTime 30/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

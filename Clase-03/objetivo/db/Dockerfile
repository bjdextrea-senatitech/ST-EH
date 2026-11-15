FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      redis-server openssh-server socat \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /run/sshd && ssh-keygen -A

# SSH en un puerto no estándar (no aparece si solo escaneas los 1000 puertos típicos)
RUN sed -i 's/^#\?Port .*/Port 2222/' /etc/ssh/sshd_config \
 && useradd -m -s /bin/bash svc_backup && echo 'svc_backup:Backup2026!' | chpasswd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 2222 6379 48620
CMD ["/entrypoint.sh"]

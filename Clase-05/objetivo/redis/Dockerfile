# qx-redis · Redis 5.0.7 SIN autenticacion ni protected-mode (6379 expuesto).
# Escritura arbitraria -> inyeccion de clave SSH en el home de redis = RCE (shell).
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends redis-server openssh-server && rm -rf /var/lib/apt/lists/*
RUN sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf && \
    sed -i 's/^protected-mode .*/protected-mode no/' /etc/redis/redis.conf && \
    sed -i 's/^daemonize .*/daemonize no/' /etc/redis/redis.conf && \
    sed -i 's|^logfile .*|logfile ""|' /etc/redis/redis.conf && \
    sed -i 's/^# *requirepass.*//' /etc/redis/redis.conf && \
    mkdir -p /var/run/sshd && \
    usermod -d /var/lib/redis -s /bin/bash redis && mkdir -p /var/lib/redis/.ssh && \
    chown -R redis:redis /var/lib/redis && chmod 700 /var/lib/redis/.ssh && \
    sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/; s/^#\?StrictModes.*/StrictModes no/' /etc/ssh/sshd_config && \
    echo 'QHAPAQ{55-redis-sin-autenticacion-rce}' > /var/lib/redis/flag-redis.txt && chmod 644 /var/lib/redis/flag-redis.txt
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

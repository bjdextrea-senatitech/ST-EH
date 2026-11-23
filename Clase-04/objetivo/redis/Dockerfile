# qs-cache · Redis 5.0.7 del paquete de Ubuntu 20.04 SIN parche → CVE-2022-0543 (escape del sandbox Lua)
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i '/focal-updates\|focal-security\|focal-backports/d' /etc/apt/sources.list \
    && apt-get update && apt-get install -y --no-install-recommends redis-server=5:5.0.7-2 redis-tools=5:5.0.7-2 \
    && rm -rf /var/lib/apt/lists/*
COPY flag.txt /var/lib/redis/flag.txt
RUN chown redis:redis /var/lib/redis/flag.txt && chmod 600 /var/lib/redis/flag.txt
USER redis
EXPOSE 6379
CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no", "--dir", "/var/lib/redis"]

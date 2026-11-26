# qx-vnc · x11vnc con contrasena debil (8 caracteres, crackeable con hydra/medusa)
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends x11vnc xvfb xterm && rm -rf /var/lib/apt/lists/*
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

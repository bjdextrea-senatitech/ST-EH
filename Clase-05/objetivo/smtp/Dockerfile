# qx-smtp · Postfix como OPEN RELAY (mynetworks=0.0.0.0/0) + comando VRFY activo (enum de usuarios)
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends postfix rsyslog && rm -rf /var/lib/apt/lists/* || true
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

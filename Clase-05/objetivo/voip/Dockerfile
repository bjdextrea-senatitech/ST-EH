# qx-voip · Asterisk (SIP) con alwaysauthreject=no (permite enumerar extensiones) y secretos debiles.
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends asterisk && rm -rf /var/lib/apt/lists/*
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

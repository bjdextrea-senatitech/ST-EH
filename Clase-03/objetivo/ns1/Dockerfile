FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends bind9 \
 && rm -rf /var/lib/apt/lists/*
COPY named.conf.options named.conf.local /etc/bind/
COPY db.qhapaq.lab /etc/bind/db.qhapaq.lab
RUN named-checkconf && named-checkzone qhapaq.lab /etc/bind/db.qhapaq.lab
EXPOSE 53/tcp 53/udp
# -g: primer plano con logs a la consola · -4: solo IPv4
CMD ["named", "-g", "-4", "-u", "bind"]

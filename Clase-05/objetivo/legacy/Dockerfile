# qx-legacy · Intranet antigua (Ubuntu 14.04 sin parches): Apache 2.4.7 + OpenSSL 1.0.1f + bash 4.3
#   80/tcp  -> /cgi-bin/estado.sh  (Shellshock, CVE-2014-6271)
#   443/tcp -> HTTPS con OpenSSL 1.0.1f (Heartbleed, CVE-2014-0160)
# Etapa 1: se recompila el paquete openssl 1.0.1f-1ubuntu2 de 14.04 SIN el parche de Heartbleed
FROM ubuntu:14.04 AS openssl-vulnerable
ENV DEBIAN_FRONTEND=noninteractive
RUN printf 'deb http://archive.ubuntu.com/ubuntu trusty main universe\ndeb http://archive.ubuntu.com/ubuntu trusty-updates main universe\ndeb http://archive.ubuntu.com/ubuntu trusty-security main universe\ndeb-src http://archive.ubuntu.com/ubuntu trusty main\n' > /etc/apt/sources.list && \
    apt-get update && apt-get install -y --force-yes build-essential dpkg-dev fakeroot && \
    apt-get build-dep -y --force-yes openssl && \
    mkdir /build && cd /build && apt-get source --download-only openssl=1.0.1f-1ubuntu2 && dpkg-source -x --skip-patches openssl_1.0.1f-1ubuntu2.dsc && cd openssl-1.0.1f && \
    sed -i '/CVE-2014-0160/d' debian/patches/series && \
    DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -b -uc -us >/dev/null && ls /build/*.deb

FROM ubuntu:14.04
ENV DEBIAN_FRONTEND=noninteractive
# Solo el "pocket" original de 14.04 (sin -updates ni -security) para obtener las versiones vulnerables
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty main universe' > /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --force-yes bash=4.3-6ubuntu1 && \
    apt-get install -y --force-yes apache2=2.4.7-1ubuntu4 openssl=1.0.1f-1ubuntu2 libssl1.0.0=1.0.1f-1ubuntu2 ssl-cert curl && \
    rm -rf /var/lib/apt/lists/*
COPY --from=openssl-vulnerable /build/libssl1.0.0_1.0.1f-1ubuntu2_amd64.deb /build/openssl_1.0.1f-1ubuntu2_amd64.deb /tmp/
RUN dpkg -i /tmp/libssl1.0.0_*.deb /tmp/openssl_*.deb && apt-mark hold libssl1.0.0 openssl && rm -f /tmp/*.deb
RUN a2enmod cgi ssl && a2ensite default-ssl && \
    sed -i 's/^\(\s*\)MaxSpareServers.*/\1MaxSpareServers 2/; s/^\(\s*\)StartServers.*/\1StartServers 1/; s/^\(\s*\)MinSpareServers.*/\1MinSpareServers 1/' /etc/apache2/mods-available/mpm_prefork.conf && \
    a2dismod mpm_event && a2enmod mpm_prefork && \
    echo 'ServerName legacy.qhapaq.lab' >> /etc/apache2/apache2.conf
COPY cgi/estado.sh /usr/lib/cgi-bin/estado.sh
COPY www/ /var/www/html/
COPY bot.sh /usr/local/bin/bot.sh
RUN chmod 755 /usr/lib/cgi-bin/estado.sh /usr/local/bin/bot.sh && \
    echo 'QHAPAQ{53-shellshock-cgi-bash}' > /var/www/bandera-53.txt && chown www-data /var/www/bandera-53.txt && chmod 400 /var/www/bandera-53.txt
CMD ["/bin/bash","-c","/usr/local/bin/bot.sh & exec apache2ctl -D FOREGROUND"]

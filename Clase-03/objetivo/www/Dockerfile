FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends apache2 openssl \
 && rm -rf /var/lib/apt/lists/* \
 && a2enmod ssl headers >/dev/null

# Certificado autofirmado: sus nombres alternativos (SAN) delatan otros subdominios
RUN openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
      -keyout /etc/ssl/private/qhapaq.key -out /etc/ssl/certs/qhapaq.crt \
      -subj "/C=PE/ST=Arequipa/O=Inversiones Qhapaq SAC/OU=QHAPAQ{06-el-certificado-habla}/CN=www.qhapaq.lab" \
      -addext "subjectAltName=DNS:www.qhapaq.lab,DNS:intranet.qhapaq.lab,DNS:dev.qhapaq.lab,DNS:vpn-old.qhapaq.lab,DNS:portal-rrhh.qhapaq.lab"

COPY qhapaq.conf /etc/apache2/sites-available/000-default.conf
COPY sitio/ /var/www/html/
RUN rm -f /var/www/html/index.html.dpkg* \
 && echo "ServerName www.qhapaq.lab" >> /etc/apache2/apache2.conf \
 && sed -i 's/^ServerTokens .*/ServerTokens Full/; s/^ServerSignature .*/ServerSignature On/' /etc/apache2/conf-available/security.conf
EXPOSE 80 443
CMD ["apachectl", "-D", "FOREGROUND"]

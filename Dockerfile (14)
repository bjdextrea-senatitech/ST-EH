# qs-db · MariaDB expuesta + Apache/PHP en 8080. Mala configuración: FILE + secure_file_priv vacío + carpeta web escribible por mysql
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server apache2 libapache2-mod-php php-mysql \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/:80>/:8080>/' /etc/apache2/sites-available/000-default.conf \
    && echo 'ServerName qi-erp-db' >> /etc/apache2/apache2.conf \
    && mkdir -p /var/www/html/uploads && chown mysql:mysql /var/www/html/uploads && chmod 755 /var/www/html/uploads
COPY 99-qhapaq.cnf /etc/mysql/mariadb.conf.d/99-qhapaq.cnf
COPY init.sql /opt/init.sql
COPY index.php /var/www/html/index.php
COPY flag-rce.txt /var/www/flag-rce.txt
COPY start.sh /start.sh
RUN rm -f /var/www/html/index.html && chown www-data:www-data /var/www/flag-rce.txt && chmod 600 /var/www/flag-rce.txt && chmod +x /start.sh
EXPOSE 3306 8080
CMD ["/start.sh"]

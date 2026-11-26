# qx-mysql · MariaDB con privilegio FILE en la cuenta de app + Apache/PHP.
# secure_file_priv vacio -> INTO OUTFILE escribe una webshell en el DocumentRoot = RCE www-data.
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server apache2 php libapache2-mod-php && rm -rf /var/lib/apt/lists/*
COPY my.cnf /etc/mysql/mariadb.conf.d/99-lab.cnf
COPY init.sql /docker-entrypoint-initdb.d/init.sql
COPY start.sh /start.sh
RUN chmod +x /start.sh && \
    sed -i 's/^bind-address.*/bind-address=0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf && \
    chmod 777 /var/www/html && echo '<h1>Portal Qhapaq</h1>' > /var/www/html/index.html && \
    mkdir -p /opt/app && echo 'QHAPAQ{50-mysql-file-into-outfile-webshell}' > /opt/app/flag-mysql.txt && chmod 644 /opt/app/flag-mysql.txt
CMD ["/start.sh"]

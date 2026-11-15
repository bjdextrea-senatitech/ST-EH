FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections \
 && echo "postfix postfix/mailname string mail.qhapaq.lab" | debconf-set-selections \
 && apt-get update && apt-get install -y --no-install-recommends postfix \
 && rm -rf /var/lib/apt/lists/*

# Cuentas de correo de la empresa (cada buzón es un usuario del sistema; "backup" ya existe en Ubuntu)
RUN for u in jdiaz mquispe rhuaman soporte rrhh gerencia; do \
      useradd -M -s /usr/sbin/nologin "$u"; \
    done

RUN postconf -e "myhostname = mail.qhapaq.lab" \
 && postconf -e "mydomain = qhapaq.lab" \
 && postconf -e "mydestination = \$myhostname, qhapaq.lab, localhost" \
 && postconf -e "inet_interfaces = all" \
 && postconf -e "inet_protocols = ipv4" \
 && postconf -e "smtpd_banner = \$myhostname ESMTP Postfix (Ubuntu)" \
 && postconf -e "disable_vrfy_command = no" \
 && postconf -e "maillog_file = /dev/stdout" \
 && postconf -F '*/*/chroot = n'
EXPOSE 25
CMD ["postfix", "start-fg"]

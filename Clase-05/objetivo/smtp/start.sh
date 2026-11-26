#!/bin/bash
for u in jdiaz mquispe soporte gerencia rhuaman; do id $u >/dev/null 2>&1 || useradd -m $u; done
echo 'QHAPAQ{62-smtp-open-relay-y-vrfy}' > /etc/smtp-flag.txt
postconf -e "myhostname=mail.qhapaq.lab" "mydestination=mail.qhapaq.lab, localhost" \
  "smtpd_recipient_restrictions=permit_mynetworks,permit" "mynetworks=0.0.0.0/0" \
  "disable_vrfy_command=no" "smtpd_banner=mail.qhapaq.lab ESMTP Postfix (QHAPAQ)" \
  "inet_interfaces=all" "inet_protocols=ipv4" >/dev/null 2>&1
service postfix start >/dev/null 2>&1
tail -F /var/log/mail.log 2>/dev/null || tail -F /dev/null

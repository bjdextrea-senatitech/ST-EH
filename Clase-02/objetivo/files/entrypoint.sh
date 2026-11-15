#!/bin/bash
# Arranca SSH en segundo plano y vsftpd como proceso hijo.
# (vsftpd no se lleva bien siendo el PID 1 del contenedor: por eso no usamos exec)
/usr/sbin/sshd
/usr/sbin/vsftpd /etc/vsftpd.conf &
wait -n

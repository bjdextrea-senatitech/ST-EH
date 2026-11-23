#!/bin/bash
# Reglas del firewall (lo que el alumno debe "mapear" con nmap)
iptables -F INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP          # no responde ping
iptables -A INPUT -p tcp --dport 80 -j ACCEPT                         # open
iptables -A INPUT -p tcp --dport 22 -j ACCEPT                         # open
iptables -A INPUT -p tcp --dport 443 -j REJECT --reject-with tcp-reset # closed
iptables -A INPUT -p tcp --dport 8080 -j DROP                         # filtered
iptables -A INPUT -p tcp --dport 3306 -j REJECT --reject-with icmp-port-unreachable # filtered (ICMP)
iptables -A INPUT -p tcp --sport 53 --dport 9999 -j ACCEPT            # panel "de confianza"
iptables -A INPUT -p tcp --dport 9999 -j DROP
iptables -A INPUT -p udp --dport 69 -j ACCEPT                         # TFTP
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j DROP                                      # el resto: filtered

/usr/sbin/sshd
in.tftpd -4 --listen --user tftp --address 0.0.0.0:69 --secure /srv/tftp   # -4: el contenedor no tiene IPv6
socat TCP-LISTEN:9999,fork,reuseaddr SYSTEM:'cat /opt/panel.txt' &
cd /var/www && exec python3 -m http.server 80

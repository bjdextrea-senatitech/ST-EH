#!/bin/bash
# qx-dc01 · Controlador de dominio Samba AD (QHAPAQ.LAB) deliberadamente mal configurado
set -u
MARK=/var/lib/samba/.qhapaq-listo
if [ ! -f "$MARK" ]; then
  rm -rf /etc/samba/smb.conf /var/lib/samba/private/* /var/lib/samba/sysvol/* /var/lib/samba/*.tdb /var/lib/samba/*.ldb
  samba-tool domain provision --realm=QHAPAQ.LAB --domain=QHAPAQ --server-role=dc \
    --dns-backend=SAMBA_INTERNAL --adminpass='Qh@paq-DA-2026!x' --host-name=dc01 \
    --host-ip=10.55.0.10 --option="vfs objects = dfs_samba4 acl_xattr xattr_tdb" \
    --option="dns forwarder = 127.0.0.11" >/var/log/provision.log 2>&1
  cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
  printf '\n[kdc]\n\trequire-preauth = false\n' >> /etc/krb5.conf
  # Recursos compartidos
  mkdir -p /srv/rrhh /srv/sqlbackups /srv/ti /srv/gerencia
  echo 'QHAPAQ{43-asrep-roasting-sin-preautenticacion}' > /srv/rrhh/bandera.txt
  printf 'Planilla noviembre 2026 - CONFIDENCIAL\nNota: el portal de RRHH migra a la nube en diciembre.\n' > /srv/rrhh/planilla-nov.txt
  echo 'QHAPAQ{44-kerberoasting-cuenta-de-servicio}' > /srv/sqlbackups/bandera.txt
  printf '# Conexion al SQL Server de produccion (10.55.0.33)\nServer=sql01.qhapaq.lab,1433;User Id=svc_sql;Password=(la misma de la cuenta de dominio)\n' > /srv/sqlbackups/conexion.txt
  echo 'QHAPAQ{45-gpp-cpassword-en-sysvol}' > /srv/ti/bandera.txt
  echo 'QHAPAQ{46-domain-admin-pass-the-hash}' > /srv/gerencia/bandera.txt
  cat >> /etc/samba/smb.conf <<'SMB'

[RRHH]
   path = /srv/rrhh
   read only = yes
   valid users = QHAPAQ\pramos QHAPAQ\Administrator
[SQLBackups]
   path = /srv/sqlbackups
   read only = yes
   valid users = QHAPAQ\svc_sql QHAPAQ\Administrator
[TI]
   path = /srv/ti
   read only = yes
   valid users = QHAPAQ\adm_soporte QHAPAQ\Administrator
[Gerencia]
   path = /srv/gerencia
   read only = yes
   valid users = QHAPAQ\Administrator @"QHAPAQ\Domain Admins"
SMB
  chmod -R a+rX /srv
  samba -D; sleep 6
  samba-tool domain passwordsettings set --complexity=off --min-pwd-length=1 --history-length=0 --min-pwd-age=0 --max-pwd-age=0 >/dev/null
  mk() { samba-tool user create "$1" "$2" --given-name="$3" --surname="$4" --description="$5" >/dev/null; }
  mk jdiaz      'Qhapaq2026!'          'Juan'  'Diaz'    'Jefe de TI'
  mk mquispe    'M4ria.Quispe#77'      'Maria' 'Quispe'  'Contabilidad'
  mk rhuaman    'Rh.2026-Fin*'         'Rosa'  'Huaman'  'Finanzas'
  mk lmamani    'Lm-Ventas.2026'       'Luis'  'Mamani'  'Ventas'
  mk gerencia   'Gerencia#2025'        'Carlos' 'Flores' 'Gerente general'
  mk pramos     'sunshine1'            'Pedro' 'Ramos'   'Asistente RRHH'
  mk svc_sql    'Password123'          'Servicio' 'SQL'  'Cuenta de servicio SQL Server'
  mk svc_impresion 'Impresora2026!'    'Servicio' 'Impresion' 'Cola de impresion - pwd temporal: Impresora2026! - QHAPAQ{42-rpcclient-sesion-nula-y-descripciones}'
  mk adm_soporte 'Soporte#Qhapaq2026'  'Admin' 'Soporte'  'Administrador de soporte'
  samba-tool group addmembers "Domain Admins" adm_soporte >/dev/null
  # Mala practica 1: AS-REP roasting (DONT_REQ_PREAUTH = 0x400000)
  DN=$(ldbsearch -H /var/lib/samba/private/sam.ldb "(sAMAccountName=pramos)" dn | awk '/^dn:/{print substr($0,5)}')
  printf 'dn: %s\nchangetype: modify\nreplace: userAccountControl\nuserAccountControl: 4260352\n' "$DN" | ldbmodify -H /var/lib/samba/private/sam.ldb >/dev/null
  # Samba 4.19 (Heimdal) exige preautenticacion a todos por defecto: se desactiva a nivel KDC
  # para que el flag DONT_REQ_PREAUTH de cada cuenta se respete (como en un AD de Windows)
  DN=$(ldbsearch -H /var/lib/samba/private/sam.ldb "(sAMAccountName=krbtgt)" dn | awk '/^dn:/{print substr($0,5)}')
  printf 'dn: %s\nchangetype: modify\nreplace: userAccountControl\nuserAccountControl: 4194818\n' "$DN" | ldbmodify -H /var/lib/samba/private/sam.ldb >/dev/null
  # Mala practica 2: cuenta de servicio con SPN y clave debil (Kerberoasting)
  samba-tool spn add MSSQLSvc/sql01.qhapaq.lab:1433 svc_sql >/dev/null
  # Mala practica 3: sesion nula -> "Anonymous Logon" en Pre-Windows 2000 Compatible Access
  samba-tool group addmembers "Pre-Windows 2000 Compatible Access" S-1-5-7 >/dev/null 2>&1 || true
  # Mala practica 4: Group Policy Preferences con cpassword en SYSVOL
  python3 /gpp.py 'Soporte#Qhapaq2026' > /tmp/cpass
  POL=/var/lib/samba/sysvol/qhapaq.lab/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/Machine/Preferences/Groups
  mkdir -p "$POL"
  cat > "$POL/Groups.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<Groups clsid="{3125E937-EB16-4b4c-9934-544FC6D24D26}"><User clsid="{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}" name="adm_soporte" image="2" changed="2025-03-14 09:12:44" uid="{8F3A1B2C-4D5E-4F60-9A1B-2C3D4E5F6A7B}"><Properties action="U" newName="" fullName="Admin Soporte" description="Admin local en estaciones" cpassword="$(cat /tmp/cpass)" changeLogon="0" noChange="1" neverExpires="1" acctDisabled="0" userName="adm_soporte"/></User>
</Groups>
XML
  rm -f /tmp/cpass
  samba-tool ntacl sysvolreset >/dev/null 2>&1 || true
  chmod -R a+rX /var/lib/samba/sysvol
  pkill samba; sleep 3
  touch "$MARK"
fi
exec samba -F --no-process-group

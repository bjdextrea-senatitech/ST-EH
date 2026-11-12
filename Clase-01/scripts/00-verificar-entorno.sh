#!/usr/bin/env bash
# =============================================================================
# 00-verificar-entorno.sh  ·  SENATI DC05 Ethical Hacking · Clase 01
# Revisa que tu máquina (Kali, Ubuntu o WSL) tenga todo lo que pide Bandit.
# Solo LEE: no instala ni cambia nada.
#
# Uso:  bash 00-verificar-entorno.sh
# =============================================================================

HOST="bandit.labs.overthewire.org"
PUERTO=2220
OK=0
FALTA=0

echo "=== 1. Herramientas que usaremos hoy ==="
# Cada palabra de la lista es un comando; "command -v" dice dónde está o falla si no existe.
for herramienta in ssh scp nc openssl nmap git file xxd base64 tr strings diff gzip bzip2 tar; do
    if command -v "$herramienta" > /dev/null 2>&1; then
        echo "  [OK]    $herramienta  ->  $(command -v "$herramienta")"
        OK=$((OK + 1))
    else
        echo "  [FALTA] $herramienta"
        FALTA=$((FALTA + 1))
    fi
done

echo
echo "=== 2. ¿Llego al servidor de Bandit? ==="
# Resolución DNS: getent consulta el mismo resolvedor que usa ssh.
if getent hosts "$HOST" > /dev/null 2>&1; then
    echo "  [OK]    DNS: $HOST = $(getent hosts "$HOST" | head -n 1 | cut -d ' ' -f 1)"
else
    echo "  [FALLA] No se resuelve $HOST (¿hay Internet en la VM?)"
fi

# /dev/tcp es una función de bash: abre una conexión TCP sin necesitar nc.
# timeout corta el intento a los 5 segundos para no quedarse colgado.
if timeout 5 bash -c "exec 3<>/dev/tcp/$HOST/$PUERTO" 2> /dev/null; then
    echo "  [OK]    Puerto $PUERTO abierto en $HOST"
else
    echo "  [FALLA] No conecta al puerto $PUERTO (red del local, proxy o firewall)"
fi

echo
echo "=== 3. Carpeta de trabajo ==="
if [ -d "$HOME/bandit" ]; then
    echo "  [OK]    Ya existe $HOME/bandit"
else
    echo "  [INFO]  Aún no existe $HOME/bandit (la crea guardar-clave.sh)"
fi

echo
echo "Resultado: $OK herramientas OK, $FALTA faltan."
if [ "$FALTA" -gt 0 ]; then
    echo "En Kali/Ubuntu instálalas con:"
    echo "  sudo apt update && sudo apt install -y openssh-client netcat-openbsd openssl nmap git file xxd binutils bzip2"
fi

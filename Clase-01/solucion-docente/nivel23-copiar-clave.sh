#!/bin/bash
# Solución docente · Bandit 23 → 24 · NO REPARTIR
# Se copia a /var/spool/bandit24/foo/ y lo ejecuta el cron como bandit24.
# Antes, como bandit23:
#   DIR=$(mktemp -d) && chmod 777 "$DIR" && echo "$DIR"
#   (editar DESTINO con esa ruta)
#   cp nivel23-copiar-clave.sh /var/spool/bandit24/foo/copiar-$RANDOM.sh
#   chmod 755 /var/spool/bandit24/foo/copiar-*.sh
#   esperar hasta 60 s y luego: cat "$DIR/clave24"

DESTINO="/tmp/tmp.CAMBIAR"
cat /etc/bandit_pass/bandit24 > "$DESTINO/clave24"
chmod 644 "$DESTINO/clave24"

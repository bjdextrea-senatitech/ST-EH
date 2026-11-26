#!/bin/bash
# El administrador consulta la intranet por HTTPS de forma continua. Sus credenciales
# y token de sesion quedan en los buffers de Apache: lo que Heartbleed devuelve.
sleep 5
PAD=$(printf 'A%.0s' $(seq 1 1024))
while true; do
  for _ in $(seq 1 10); do
    curl -sk -o /dev/null https://127.0.0.1/login.html \
      -H "X-Relleno: $PAD" \
      -H "X-Usuario: admin.intranet" \
      -H "X-Clave: Intr4net!2014" \
      -H "X-Token-Sesion: QHAPAQ{54-heartbleed-memoria-filtrada}" 2>/dev/null &
  done
  wait
done

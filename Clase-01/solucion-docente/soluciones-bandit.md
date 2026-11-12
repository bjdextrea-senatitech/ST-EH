# Solucionario docente · Bandit 0 → 34 · NO SUBIR AL REPO PÚBLICO

Solo comandos, sin claves: las claves de Bandit cambian de vez en cuando. `$H` = `bandit.labs.overthewire.org`.

| Nivel | Solución |
|---|---|
| 0 | `ssh -p 2220 bandit0@$H` (clave `bandit0`) |
| 0→1 | `cat readme` |
| 1→2 | `cat ./-` |
| 2→3 | `cat ./--spaces\ in\ this\ filename--` (o `cat -- "--spaces in this filename--"`; el nombre cambió en 2024; antes era `spaces in this filename`) |
| 3→4 | `ls -la inhere` → `cat inhere/...Hiding-From-You` (antes era `.hidden`) |
| 4→5 | `file ./inhere/*` → `cat ./inhere/-file07` (el número puede variar) |
| 5→6 | `find inhere -type f -size 1033c ! -executable -exec cat {} \;` |
| 6→7 | `find / -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null` → `/var/lib/dpkg/info/bandit7.password` |
| 7→8 | `grep millionth data.txt` |
| 8→9 | `sort data.txt \| uniq -u` |
| 9→10 | `strings data.txt \| grep "==="` |
| 10→11 | `base64 -d data.txt` |
| 11→12 | `tr 'A-Za-z' 'N-ZA-Mn-za-m' < data.txt` |
| 12→13 | `D=$(mktemp -d); cp data.txt $D; cd $D; xxd -r data.txt > f` y luego, según `file f`: gzip → `mv f f.gz; gzip -d f.gz` · bzip2 → `bzip2 -d f; mv f.out f` · tar → `tar -xf f` (sale un archivo nuevo). Repetir unas 9 veces hasta `ASCII text` |
| 13→14 | Local: `scp -P 2220 bandit13@$H:sshkey.private b14.key; chmod 600 b14.key; ssh -i b14.key -p 2220 bandit14@$H`. Dentro: `cat /etc/bandit_pass/bandit14` (ya no se permite `ssh localhost` desde el servidor) |
| 14→15 | `cat /etc/bandit_pass/bandit14 \| nc localhost 30000` |
| 15→16 | `openssl s_client -connect localhost:30001 -quiet < /etc/bandit_pass/bandit15` (si corta: `-ign_eof`) |
| 16→17 | `nmap -sV -p 31000-32000 localhost` → hay 2 puertos `ssl/unknown` (típicamente 31790) → `openssl s_client -connect localhost:31790 -quiet < /etc/bandit_pass/bandit16` → devuelve una llave RSA → guardar local, `chmod 600`, `ssh -i ... bandit17@$H` |
| 17→18 | `diff passwords.old passwords.new` → la línea con `>` |
| 18→19 | `ssh -p 2220 bandit18@$H cat readme` |
| 19→20 | `./bandit20-do cat /etc/bandit_pass/bandit20` |
| 20→21 | `nc -l -p 4444 < /etc/bandit_pass/bandit20 &` y luego `./suconnect 4444` (respuesta en la salida del nc) |
| 21→22 | `cat /etc/cron.d/cronjob_bandit22` → `cat /usr/bin/cronjob_bandit22.sh` → `cat /tmp/t7O6lds9S0RqQh9aMcz6ShpAoZKF7fgv` (nombre puede variar: leerlo del script) |
| 22→23 | `cat /tmp/$(echo I am user bandit23 \| md5sum \| cut -d ' ' -f 1)` |
| 23→24 | Ver `nivel23-copiar-clave.sh`. Nota: el script del cron solo ejecuta archivos cuyo dueño sea bandit23 |
| 24→25 | Ver `nivel24-pin.sh` (clave: `nc -N`; sin `-N` el nc de Ubuntu puede colgarse o perder la respuesta) |
| 25→26 | Local: `scp -P 2220 bandit25@$H:bandit26.sshkey b26.key; chmod 600 b26.key`; achicar terminal a ~5 líneas; `ssh -i b26.key -p 2220 bandit26@$H` → en `--More--` pulsar `v` → `:set shell=/bin/bash` → `:shell`. (Para leer la clave basta `:e /etc/bandit_pass/bandit26`) |
| 26→27 | En esa shell: `./bandit27-do cat /etc/bandit_pass/bandit27` |
| 27→28 | `git clone ssh://bandit27-git@$H:2220/home/bandit27-git/repo` (clave de bandit27) → `cat repo/README` |
| 28→29 | Repo `bandit28-git`: `git log -p` → la clave está en el commit anterior al que la reemplazó por `xxxxxxxxxx` |
| 29→30 | Repo `bandit29-git`: `git branch -a` → `git checkout dev` → `cat README.md` |
| 30→31 | Repo `bandit30-git`: `git tag` → `git show secret` |
| 31→32 | Repo `bandit31-git`: `echo 'May I come in?' > key.txt; git add -f key.txt; git commit -m key; git push origin master` → la clave aparece en la respuesta remota del push |
| 32→33 | En la uppershell: `$0` → abre `sh` como bandit33 → `cat /etc/bandit_pass/bandit33` |
| 33→34 | `cat README.txt` (fin del juego) |

## Tiempos de referencia (alumno promedio)
- 0→10: 30–40 min · 10→20: 40–50 min · 20→25: 30–40 min · 25→34: 45–60 min.
- La meta realista en clase es bandit20; los que ya conocen Linux llegan a bandit25.

## Puntos de atasco típicos (estar atento)
- **12→13** (capas de compresión): es el que más tiempo consume. Muéstralo en la pizarra con `file` en bucle.
- **13→14**: alumnos en Windows sin `scp`. Que usen Kali.
- **16→17**: `nmap -sV` tarda 1–2 min; algunos lo cancelan creyendo que se colgó.
- **23→24**: permisos de su carpeta temporal y del script, y esperar el minuto del cron.

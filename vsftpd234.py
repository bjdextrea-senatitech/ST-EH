#!/usr/bin/env python3
"""Emulador didáctico de vsFTPd 2.3.4 (CVE-2011-2523).
Si el USER contiene ':)' se abre una shell de root en 6200/tcp, como en el tarball troyanizado de 2011."""
import signal, socket, subprocess, threading
signal.signal(signal.SIGCHLD, signal.SIG_IGN)  # evita procesos zombi de socat

BANNER = b"220 (vsFTPd 2.3.4)\r\n"
backdoor_lock = threading.Lock()

def abrir_backdoor():
    # Igual que el original: escucha en 6200 y entrega /bin/sh (una conexión)
    with backdoor_lock:
        subprocess.Popen(["socat", "TCP-LISTEN:6200,reuseaddr", "EXEC:/bin/sh,stderr"])

def atender(c):
    f = c.makefile("rb")
    c.sendall(BANNER)
    user = None
    logged = False
    try:
        for raw in f:
            line = raw.decode("latin-1").strip()
            cmd, _, arg = line.partition(" ")
            cmd = cmd.upper()
            if cmd == "USER":
                user = arg
                if ":)" in arg:
                    abrir_backdoor()
                c.sendall(b"331 Please specify the password.\r\n")
            elif cmd == "PASS":
                if user in ("anonymous", "ftp"):
                    logged = True
                    c.sendall(b"230 Login successful.\r\n")
                else:
                    c.sendall(b"530 Login incorrect.\r\n")
            elif cmd == "SYST":
                c.sendall(b"215 UNIX Type: L8\r\n")
            elif cmd == "PWD" and logged:
                c.sendall(b'257 "/" is the current directory\r\n')
            elif cmd == "FEAT":
                c.sendall(b"211-Features:\r\n EPRT\r\n EPSV\r\n PASV\r\n UTF8\r\n211 End\r\n")
            elif cmd == "HELP":
                c.sendall(b"214 Help OK.\r\n")
            elif cmd == "QUIT":
                c.sendall(b"221 Goodbye.\r\n")
                break
            elif not logged:
                c.sendall(b"530 Please login with USER and PASS.\r\n")
            else:
                c.sendall(b"502 Command not implemented.\r\n")
    except OSError:
        pass
    finally:
        c.close()

s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 21))
s.listen(20)
while True:
    conn, _ = s.accept()
    threading.Thread(target=atender, args=(conn,), daemon=True).start()

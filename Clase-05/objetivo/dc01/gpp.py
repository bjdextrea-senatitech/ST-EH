# Cifra una contrasena como lo hacia Group Policy Preferences (clave AES publicada por Microsoft en MS-GPPREF)
import sys, base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
key = bytes.fromhex("4e9906e8fcb66cc9faf49310620ffee8f496e806cc057990209b09a433b66c1b")
p = padding.PKCS7(128).padder(); data = p.update(sys.argv[1].encode("utf-16-le")) + p.finalize()
e = Cipher(algorithms.AES(key), modes.CBC(b"\x00"*16)).encryptor()
print(base64.b64encode(e.update(data) + e.finalize()).decode().rstrip("="))

#!/bin/bash
# Contraseñas SMB (mquispe sigue la política "Empresa+Año+símbolo")
printf 'Qhapaq2025!\nQhapaq2025!\n'        | smbpasswd -a -s mquispe >/dev/null
printf 'Lm9#tRx2@wQp7vZk\nLm9#tRx2@wQp7vZk\n' | smbpasswd -a -s jdiaz  >/dev/null
exec smbd --foreground --no-process-group --debug-stdout

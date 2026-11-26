#!/bin/bash
echo 'QHAPAQ{59-voip-sip-extension-y-secreto-debil}' > /var/lib/asterisk/flag.txt
cat > /etc/asterisk/sip.conf <<SIP
[general]
context=default
allowguest=no
alwaysauthreject=no
bindport=5060
bindaddr=0.0.0.0
transport=udp
srvlookup=no

[1001]
type=friend
host=dynamic
secret=1001
context=interno

[1002]
type=friend
host=dynamic
secret=verano2025
context=interno

[2000]
type=friend
host=dynamic
secret=Qhapaq.Voip#2026
context=interno
SIP
cat > /etc/asterisk/extensions.conf <<EXT
[interno]
exten => 100,1,Answer()
 same => n,Playback(flag)
 same => n,Hangup()
EXT
chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk 2>/dev/null
exec asterisk -f -C /etc/asterisk/asterisk.conf

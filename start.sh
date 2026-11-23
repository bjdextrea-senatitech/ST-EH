#!/bin/bash
rm -f /var/run/xrdp/*.pid
mkdir -p /var/run/xrdp
xrdp-sesman
exec xrdp --nodaemon

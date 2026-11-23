# qs-ftp · réplica didáctica de vsftpd 2.3.4 con la puerta trasera de CVE-2011-2523
# (no es el binario real: es un emulador en Python que reproduce el banner y el backdoor ":)" -> shell en 6200/tcp)
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends python3 socat \
    && rm -rf /var/lib/apt/lists/* && mkdir -p /srv/ftp/pub
COPY vsftpd234.py /opt/vsftpd234.py
COPY flag.txt /root/flag.txt
COPY leeme.txt /srv/ftp/pub/leeme.txt
RUN chmod 600 /root/flag.txt
CMD ["python3", "/opt/vsftpd234.py"]

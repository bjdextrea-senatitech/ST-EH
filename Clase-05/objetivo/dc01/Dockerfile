FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends samba samba-ad-dc samba-ad-provision samba-dsdb-modules samba-vfs-modules krb5-user winbind smbclient ldb-tools tdb-tools python3-cryptography iproute2 && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /entrypoint.sh
COPY gpp.py /gpp.py
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

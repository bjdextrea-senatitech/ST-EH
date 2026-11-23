# qw-portal · Portal ERP Qhapaq (Flask) deliberadamente vulnerable
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-flask curl \
    && rm -rf /var/lib/apt/lists/*
COPY app /opt/app
WORKDIR /opt/app
EXPOSE 5000
CMD ["python3", "app.py"]

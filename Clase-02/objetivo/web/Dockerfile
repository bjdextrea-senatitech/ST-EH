FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends nginx \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log
COPY default.conf /etc/nginx/sites-available/default
COPY sitio/ /var/www/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

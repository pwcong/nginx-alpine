FROM alpine:3.13

LABEL maintainer="Pwcong <pwcong@foxmail.com>"

ENV VERSION_NGINX 1.21.1

RUN mkdir -p /root/build/nginx

WORKDIR /root/build/nginx

RUN apk -U upgrade \
  && apk add --no-cache wget gzip pcre zlib perl openssl libxslt gd geoip curl \
  && apk add --no-cache --virtual .build-deps build-base linux-headers pcre-dev zlib-dev perl-dev openssl-dev libxslt-dev gd-dev geoip-dev \
  && addgroup -g 101 -S nginx \
  && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
  && wget https://nginx.org/download/nginx-${VERSION_NGINX}.tar.gz -O /root/build/nginx.tar.gz \
  && tar -xvzf /root/build/nginx.tar.gz -C /root/build/nginx --strip-components=1 \
  && /root/build/nginx/configure \
  --prefix=/usr/lib/nginx \
  --sbin-path=/sbin/nginx \
  --pid-path=/var/pid/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --http-log-path=/dev/stdout \
  --error-log-path=/dev/stderr \
  --pid-path=/var/pid/nginx.pid \
  --user=nginx \
  --group=nginx \
  --with-file-aio \
  --with-pcre-jit \
  --with-threads \
  --with-poll_module \
  --with-select_module \
  --with-stream_ssl_module \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_dav_module \
  --with-http_degradation_module \
  --with-http_flv_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-mail_ssl_module \
  --with-http_mp4_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_slice_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-mail=dynamic \
  --with-stream=dynamic \
  --with-http_geoip_module=dynamic \
  --with-http_image_filter_module=dynamic \
  --with-http_xslt_module=dynamic \
  --with-http_perl_module=dynamic \
  --with-perl_modules_path=/etc/nginx/perl \
  && make \
  && make install \
  && apk del .build-deps \
  && rm -rf /root/build \
  && ln -s /usr/lib/nginx/modules /etc/nginx/modules

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]

FROM alpine:latest

ENV TWITCH_HOST=live.twitch.tv

RUN set -ex \
    && apk update --no-cache \
    && apk add --no-cache --virtual .gettext \
        gettext \
        curl \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    \
    && apk add --no-cache $runDeps \
    && curl -o /tmp/stat.xsl https://raw.githubusercontent.com/arut/nginx-rtmp-module/master/stat.xsl \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
    && apk add --no-cache \
        nginx \
        nginx-mod-rtmp \
        nginx-mod-http-geoip \
        nginx-mod-http-image-filter \
        nginx-mod-http-js \
        nginx-mod-http-xslt-filter \
        nginx-mod-stream-geoip \
        nginx-mod-stream-js \
        ffmpeg \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mv /tmp/stat.xsl /var/www/ \
    && mkdir -p /etc/nginx/conf.d

COPY base .

EXPOSE 1935 80

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "nginx" ]
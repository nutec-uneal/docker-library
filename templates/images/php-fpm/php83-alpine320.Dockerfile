FROM php:8.3.15-fpm-alpine3.20

LABEL org.opencontainers.image.authors="NUTEC UNEAL" \
    org.opencontainers.image.base.name="docker.io/library/php:8.3.15-fpm-alpine3.20" \
    org.opencontainers.image.documentation="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.source="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.url="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.vendor="NUTEC UNEAL"

ARG PUID=1024
ARG PGID=1024
ARG USER_NAME=app
ARG USER_GECOS=Application
ARG GROUP_NAME=${USER_NAME}
ARG DOCKER_PHPEXT_SRCBIN=https://github.com/mlocati/docker-php-extension-installer/releases/download/2.6.0/install-php-extensions
ARG PHP_DIR_CONF_DEFAULT=/usr/local/etc/php
ARG PHP_DIR_CONF_FPM_DEFAULT=/usr/local/etc/php-fpm
ARG PHP_DIR_CONF=/etc/php
ARG PHP_DIR_CONF_FPM=/etc/php-fpm
ARG PHP_DIR_PID=/run/php
ARG PHP_DIR_LOG=/var/log/php
ARG APP_DIR=/var/www/html


WORKDIR /
USER root

ADD ${DOCKER_PHPEXT_SRCBIN} /usr/local/bin

RUN apk --update-cache add --no-cache fcgi \
    && (grep "^${USER_NAME}:" /etc/passwd &> /dev/null && deluser ${USER_NAME} || true) \
    && (grep "^${GROUP_NAME}:" /etc/group &> /dev/null && delgroup ${GROUP_NAME} || true) \
    && addgroup -g ${PGID} ${GROUP_NAME} \
    && adduser -u ${PUID} -G ${GROUP_NAME} -g "${USER_GECOS}" -s /bin/sh -D ${USER_NAME} \
    && mkdir ${PHP_DIR_CONF_FPM_DEFAULT} ${PHP_DIR_CONF} ${PHP_DIR_CONF_FPM} \
    ${PHP_DIR_PID} ${PHP_DIR_LOG} \
    && mv /usr/local/etc/php-fpm.* -t ${PHP_DIR_CONF_FPM_DEFAULT} \
    && chmod +x /usr/local/bin/install-php-extensions

COPY ./*.sh /

RUN chown -R ${USER_NAME}:${GROUP_NAME} ${PHP_DIR_CONF} ${PHP_DIR_CONF_FPM} \
    ${PHP_DIR_PID} ${PHP_DIR_LOG} ${APP_DIR}\
    && chmod 755 /usr/local/bin/install-php-extensions \
    && chmod -R 755 ${PHP_DIR_CONF_DEFAULT} ${PHP_DIR_CONF_FPM_DEFAULT} /*.sh \
    && chmod -R 750 ${PHP_DIR_CONF} ${PHP_DIR_CONF_FPM} ${PHP_DIR_PID} \
    ${PHP_DIR_LOG} ${APP_DIR} \
    && rm -rf /tmp/*
ARG IMAGE_BASE=ghcr.io/nutec-uneal/php:8.3-fpm-alpine3.20
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.description="LDAP Account Manager" \
    org.opencontainers.image.title="LAM" \
    org.opencontainers.image.version="8.9-1"

ARG USER_NAME=app
ARG GROUP_NAME=${USER_NAME}
ARG LAM_SRCBIN=https://github.com/LDAPAccountManager/lam/releases/download/8.9/ldap-account-manager-8.9.tar.bz2
ARG LAM_DIR_APP_SRC=/usr/share/lam
ARG LAM_DIR_APP=/var/www/html
ARG LAM_DIR_DATA=/var/lib/lam
ARG LAM_DIR_LOG=/var/log/lam


ENV PHP_INI_SCAN_DIR=/etc/php/conf.d

WORKDIR /
USER root

ADD ${LAM_SRCBIN} ${LAM_DIR_APP_SRC}/
COPY scripts/*.sh /

RUN install-php-extensions \
    gd \
    gettext \
    gmp \
    intl \
    ldap \
    pdo_mysql \
    opcache \
    xdebug \
    xmlrpc \
    zip \
    && mkdir ${LAM_DIR_DATA} ${LAM_DIR_LOG} \
    && chown -R ${USER_NAME}:${GROUP_NAME} ${LAM_DIR_DATA} ${LAM_DIR_LOG} \
    && chmod -R 755 ${LAM_DIR_APP_SRC} /*.sh \
    && chmod -R 750 ${LAM_DIR_DATA} ${LAM_DIR_LOG}


WORKDIR ${LAM_DIR_APP}
USER ${USER_NAME}

EXPOSE 9000

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "start" ]
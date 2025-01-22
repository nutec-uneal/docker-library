ARG IMAGE_BASE=ghcr.io/nutec-uneal/php:8.3-fpm-alpine3.20
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.description="Helpdesk and IT assets" \
    org.opencontainers.image.title="GLPI" \
    org.opencontainers.image.version="10.0.17-1"

ARG USER_NAME=app
ARG USER_GECOS=Application
ARG GLPI_SRCBIN=https://github.com/glpi-project/glpi/releases/download/10.0.17/glpi-10.0.17.tgz
ARG GLPI_DIR_APP_SRC=/usr/share/glpi
ARG GLPI_DIR_CONF_DEFAULT=/usr/local/etc/glpi
ARG GLPI_DIR_APP=/var/www/html
ARG GLPI_DIR_CONF=/etc/glpi
ARG GLPI_DIR_DATA=/var/lib/glpi
ARG GLPI_DIR_LOG=/var/log/glpi


ENV PHP_INI_SCAN_DIR=/etc/php/conf.d

WORKDIR /
USER root

ADD ${GLPI_SRCBIN} ${GLPI_DIR_APP_SRC}/
COPY files/app ${GLPI_DIR_APP_SRC}
COPY files/conf/* ${GLPI_DIR_CONF_DEFAULT}/
COPY scripts/*.sh /

RUN install-php-extensions \
    apcu \
    bz2 \
    gd \
    exif \
    intl \
    ldap \
    mysqli \
    opcache \
    xdebug \
    xmlrpc \
    zip \
    && mkdir ${GLPI_DIR_CONF} ${GLPI_DIR_DATA} ${GLPI_DIR_LOG} \
    && chown -R ${USER_NAME}:${GROUP_NAME} ${GLPI_DIR_CONF} ${GLPI_DIR_DATA} ${GLPI_DIR_LOG} \
    && chmod -R 755 ${GLPI_DIR_APP_SRC} ${GLPI_DIR_CONF_DEFAULT} /*.sh \
    && chmod -R 750 ${GLPI_DIR_CONF} ${GLPI_DIR_DATA} ${GLPI_DIR_LOG}


WORKDIR ${GLPI_DIR_APP}
USER ${USER_NAME}

EXPOSE 9000

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["start"]
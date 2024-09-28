FROM php:8.2-fpm-alpine3.20

ARG PUID=1024
ARG PGID=1024
ARG USER_NAME=app
ARG USER_GECOS=Application
ARG GROUP_NAME=${USER_NAME}
ARG PHP_EXT_SOURCE_URI=https://github.com/mlocati/docker-php-extension-installer/releases/download/2.4.0/install-php-extensions
ARG PHP_CONF=/etc/php
ARG PHP_CONF_FPM=/etc/php-fpm
ARG PHP_DIR_LOG=/var/log/php
ARG PHP_CONF_DEFAULT=/usr/local/etc/php
ARG PHP_CONF_FPM_DEFAULT=/usr/local/etc/php-fpm
ARG PHP_DIR_PID=/run/php
ARG GLPI_SOURCE_URI=https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz
ARG GLPI_APP=/var/www/html
ARG GLPI_APP_DEFAULT=/usr/share/glpi
ARG GLPI_DIR_CONF=/etc/glpi
ARG GLPI_DIR_DATA=/var/lib/glpi
ARG GLPI_DIR_LOG=/var/log/glpi

ENV PHP_INI_SCAN_DIR=${PHP_CONF}/conf.d


WORKDIR /
USER root

ADD ${PHP_EXT_SOURCE_URI} /usr/local/bin
ADD ${GLPI_SOURCE_URI} ${GLPI_APP_DEFAULT}/

RUN apk add --no-cache fcgi \
    && (grep "^${USER_NAME}:" /etc/passwd &> /dev/null && deluser ${USER_NAME} || true) \
    && (grep "^${GROUP_NAME}:" /etc/group &> /dev/null && delgroup ${GROUP_NAME} || true) \
    && addgroup -g ${PGID} ${GROUP_NAME} \
    && adduser -u ${PUID} -G ${GROUP_NAME} -g "${USER_GECOS}" -s /bin/sh -D ${USER_NAME} \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions apcu bz2 gd exif intl ldap mysqli opcache xdebug xmlrpc zip \
    && mkdir ${GLPI_DIR_CONF} ${GLPI_DIR_DATA} ${GLPI_DIR_LOG} ${PHP_DIR_PID} \
    ${PHP_CONF} ${PHP_CONF_FPM} ${PHP_DIR_LOG} ${PHP_CONF_FPM_DEFAULT} \
    && mv /usr/local/etc/php-fpm.* -t ${PHP_CONF_FPM_DEFAULT} \
    && rm -rf /tmp/*

COPY conf/app/*.php ${GLPI_APP_DEFAULT}/
COPY scripts/*.sh /

RUN chown -R root:root ${PHP_CONF_DEFAULT} ${PHP_CONF_FPM_DEFAULT} ${GLPI_APP_DEFAULT} \
    && chmod -R 755 ${PHP_CONF_DEFAULT} ${PHP_CONF_FPM_DEFAULT} ${GLPI_APP_DEFAULT} /*.sh \
    && chown -R ${USER_NAME}:${GROUP_NAME} ${GLPI_DIR_CONF} ${GLPI_DIR_DATA} \
    ${GLPI_DIR_LOG} ${GLPI_APP} ${PHP_DIR_PID} ${PHP_CONF} ${PHP_CONF_FPM} ${PHP_DIR_LOG} \
    && chmod -R 750 ${GLPI_DIR_CONF} ${GLPI_DIR_DATA} ${GLPI_DIR_LOG} ${GLPI_APP} \
    ${PHP_DIR_PID} ${PHP_CONF} ${PHP_CONF_FPM} ${PHP_DIR_LOG}


USER ${USER_NAME}

EXPOSE 9000

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["start"]
FROM alpine:3.20.3

LABEL org.opencontainers.image.authors="NUTEC UNEAL" \
    org.opencontainers.image.base.name="docker.io/library/alpine:3.20.3" \
    org.opencontainers.image.description="The world's leading RADIUS server." \
    org.opencontainers.image.documentation="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.source="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.title="FreeRADIUS" \
    org.opencontainers.image.url="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.vendor="NUTEC UNEAL" \
    org.opencontainers.image.version="3.0.26-1" 

ARG PUID=1024
ARG PGID=1024
ARG USER_NAME=app
ARG USER_GECOS=Application
ARG GROUP_NAME=${USER_NAME}
ARG RADIUS_DIR_CONF_DEFAULT=/usr/local/etc/radius
ARG RADIUS_DIR_CONF=/etc/radius
ARG RADIUS_DIR_PID=/run/radius
ARG RADIUS_DIR_DATA=/var/lib/radius
ARG RADIUS_DIR_CACHE=/var/cache/radius
ARG RADIUS_DIR_LOG=/var/log/radius
ARG RADIUS_CLIENT_DIR_CONF_DEFAULT=/usr/local/etc/radiusclient
ARG RADIUS_CLIENT_DIR_CONF=/etc/radiusclient


WORKDIR /
USER root

RUN apk add --no-cache \
    openssl \
    freeradius \
    freeradius-eap \
    freeradius-ldap \
    freeradius-postgresql \
    freeradius-sqlite \
    freeradius-redis \
    freeradius-rest \
    freeradius-python3 \
    freeradius-utils \
    freeradius-checkrad \
    freeradius-client \
    net-snmp-tools \
    && (grep "^${USER_NAME}:" /etc/passwd &> /dev/null && deluser ${USER_NAME} || true) \
    && (grep "^${GROUP_NAME}:" /etc/group &> /dev/null && delgroup ${GROUP_NAME} || true) \
    && addgroup -g ${PGID} ${GROUP_NAME} \
    && adduser -u ${PUID} -G ${GROUP_NAME} -g "${USER_GECOS}" -s /bin/sh -D ${USER_NAME} \
    && mkdir -p ${RADIUS_DIR_CONF_DEFAULT} ${RADIUS_DIR_CONF} ${RADIUS_DIR_PID} \
    ${RADIUS_DIR_DATA} ${RADIUS_DIR_CACHE} ${RADIUS_DIR_LOG} ${RADIUS_CLIENT_DIR_CONF_DEFAULT} \
    && cp -r /etc/raddb/* ${RADIUS_DIR_CONF_DEFAULT} \
    && cp -r ${RADIUS_CLIENT_DIR_CONF}/* ${RADIUS_CLIENT_DIR_CONF_DEFAULT} \
    && rm -rf /etc/raddb ${RADIUS_DIR_CONF_DEFAULT}/sites-enabled/* \
    ${RADIUS_CLIENT_DIR_CONF}/* /tmp/*

COPY scripts/*.sh /

RUN chown -R root:root ${RADIUS_DIR_CONF_DEFAULT} ${RADIUS_CLIENT_DIR_CONF_DEFAULT} \
    && chown -R ${USER_NAME}:${GROUP_NAME} ${RADIUS_DIR_CONF} ${RADIUS_DIR_PID} \
    ${RADIUS_DIR_DATA} ${RADIUS_DIR_CACHE} ${RADIUS_DIR_LOG} ${RADIUS_CLIENT_DIR_CONF} \
    && chmod -R 755 ${RADIUS_DIR_CONF_DEFAULT} ${RADIUS_DIR_PID} ${RADIUS_CLIENT_DIR_CONF_DEFAULT} /*.sh \
    && chmod -R 750 ${RADIUS_DIR_CONF} ${RADIUS_DIR_DATA} ${RADIUS_DIR_CACHE} \
    ${RADIUS_DIR_LOG} ${RADIUS_CLIENT_DIR_CONF}


USER ${USER_NAME}

EXPOSE 1812-1813/udp
EXPOSE 1812-1813/tcp

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "start" ]
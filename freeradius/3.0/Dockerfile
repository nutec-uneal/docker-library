FROM alpine:3.22.0

LABEL org.opencontainers.image.authors="NUTEC UNEAL" \
    org.opencontainers.image.url="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.documentation="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.source="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.version="3.0.27-1" \
    org.opencontainers.image.vendor="NUTEC UNEAL" \
    org.opencontainers.image.title="FreeRADIUS" \
    org.opencontainers.image.description="The world's leading RADIUS server." 


ARG PUID=1024
ARG PGID=1024
ARG USER_NAME=app
ARG USER_GECOS=Application
ARG GROUP_NAME=${USER_NAME}
ARG RADIUS_DIR_PID=/run/radius
ARG RADIUS_DIR_CONF=/etc/raddb
ARG RADIUS_DIR_DATA=/var/lib/radius
ARG RADIUS_DIR_CACHE=/var/cache/radius
ARG RADIUS_DIR_LOG=/var/log/radius
ARG RADIUS_CLIENT_DIR_CONF=/etc/radiusclient

WORKDIR /
USER root

COPY scripts/*.sh /

RUN apk --update-cache add --no-cache \
    openssl \
    freeradius \
    freeradius-checkrad \
    freeradius-dhcp \
    freeradius-eap \
    freeradius-krb5 \
    freeradius-ldap \
    freeradius-mysql \
    freeradius-pam \
    freeradius-postgresql \
    freeradius-redis \
    freeradius-rest \
    freeradius-sqlite \
    freeradius-utils \
    freeradius-client \
    net-snmp-tools \
    && addgroup -g ${PGID} ${GROUP_NAME} \
    && adduser -g "${USER_GECOS}" -u ${PUID} -G ${GROUP_NAME} -s /bin/sh -D -H ${USER_NAME} \
    && rm -rf /var/lib/radiusd /var/cache/radiusd ${RADIUS_DIR_LOG}/* \
    && mkdir -p ${RADIUS_DIR_PID} \
    ${RADIUS_DIR_DATA} \
    ${RADIUS_DIR_CACHE} \
    && chown -R ${USER_NAME}:${GROUP_NAME} ${RADIUS_DIR_PID} \
    ${RADIUS_DIR_CONF} \
    ${RADIUS_DIR_DATA} \
    ${RADIUS_DIR_CACHE} \
    ${RADIUS_DIR_LOG} \
    ${RADIUS_CLIENT_DIR_CONF} \
    && chmod -R 755 ${RADIUS_DIR_PID} /*.sh \
    && chmod -R 750 ${RADIUS_DIR_CONF} \
    ${RADIUS_DIR_DATA} \
    ${RADIUS_DIR_CACHE} \
    ${RADIUS_DIR_LOG} \
    ${RADIUS_CLIENT_DIR_CONF}

WORKDIR ${RADIUS_DIR_CONF}
USER ${USER_NAME}

EXPOSE 1812-1813/udp
EXPOSE 1812-1813/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "-P" ]

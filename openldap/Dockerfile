FROM alpine:3.20.3

LABEL org.opencontainers.image.authors="NUTEC UNEAL" \
    org.opencontainers.image.base.name="docker.io/library/alpine:3.20.3" \
    org.opencontainers.image.description="An open source Lightweight Directory Access Protocol (LDAP)." \
    org.opencontainers.image.documentation="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.source="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.title="OpenLDAP" \
    org.opencontainers.image.url="https://github.com/nutec-uneal/docker-library" \
    org.opencontainers.image.vendor="NUTEC UNEAL" \
    org.opencontainers.image.version="2.6.8-1"

ARG PUID=1024
ARG PGID=1024
ARG USER_NAME=app
ARG USER_GECOS=Application
ARG GROUP_NAME=${USER_NAME}
ARG OPENLDAP_DIR_CONF_DEFAULT=/usr/local/etc/openldap
ARG OPENLDAP_DIR_CONF=/etc/openldap
ARG OPENLDAP_DIR_PID=/run/openldap
ARG OPENLDAP_DIR_DATA=/var/lib/openldap
ARG OPENLDAP_DIR_CACHE=/var/cache/openldap
ARG OPENLDAP_DIR_LOG=/var/log/openldap


WORKDIR /
USER root

RUN apk --update-cache add --no-cache \
    openldap \
    openldap-overlay-all \
    openldap-back-mdb \
    openldap-clients \  
    && (grep "^${USER_NAME}:" /etc/passwd &> /dev/null && deluser ${USER_NAME} || true) \
    && (grep "^${GROUP_NAME}:" /etc/group &> /dev/null && delgroup ${GROUP_NAME} || true) \
    && addgroup -g ${PGID} ${GROUP_NAME} \
    && adduser -u ${PUID} -G ${GROUP_NAME} -g "${USER_GECOS}" -s /bin/sh -D ${USER_NAME} \
    && mkdir -p ${OPENLDAP_DIR_CONF_DEFAULT} ${OPENLDAP_DIR_PID} ${OPENLDAP_DIR_DATA} \
    ${OPENLDAP_DIR_CACHE} ${OPENLDAP_DIR_LOG} \
    && cp -r ${OPENLDAP_DIR_CONF}/* ${OPENLDAP_DIR_CONF_DEFAULT} \
    && rm -rf ${OPENLDAP_DIR_CONF}/* /tmp/*

COPY scripts/*.sh /
COPY examples/*-example.ldif ${OPENLDAP_DIR_CONF_DEFAULT}/

RUN chown -R root:root ${OPENLDAP_DIR_CONF_DEFAULT} \
    && chown -R ${USER_NAME}:${GROUP_NAME} ${OPENLDAP_DIR_CONF} ${OPENLDAP_DIR_PID} \
    ${OPENLDAP_DIR_DATA} ${OPENLDAP_DIR_CACHE} ${OPENLDAP_DIR_LOG} \
    && chmod -R 755 ${OPENLDAP_DIR_CONF_DEFAULT} ${OPENLDAP_DIR_PID} /*.sh \
    && chmod -R 750 ${OPENLDAP_DIR_CONF} ${OPENLDAP_DIR_DATA} ${OPENLDAP_DIR_CACHE} \
    ${OPENLDAP_DIR_LOG}


WORKDIR ${OPENLDAP_DIR_CONF}
USER ${USER_NAME}

EXPOSE 389
EXPOSE 636

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "start" ]
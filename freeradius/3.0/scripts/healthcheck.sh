#!/bin/sh

: ${HEALTH_HOST:='127.0.0.1'}
: ${HEALTH_PORT:='11812'}
: ${HEALTH_PROTOCOL:='udp'}
: ${HEALTH_USER:=''}
: ${HEALTH_PASSWORD:=''}
: ${HEALTH_PASSWORD_FILE:=''}
: ${HEALTH_TYPE:='pap'}
: ${HEALTH_NAS_PORT_NUMBER:='0'}
: ${HEALTH_SECRET:=''}
: ${HEALTH_SECRET_FILE:=''}

password="$HEALTH_PASSWORD"
secret="$HEALTH_SECRET"

if [[ -n "$HEALTH_PASSWORD_FILE" ]]; then
    password=$(head -n 1 "$HEALTH_PASSWORD_FILE")
fi

if [[ -n "$HEALTH_SECRET_FILE" ]]; then
    secret=$(head -n 1 "$HEALTH_SECRET_FILE")
fi

radtest \
    -P "$HEALTH_PROTOCOL" \
    -t "$HEALTH_TYPE" \
    "$HEALTH_USER" \
    "$password" \
    "$HEALTH_HOST:$HEALTH_PORT" \
    "$HEALTH_NAS_PORT_NUMBER" \
    "$secret" &> /dev/null

if [[ "$?" -eq 0 ]]; then
    echo "RADIUS connection successful."
else
    echo "RADIUS connection unsuccessful: Host ($HEALTH_HOST), Port ($HEALTH_PORT), User ($HEALTH_USER)."
fi

exit $?

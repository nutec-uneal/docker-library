#!/bin/sh

: ${PERSISTENT_MODE:=''}

if [[ "$#" -eq 0 || "${1#-}" != "$1" ]]; then
    set -- radiusd "$@"
fi

if [[ "$1" == 'radiusd' ]]; then
    shift

    if [[ -z "$PERSISTENT_MODE" ]]; then
        exec radiusd -f "$@"
    fi

    while true; do
        radiusd -f "$@"

        if [[ "$?" -ne 0 ]]; then
            exit $?
        fi

        echo "$(date +"[%Y-%m-%d %H:%M:%S %z]") The program will reload in $PERSISTENT_MODE seconds."
        sleep "$PERSISTENT_MODE"
        echo "$(date +"[%Y-%m-%d %H:%M:%S %z]") Program reloaded..."
    done
elif [[ "$1" == 'inspectmode' ]]; then
    echo "$(date +"[%Y-%m-%d %H:%M:%S %z]") [INSPECTION MODE]"

    while true; do
        sleep 120
    done

    exit 0
fi

exec "$@"

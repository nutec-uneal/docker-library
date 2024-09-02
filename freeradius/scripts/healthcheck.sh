#!/bin/sh

: ${HEALTHC_HOST:="localhost"}
: ${HEALTHC_PORT:="11812"}
: ${HEALTHC_NAS_PORT_NUMBER:="0"}


print_help() {
    echo "Usage: $0"
    echo "Usage: $0 --help"
    echo
    
    echo "Variables:"
    echo "  HEALTHC_HOST: server ip/host (default: localhost)."
    echo "  HEALTHC_PORT: server port (default: 11812)."
    echo "  HEALTHC_USER: connection user."
    echo "  HEALTHC_PASSWORD: user password."
    echo "  HEALTHC_PASSWORD_FILE: user password file."
    echo "  HEALTHC_TYPE: authentication method."
    echo "      Options: pap, chap, mschap, eap-md5 ou [EMPTY (default)]."
    echo "  HEALTHC_NAS_PORT_NUMBER: NAS port number (default: 0)."
    echo "  HEALTHC_SECRET: client secret."
    echo "  HEALTHC_SECRET_FILE: client secret file."
    echo "  Note: \"_FILE\" versions are mutually exclusive with their common versions"
    echo "      and have higher priority, in addition to not requiring shell escape characters."
}

print_info() {
    echo "$(date +"[%d/%m/%Y %H:%M:%S %z INF]") $1"
}

print_info_short(){
    echo "$1"
}

print_err() {
    echo "$(date +"[%d/%m/%Y %H:%M:%S %z ERR]") $1" >&2
}

print_err_short(){
    echo "$1" >&2
}

run_test(){
    health_password="$HEALTHC_PASSWORD"
    
    if [[ -n "$HEALTHC_PASSWORD_FILE" ]]; then
        health_password=$(head -n 1 "$HEALTHC_PASSWORD_FILE")
    fi
    
    health_secret="$HEALTHC_SECRET"
    
    if [[ -n "$HEALTHC_SECRET_FILE" ]]; then
        health_secret=$(head -n 1 "$HEALTHC_SECRET_FILE")
    fi
    
    params="$([[ ! -z "$HEALTHC_TYPE" ]] && echo "-t $HEALTHC_TYPE")"
    params="$params $HEALTHC_USER $health_password"
    params="$params $HEALTHC_HOST:$HEALTHC_PORT"
    params="$params $HEALTHC_NAS_PORT_NUMBER $health_secret"
    
    (
        radtest $params &> /dev/null \
        && print_info_short "Radius: successful connection"
    ) || \
    (
        print_err_short "Radius: Unsuccessful connection - Host/Port/Type/User/NAS_PORT ($HEALTHC_HOST, $HEALTHC_PORT, $HEALTHC_TYPE, $HEALTHC_USER, $HEALTHC_NAS_PORT_NUMBER)" \
        && exit 1
    )
}


if [[ "$#" -eq 0 ]]; then
    run_test
elif [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    print_help
else
    print_err_short "Command not understood. Use --help."
    exit 1
fi

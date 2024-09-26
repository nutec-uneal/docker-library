#!/bin/sh

: ${HEALTHC_HOST:="ldap://localhost"}


print_help() {
    echo "Usage: $0"
    echo "Usage: $0 --help"
    echo
    
    echo "Variables:"
    echo "  HEALTHC_HOST:  (default: ldap://localhost)"
    echo "  HEALTHC_BIND_DN: DESC1"
    echo "  HEALTHC_BIND_PASSWORD: DESC1"
    echo "  HEALTHC_BIND_PASSWORD_FILE: DESC1"
    echo "  HEALTHC_BASE_DN: DESC1"
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
    h_password=$([[ -n "$HEALTHC_BIND_PASSWORD_FILE" ]] \
        && head -n 1 "$HEALTHC_BIND_PASSWORD_FILE" \
        || echo "$HEALTHC_BIND_PASSWORD")
    
    h_basedn=$([[ -n "$HEALTHC_BASE_DN" ]] \
        && echo "$HEALTHC_BASE_DN" \
        || echo "$HEALTHC_BIND_DN")
    
    (
        ldapsearch -H "$HEALTHC_HOST" -D "$HEALTHC_BIND_DN" -w "$h_password" -b "$h_basedn" &> /dev/null \
        && print_info_short "LDAP: successful connection"
    ) || \
    (
        print_err_short "LDAP: Unsuccessful connection - Host/BindDN/BaseDN ($HEALTHC_HOST, $HEALTHC_BIND_DN, $h_basedn)" \
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

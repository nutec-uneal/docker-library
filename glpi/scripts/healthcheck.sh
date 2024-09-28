#!/bin/sh

: ${HEALTHC_HOST:="localhost"}
: ${HEALTHC_PORT:="9000"}
: ${HEALTHC_SCRIPT_FILENAME:="index.php"}
: ${HEALTHC_REQUEST_METHOD:="GET"}


print_help() {
    echo "Use: $0"
    echo "Use: $0 --help"
    echo
    
    echo "Variables:"
    echo "  HEALTHC_HOST: server ip/host (default: localhost)."
    echo "  HEALTHC_PORT: server port (default: 9000)."
    echo "  HEALTHC_SCRIPT_FILENAME: script filename (default: index.php)."
    echo "  HEALTHC_REQUEST_METHOD: HTTP method (default: GET)."
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
    (
        SCRIPT_FILENAME="$HEALTHC_SCRIPT_FILENAME" \
        REQUEST_METHOD="$HEALTHC_REQUEST_METHOD" \
        cgi-fcgi -bind -connect "$HEALTHC_HOST:$HEALTHC_PORT" &> /dev/null \
        && print_info_short "FastCGI: successful connection."
    ) || \
    (
        print_err_short "FastCGI: unsuccessful connection - HOST($HEALTHC_HOST), PORT($HEALTHC_PORT), FILENAME($HEALTHC_SCRIPT_FILENAME), METHOD($HEALTHC_REQUEST_METHOD)." \
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
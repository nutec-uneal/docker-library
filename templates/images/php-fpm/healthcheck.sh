#!/bin/sh

: ${HEALTHC_HOST:="localhost"}
: ${HEALTHC_PORT:="9000"}
: ${HEALTHC_SFILENAME:="index.php"}
: ${HEALTHC_REQMETHOD:="GET"}


print_help() {
    echo "Usage: $0"
    echo "Usage: $0 --help"
    echo
    
    echo "Variables:"
    echo "  HEALTHC_HOST: server ip/host (default: localhost)."
    echo "  HEALTHC_PORT: server port (default: 9000)."
    echo "  HEALTHC_SFILENAME: script filename (default: index.php)."
    echo "  HEALTHC_REQMETHOD: HTTP method (default: GET)."
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
    SCRIPT_FILENAME="$HEALTHC_SFILENAME"
    REQUEST_METHOD="$HEALTHC_REQMETHOD"
    
    (
        cgi-fcgi -bind -connect "$HEALTHC_HOST:$HEALTHC_PORT" &> /dev/null \
        && print_info_short "FastCGI: successful connection."
    ) || \
    (
        print_err_short "FastCGI: unsuccessful connection - HOST($HEALTHC_HOST), PORT($HEALTHC_PORT), FILENAME($HEALTHC_SFILENAME), METHOD($HEALTHC_REQMETHOD)." \
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
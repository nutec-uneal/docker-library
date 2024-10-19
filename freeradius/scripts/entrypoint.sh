#!/bin/sh

: ${RADIUS_CONF_DIR:="/etc/radius"}
: ${RADIUS_DICT_DIR:="/usr/share/freeradius"}
# [EMPTY/any other] (disable), INFO, DEBUG (-x, -xx), VERBOSE (-X, -tfxxl stdout)
: ${RADIUS_LOG_LEVEL:="INFO"}
# stdout, file_path
: ${RADIUS_LOG_OUTPUT:="stdout"}
: ${RADIUS_CLIENT_CONF_DIR:="/etc/radiusclient"}


default_radius_conf="/usr/local/etc/radius"
default_radius_dicts="/usr/share/freeradius"
default_radiusclient_conf="/usr/local/etc/radiusclient"

service_name="FreeRADIUS"
none_value="__NONE__"


print_help() {
    echo "Usage: $0 {Commands | --help}"
    echo
    
    echo "Commands:"
    echo "  start [-p [<waitTime>]]"
    echo "      Start the application."
    echo "  inspectormode"
    echo "      Runs inspector mode keeping the container running"
    echo "      without loading the application."
    echo "  resume"
    echo "      Print some information."
    echo "  copy <pathDest>"
    echo "      Copy default settings to a specified directory."
    echo
    
    echo "Options:"
    echo "  -p [<waitTime>]: activates persistent mode."
    echo "      In this mode, if the process ends gracefully,"
    echo "      it will start again, respecting a pause of <waitTime> seconds."
    echo "      Default: waitTime=0."
    echo "  <pathDest>: destination folder."
    echo
    
    echo "Variables:"
    echo "  RADIUS_CONF_DIR: Radius configuration directory (default: /etc/radius)."
    echo "  RADIUS_DICT_DIR: Radius dictionary directory (default: /usr/share/freeradius)."
    echo "  RADIUS_LOG_LEVEL: Daemon log level."
    echo "      INFO, DEBUG, VERBOSE, [any other to disable] (default: INFO)."
    echo "  RADIUS_LOG_OUTPUT: Log output. Options: stdout, file path (default: stdout)."
    echo "      In VERBOSE mode it is automatically set to LOG_OUTPUT=stdout."
    echo "  RADIUS_CLIENT_CONF_DIR: Radiusclient configuration directory (default: /etc/radiusclient)."
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

print_resume(){
    echo "[Default Dirs]"
    echo "  - Radius: $default_radius_conf"
    echo "  - Radius Dictionaries: $default_radius_dicts"
    echo "  - Radiusclient: $default_radiusclient_conf"
    echo
    echo "[Recommended Dirs]"
    echo "  - /etc/radius"
    echo "  - /etc/radiusclient"
    echo "  - /run/radius"
    echo "  - /var/lib/radius"
    echo "  - /var/log/radius"
    echo "  - /var/cache/radius"
}

get_shell_options(){
    local i=1
    local s_args="$1"
    local end_loop="$2"
    
    set -- $s_args
    shift
    
    while [[ "$i" -le "$end_loop" ]]; do
        if [[ "$((i + 1))" -gt "$end_loop" || "$2" == "-?" ]]; then
            shell_cmd_options="$shell_cmd_options $1 $none_value"
            i="$(($i + 1))"
            shift
        else
            shell_cmd_options="$shell_cmd_options $1 $2"
            i="$(($i + 2))"
            shift
            shift
        fi
    done
}

get_options_app(){
    local opt=
    local opt_arg=
    
    while getopts ":p:" opt_read $1; do
        opt="$opt_read"
        opt_arg="$OPTARG"
        
        case "$opt" in
            "p")
                app_persistent_mode="yes"
                app_persistent_mode_wait_time=$([[ "$OPTARG" != "$none_value" ]] && echo "$OPTARG" || echo "0")
            ;;
            *)
                print_err_short "\"$opt_arg\" option not found."
                exit 1
            ;;
        esac
    done
}

check_dir_is_empty(){
    local dir_path="$1"
    
    if [[ ! -d "$dir_path" || ! -r "$dir_path" ]]; then
        print_err "\"$dir_path\" is not a directory or cannot be read."
        exit 1
    fi
    
    dir_is_empty=$([[ -z "$(ls -A "$1")" ]] && echo "yes")
}

cp_file(){
    local source_file="$1"
    local dest_dir="$2"
    
    if [[ ! -d "$dest_dir" || ! -w "$dest_dir" ]]; then
        print_err "\"$dest_dir\" is not a directory or is not writable."
        exit 1
    fi
    
    cp $source_file $dest_dir
    chmod -R 750 $dest_dir
}

cp_dir(){
    local source_dir="$1"
    local dest_dir="$2"
    
    if [[ ! -d "$dest_dir" || ! -w "$dest_dir" ]]; then
        print_err "\"$dest_dir\" is not a directory or is not writable."
        exit 1
    fi

    [[ "$3" == "folder" ]] && cp -r $source_dir $dest_dir || cp -r $source_dir/* $dest_dir
    chmod -R 750 $dest_dir
}

init_dirs_if_empty(){
    check_dir_is_empty "$RADIUS_CONF_DIR"
    [[ -n "$dir_is_empty" ]] \
    && print_info "RADIUS_CONF_DIR: \"$RADIUS_CONF_DIR\" empty, creating..." \
    && cp_dir "$default_radius_conf" "$RADIUS_CONF_DIR" \
    || print_info "RADIUS_CONF_DIR: \"$RADIUS_CONF_DIR\" [OK]."

    check_dir_is_empty "$RADIUS_CLIENT_CONF_DIR"
    [[ -n "$dir_is_empty" ]] \
    && print_info "RADIUS_CLIENT_CONF_DIR: \"$RADIUS_CLIENT_CONF_DIR\" empty, creating..." \
    && cp_dir "$default_radiusclient_conf" "$RADIUS_CLIENT_CONF_DIR" \
    || print_info "RADIUS_CLIENT_CONF_DIR: \"$RADIUS_CLIENT_CONF_DIR\" [OK]."
}

mode_inspector(){
    print_info "INSPECTION MODE."
    
    while true; do
        sleep 120;
    done
}

mode_copy(){
    print_info_short "Copying to \"$1\":"
    
    print_info_short "  - $default_radius_conf"
    cp_dir "$default_radius_conf" "$1" "folder"

    print_info_short "  - $default_radiusclient_conf"
    cp_dir "$default_radiusclient_conf" "$1" "folder"

    print_info_short "  - $default_radius_dicts"
    cp_dir "$default_radius_dicts" "$1" "folder"
}

mode_app(){
    entrypoint_cmd="radiusd -f -P -d $RADIUS_CONF_DIR -D $RADIUS_DICT_DIR"
    
    print_info "Starting $service_name..."
    print_info "Checking directories..."
    
    init_dirs_if_empty
    
    if [[ "$RADIUS_LOG_LEVEL" == "VERBOSE" ]]; then
        entrypoint_cmd="$entrypoint_cmd -X";
    elif [[ "$RADIUS_LOG_LEVEL" == "DEBUG" ]]; then
        entrypoint_cmd="$entrypoint_cmd -x -l $RADIUS_LOG_OUTPUT"
    elif [[ "$RADIUS_LOG_LEVEL" == "INFO" ]]; then
        entrypoint_cmd="$entrypoint_cmd -l $RADIUS_LOG_OUTPUT"
    fi

    print_info "Command executed: \"$entrypoint_cmd\""
    
    if [[ -z "$app_persistent_mode" ]]; then
        $entrypoint_cmd
    else
        local has_error=
        
        while [[ -z $has_error ]]; do
            $entrypoint_cmd || has_error="yes"
            
            if [[ -z $has_error ]]; then
                print_info "Reloading program..."
                
                if [[ "$app_persistent_mode_wait_time" -gt 0 ]]; then
                    print_info "Waiting $app_persistent_mode_wait_time seconds..."
                    sleep $app_persistent_mode_wait_time
                fi

                print_info "Program reloaded..."
            fi
        done
        
        print_err "Program exited with error. Closing..."
        exit 1
    fi
}


shell_cmd_type="$1"
shell_cmd_not_recognized=
shell_args="$@"
shell_end_loop=$(($# - 1))
shell_cmd_options=

app_persistent_mode=
app_persistent_mode_wait_time=0

if [[ "$#" -eq 1 && "$shell_cmd_type" != "start" && "$shell_cmd_type" != "copy" ]]; then
    if [[ "$shell_cmd_type" == "--help" ]]; then
        print_help
    elif [[ "$shell_cmd_type" == "inspectormode" ]]; then
        mode_inspector
    elif [[ "$shell_cmd_type" == "resume" ]]; then
        print_resume
    else
        shell_cmd_not_recognized="yes"
    fi
elif [[ "$shell_cmd_type" == "start" ]]; then
    get_shell_options "$shell_args" "$shell_end_loop"
    get_options_app "$shell_cmd_options"
    mode_app
elif [[ "$#" -eq 2 && "$shell_cmd_type" == "copy" ]]; then
    mode_copy $2
else
    shell_cmd_not_recognized="yes"
fi

if [[ -n "$shell_cmd_not_recognized" ]]; then
    print_err_short "Command not understood. Use --help."
    exit 1
fi

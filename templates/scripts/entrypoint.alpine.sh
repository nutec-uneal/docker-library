#!/bin/sh

service_name="MyApp"
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
    echo "  VAR_NAME1: DESC1"
    echo "  VAR_NAME2: DESC2"
    echo "  ...: ..."
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
    echo "print_resume....."
    echo "resume1....."
    echo "resume2....."
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
    echo "init_dir_if_empty.."
}

mode_inspector(){
    print_info "INSPECTION MODE."
    
    while true; do
        sleep 120;
    done
}

mode_copy(){
    echo "mode_copy.. dest -> $1"
}

mode_app(){
    entrypoint_cmd="echo "ok""
    
    print_info "Starting $service_name..."
    print_info "Checking directories..."
    
    init_dirs_if_empty
    
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

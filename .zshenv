#!/usr/bin/bash

function adjust_webcam() {
    if [[ $1 == 'exposure' ]]; then
        cameractrls2 -d "/dev/video2" -s exposure_time_absolute,50,800
        return;
    fi

    cameractrls -d "/dev/video2" -c "auto_exposure=manual_mode,exposure_time_absolute=200,backlight_compensation=1,white_balance_automatic=0,white_balance_temperature=2800"
}

function webcam() {
    adjust_webcam "$1"
}


hist_path="$HOME/.fzf_dir_hist"

# https://stackoverflow.com/questions/30023780/sorting-directory-contents-including-hidden-files-by-name-in-the-shell
pathsort(){
    input=$(cat)
    (
        awk '/^\..+\/$/' <<<"$input" | sort
        awk '/^[^.].+\/$/' <<<"$input" | sort
        awk '/^\..+[^/]$/' <<<"$input" | sort
        awk '/^[^.].+[^/]$/' <<<"$input" | sort
    ) | sed 's/\/$//'
}

function get_files_dirs {
    dir=$1
    local flags=${*:2}

    dirs=$(find "$dir" -maxdepth 1 -type d -printf '%f\n' 2> /dev/null | pathsort)
    files=$(find "$dir" -maxdepth 1 -type f -printf '%f\n' 2> /dev/null | pathsort)

    files_dirs=$(echo -e "$dirs\n$files")
    if [[ "$flags" == *"-d"* ]]; then
        files_dirs=$dirs
    fi

    if [ "$dir" != "/" ]; then
        files_dirs=$(echo "$files_dirs" | grep -v "${dir##*/}$")
    fi

    if [[ "$flags" == *"--full"* ]]; then
        # shellcheck disable=2001
        files_dirs=$(echo "$files_dirs" | sed "s|^|$dir/|")
    fi

    echo "$files_dirs"
}

# create array for storing history of directories
function get_files_dirs_lines {
    if [[ "$1" == "<--" ]]; then
        head -n -1 "$hist_path" > "$hist_path.tmp" && mv "$hist_path.tmp" "$hist_path"
        eval "$(tail -n 1 "$hist_path") --no-push"
        return
    fi

    local dir=${1//~/${HOME}}
    local prompt="$2"
    local flags=${*:3}

    if [[ "$flags" == *"--pop"* ]]; then
        if [[ $(wc -l < "$hist_path") -gt 1 ]]; then
            head -n -1 "$hist_path" > "$hist_path.tmp" && mv "$hist_path.tmp" "$hist_path"
        fi
        eval "$(tail -n 1 "$hist_path") --no-push"
        return
    fi

    if [[ "$flags" != *"--no-push"* ]]; then
        echo "get_files_dirs_lines '$1' '$2' ${*:3}" >> "$hist_path"
    fi

    files_dirs="$(get_files_dirs "$dir" --full)"
    if [[ "$flags" == *"-d"* ]]; then
        files_dirs="$(get_files_dirs "$dir" -d --full)"
    fi

    lines=$(grep -v "$PWD$" "$dir" 2>/dev/null || echo "$files_dirs")
    lines=$(echo "$lines" | grep -v "$prompt/$")

    if [ "$dir" != "$HOME/.zdirs" ]; then
        lines=$(echo -e "$lines\n<--")
    fi

    lines_prompt=$(echo -e "$prompt\n$lines")

    echo "$lines_prompt"
}

function fzf_dirs {
    rm "$hist_path"
    touch "$hist_path"

    get_files_dirs_lines "$HOME/.zdirs" "$HOME/.zdirs" | fzf --height=20% --no-sort \
        --header-lines=1 \
        --preview "get_files_dirs {}" \
        --bind "enter:reload(get_files_dirs_lines {} {} -d)" \
        --bind "ctrl-o:reload{get_files_dirs_lines {} {} -d --pop}" \
        --bind "ctrl-j:accept"
}

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

DEBIAN_PREVENT_KEYBOARD_CHANGES=yes
. "$HOME/.cargo/env"

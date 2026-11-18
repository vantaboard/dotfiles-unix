#!/usr/bin/env bash
# SketchyBar's volume_change event passes the output level in $INFO (0–100).
# Its CoreAudio listener reports mute as 0, so this script does not poll and
# does not start osascript.

if [[ "$SENDER" != "volume_change" ]]; then
  exit 0
fi

if [[ "${INFO:-0}" == "0" ]]; then
  sketchybar --set "$NAME" icon="󰖁" label="mute"
else
  sketchybar --set "$NAME" icon="󰕾" label="${INFO}%"
fi

#!/usr/bin/env bash
# Output volume via osascript (works without SwitchAudioSource).

vol="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo '?')"
muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo 'false')"

if [[ "$muted" == "true" ]]; then
  sketchybar --set "$NAME" icon="󰖁" label="mute"
else
  sketchybar --set "$NAME" icon="󰕾" label="${vol}%"
fi

#!/usr/bin/env bash
# Battery percentage + charging glyph (pmset).

info="$(pmset -g batt 2>/dev/null | grep -E 'InternalBattery|Battery' | head -1 || true)"
if [[ -z "$info" ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

pct="$(printf '%s' "$info" | grep -oE '[0-9]+%' | head -1 | tr -d '%')"
icon=""
if [[ "$info" == *"AC Power"* ]] || [[ "$info" == *"charging"* ]]; then
  icon=""
elif [[ -n "$pct" ]]; then
  if (( pct >= 80 )); then icon=""
  elif (( pct >= 60 )); then icon=""
  elif (( pct >= 40 )); then icon=""
  elif (( pct >= 20 )); then icon=""
  else icon=""
  fi
fi

sketchybar --set "$NAME" drawing=on icon="$icon" label="${pct:-?}%"

#!/usr/bin/env bash
# Show occupied AeroSpace workspaces only on the monitor they belong to.
# SketchyBar's display index matches NSScreen.screens (1-based). AeroSpace
# reports that same index as monitor-appkit-nsscreen-screens-id.

FG_DIM=0xff666666
FG_FOCUS=0xffeeeeee
BG_FOCUS=0xff083905

# Occupied workspaces, plus any workspace actually on screen (an empty
# focused workspace is not occupied). Two workspace queries replace
# list-windows --all, which laid out every window.
occupied="$(aerospace list-workspaces --monitor all --empty no \
  --format '%{workspace}|%{monitor-appkit-nsscreen-screens-id}|%{workspace-is-focused}' 2>/dev/null || true)"
visible="$(aerospace list-workspaces --monitor all --visible \
  --format '%{workspace}|%{monitor-appkit-nsscreen-screens-id}|%{workspace-is-focused}' 2>/dev/null || true)"
placement="$(printf '%s\n%s\n' "$occupied" "$visible" | awk -F'|' 'NF && !seen[$1]++')"
focused="$(awk -F'|' '$3 == "true" { print $1; exit }' <<<"$placement")"

shown() {
  awk -F'|' -v s="$1" '$1 == s { found = 1 } END { exit !found }' <<<"$placement"
}

display_for() {
  local display
  display="$(awk -F'|' -v s="$1" '$1 == s { print $2; exit }' <<<"$placement")"
  if [[ "$display" =~ ^[1-9][0-9]*$ ]]; then
    printf '%s' "$display"
  fi
}

show_space() {
  local sid="$1" display
  display="$(display_for "$sid")"
  if [[ -z "$display" ]]; then
    hide_space "$sid"
    return
  fi
  if [[ "$sid" == "$focused" ]]; then
    sketchybar --set "space.${sid}" \
      drawing=on \
      display="$display" \
      background.drawing=on \
      background.color="$BG_FOCUS" \
      label.color="$FG_FOCUS" \
      label.highlight_color="$FG_FOCUS" \
      label.padding_left=6 \
      label.padding_right=6
  else
    sketchybar --set "space.${sid}" \
      drawing=on \
      display="$display" \
      background.drawing=off \
      label.color="$FG_DIM" \
      label.highlight_color="$FG_DIM" \
      label.padding_left=6 \
      label.padding_right=6
  fi
}

hide_space() {
  sketchybar --set "space.${1}" \
    drawing=off \
    background.drawing=off \
    label.padding_left=0 \
    label.padding_right=0
}

for sid in 1 2 3 4 5 6 7 8 9; do
  if shown "$sid"; then
    show_space "$sid"
  else
    hide_space "$sid"
  fi
done

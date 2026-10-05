#!/usr/bin/env bash
# Show occupied AeroSpace workspaces only on the monitor they belong to.
# SketchyBar's display index matches NSScreen.screens (1-based). AeroSpace
# reports that same index as monitor-appkit-nsscreen-screens-id.

FG_DIM=0xff666666
FG_FOCUS=0xffeeeeee
BG_FOCUS=0xff083905

focused="$(aerospace list-workspaces --focused --format '%{workspace}' 2>/dev/null | head -1 || true)"
occupied="$(aerospace list-windows --all --format '%{workspace}' 2>/dev/null | awk 'NF && !seen[$0]++')"
visible="$(aerospace list-workspaces --monitor all --visible --format '%{workspace}' 2>/dev/null | awk 'NF && !seen[$0]++')"
# workspace|sketchybar-display
placement="$(aerospace list-workspaces --all --format '%{workspace}|%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null || true)"

in_list() {
  local sid="$1" list="$2"
  [[ -n "$list" ]] && grep -Fxq "$sid" <<<"$list"
}

display_for() {
  local sid="$1" line display
  line="$(awk -F'|' -v s="$sid" '$1 == s { print; exit }' <<<"$placement")"
  display="${line#*|}"
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
      label.padding_left=6 \
      label.padding_right=6
  else
    sketchybar --set "space.${sid}" \
      drawing=on \
      display="$display" \
      background.drawing=off \
      label.color="$FG_DIM" \
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
  if in_list "$sid" "$occupied" || in_list "$sid" "$visible"; then
    show_space "$sid"
  else
    hide_space "$sid"
  fi
done

# Workspaces outside 1–9 (for example after a move) appear only while occupied
# or visible, and only on the monitor that owns them.
if [[ -n "$occupied" || -n "$visible" ]]; then
  while IFS= read -r sid; do
    [[ -z "$sid" || "$sid" =~ ^[1-9]$ ]] && continue
    if ! in_list "$sid" "$occupied" && ! in_list "$sid" "$visible"; then
      continue
    fi
    sketchybar --add item "space.${sid}" left \
      --set "space.${sid}" \
        icon.drawing=off \
        label="${sid}" \
        click_script="aerospace workspace ${sid}" \
      >/dev/null 2>&1 || true
    show_space "$sid"
  done <<<"$(printf '%s\n%s\n' "$occupied" "$visible" | awk 'NF && !seen[$0]++')"
fi

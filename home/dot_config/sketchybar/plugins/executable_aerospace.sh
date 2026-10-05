#!/usr/bin/env bash
# Show only AeroSpace workspaces that contain windows.

FG_DIM=0xff666666
FG_FOCUS=0xffeeeeee
BG_FOCUS=0xff083905

focused="$(aerospace list-workspaces --focused --format '%{workspace}' 2>/dev/null | head -1 || true)"
occupied="$(aerospace list-windows --all --format '%{workspace}' 2>/dev/null | awk 'NF && !seen[$0]++')"

has_windows() {
  [[ -n "$occupied" ]] && grep -Fxq "$1" <<<"$occupied"
}

show_space() {
  local sid="$1"
  if [[ "$sid" == "$focused" ]]; then
    sketchybar --set "space.${sid}" \
      drawing=on \
      background.drawing=on \
      background.color="$BG_FOCUS" \
      label.color="$FG_FOCUS" \
      label.padding_left=6 \
      label.padding_right=6
  else
    sketchybar --set "space.${sid}" \
      drawing=on \
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
  if has_windows "$sid"; then
    show_space "$sid"
  else
    hide_space "$sid"
  fi
done

# Workspaces outside 1–9 (for example after a move) appear only while occupied.
if [[ -n "$occupied" ]]; then
  while IFS= read -r sid; do
    [[ "$sid" =~ ^[1-9]$ ]] && continue
    sketchybar --add item "space.${sid}" left \
      --set "space.${sid}" \
        icon.drawing=off \
        label="${sid}" \
        click_script="aerospace workspace ${sid}" \
      >/dev/null 2>&1 || true
    show_space "$sid"
  done <<<"$occupied"
fi

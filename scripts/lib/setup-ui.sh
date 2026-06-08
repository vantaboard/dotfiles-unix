#!/usr/bin/bash
# UI helpers: gum > fzf > bash select

setup_ui_backend() {
  if command -v gum >/dev/null 2>&1; then
    echo "gum"
  elif command -v fzf >/dev/null 2>&1; then
    echo "fzf"
  else
    echo "select"
  fi
}

# Multi-select from newline-separated options. Pre-selected lines passed as arg2 (newline-separated).
# Output: newline-separated selected items.
setup_ui_choose_multi() {
  local prompt="$1"
  local preselected="${2:-}"
  local options="$3"
  local backend
  backend="$(setup_ui_backend)"

  case "$backend" in
    gum)
      local -a args=(choose --no-limit --header "$prompt")
      if [[ -n "$preselected" ]]; then
        while IFS= read -r line; do
          [[ -n "$line" ]] && args+=(--selected "$line")
        done <<< "$preselected"
      fi
      printf '%s\n' "$options" | gum "${args[@]}"
      ;;
    fzf)
      local -a fzf_args=(--multi --prompt="$prompt ")
      if [[ -n "$preselected" ]]; then
        # fzf has no pre-select; pass via query hack - use --bind to start with selections
        printf '%s\n' "$options" | fzf "${fzf_args[@]}"
      else
        printf '%s\n' "$options" | fzf "${fzf_args[@]}"
      fi
      ;;
    select)
      echo "$prompt" >&2
      local -a opts=()
      while IFS= read -r line; do opts+=("$line"); done <<< "$options"
      local i choice selected=()
      for ((i=0; i<${#opts[@]}; i++)); do
        local mark=" "
        [[ "$preselected" == *"${opts[$i]}"* ]] && mark="x"
        printf '  [%s] %s\n' "$mark" "${opts[$i]}" >&2
      done
      echo "Enter numbers to toggle (space-separated), then press Enter. Empty line to finish:" >&2
      while read -r -p "> " choice; do
        [[ -z "$choice" ]] && break
        for num in $choice; do
          if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num < ${#opts[@]}+1 )); then
            local item="${opts[$((num-1))]}"
            if [[ " ${selected[*]} " == *" $item "* ]]; then
              selected=("${selected[@]/$item}")
            else
              selected+=("$item")
            fi
          fi
        done
        for ((i=0; i<${#opts[@]}; i++)); do
          local mark=" "
          [[ " ${selected[*]} " == *" ${opts[$i]} "* ]] && mark="x"
          printf '  [%s] %s\n' "$mark" "${opts[$i]}" >&2
        done
      done
      # Default to preselected if user picked nothing
      if [[ ${#selected[@]} -eq 0 && -n "$preselected" ]]; then
        printf '%s\n' "$preselected"
      else
        printf '%s\n' "${selected[@]}"
      fi
      ;;
  esac
}

setup_ui_confirm() {
  local prompt="$1"
  local backend
  backend="$(setup_ui_backend)"
  case "$backend" in
    gum) gum confirm "$prompt" ;;
    fzf|select) read -r -p "$prompt [y/N] " ans; [[ "$ans" =~ ^[Yy] ]];;
  esac
}

setup_ui_input() {
  local prompt="$1"
  local default="${2:-}"
  local backend
  backend="$(setup_ui_backend)"
  case "$backend" in
    gum) gum input --placeholder "$prompt" --value "$default" ;;
    *) read -r -p "$prompt: " ans; echo "${ans:-$default}" ;;
  esac
}

setup_ui_choose_one() {
  local prompt="$1"
  local options="$2"
  local backend
  backend="$(setup_ui_backend)"
  case "$backend" in
    gum) printf '%s\n' "$options" | gum choose --header "$prompt" ;;
    fzf) printf '%s\n' "$options" | fzf --prompt="$prompt " ;;
    select)
      echo "$prompt" >&2
      local -a opts=()
      while IFS= read -r line; do opts+=("$line"); done <<< "$options"
      local i
      for ((i=0; i<${#opts[@]}; i++)); do
        printf '  %d) %s\n' "$((i+1))" "${opts[$i]}" >&2
      done
      local n
      read -r -p "Choice: " n
      echo "${opts[$((n-1))]}"
      ;;
  esac
}

#!/usr/bin/bash
# UI helpers: gum > fzf > bash select

setup_ui_gum_download_url() {
  local os="$1" arch="$2" version url
  version="$(curl -fsSL https://api.github.com/repos/charmbracelet/gum/releases/latest \
    | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' | head -1)"
  if [[ -z "$version" ]]; then
    echo "Failed to resolve latest gum release version." >&2
    return 1
  fi
  url="https://github.com/charmbracelet/gum/releases/download/v${version}/gum_${version}_${os}_${arch}.tar.gz"
  printf '%s' "$url"
}

setup_ui_install_gum() {
  local arch os url dest
  os="$(uname -s)"
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "Unsupported architecture: $arch" >&2; return 1 ;;
  esac
  case "$os" in
    Linux|Darwin) ;;
    *) echo "Unsupported OS: $os" >&2; return 1 ;;
  esac
  dest="${HOME}/.local/bin"
  mkdir -p "$dest"
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to download gum." >&2
    return 1
  fi
  local tmp extracted
  url="$(setup_ui_gum_download_url "$os" "$arch")" || return 1
  tmp="$(mktemp -d)"
  if ! curl -fsSL "$url" | tar -xz -C "$tmp" --wildcards '*/gum'; then
    rm -rf "$tmp"
    return 1
  fi
  extracted="$(find "$tmp" -type f -name gum | head -1)"
  if [[ -z "$extracted" ]]; then
    echo "gum binary not found in release archive." >&2
    rm -rf "$tmp"
    return 1
  fi
  install -m 755 "$extracted" "$dest/gum"
  rm -rf "$tmp"
}

# Recommend gum before interactive prompts; offer a no-sudo install to ~/.local/bin.
setup_ui_ensure_gum() {
  if command -v gum >/dev/null 2>&1; then
    return 0
  fi

  local fallback
  fallback="$(setup_ui_backend)"

  echo "gum is recommended for the setup wizard (checkboxes, confirmations, text input)." >&2
  echo "Without it, prompts fall back to ${fallback}." >&2
  echo >&2
  echo "  1) Install gum to ~/.local/bin (no sudo)" >&2
  echo "  2) Continue without gum" >&2
  echo >&2
  echo "Manual install: https://github.com/charmbracelet/gum#installation" >&2
  echo >&2

  local choice
  read -r -p "Install gum now? [1/2] (default 1): " choice
  case "${choice:-1}" in
    2|n|N|no|No)
      echo "Continuing with ${fallback} prompts." >&2
      return 0
      ;;
  esac

  if ! setup_ui_install_gum; then
    echo "gum install failed." >&2
    return 1
  fi

  export PATH="${HOME}/.local/bin:${PATH}"
  if ! command -v gum >/dev/null 2>&1; then
    echo "gum install failed: binary not found on PATH after install." >&2
    return 1
  fi
  echo "Installed gum to ~/.local/bin/gum" >&2
}

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
      # Options use id|label. gum --selected splits on commas, so preselect by
      # display label via --label-delimiter and return ids as id|label.
      local gum_in="" fid label
      declare -A _ui_labels=()
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        fid="${line%%|*}"
        label="${line#*|}"
        _ui_labels[$fid]="$label"
        gum_in+="${label}|${fid}"$'\n'
      done <<< "$options"

      local -a args=(choose --no-limit --header "$prompt" --label-delimiter="|")
      if [[ -n "$preselected" ]]; then
        while IFS= read -r line; do
          [[ -z "$line" ]] && continue
          args+=(--selected "${line#*|}")
        done <<< "$preselected"
      fi

      local selected_fid
      while IFS= read -r selected_fid; do
        [[ -z "$selected_fid" ]] && continue
        echo "${selected_fid}|${_ui_labels[$selected_fid]:-$selected_fid}"
      done < <(printf '%s\n' "$gum_in" | gum "${args[@]}")
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

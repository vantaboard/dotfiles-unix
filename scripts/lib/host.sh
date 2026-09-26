#!/usr/bin/env bash
# Host detection for the setup wizard and tests.
# Kinds: darwin | wsl | android | linux
#
# Overrides (for tests):
#   DOTFILES_HOST_KIND   - force a kind
#   DOTFILES_UNAME_S     - fake uname -s
#   DOTFILES_PROC_VERSION - path to a fake /proc/version

dotfiles_host_kind() {
  if [[ -n "${DOTFILES_HOST_KIND:-}" ]]; then
    printf '%s\n' "$DOTFILES_HOST_KIND"
    return 0
  fi

  local uname_s
  uname_s="${DOTFILES_UNAME_S:-$(uname -s 2>/dev/null || true)}"
  case "$uname_s" in
    Darwin)
      printf '%s\n' darwin
      return 0
      ;;
  esac

  if [[ "$(uname -o 2>/dev/null || true)" == "Android" ]] \
    || [[ -n "${PREFIX:-}" && -d "${PREFIX}/etc/termux" ]]; then
    printf '%s\n' android
    return 0
  fi

  if [[ -n "${WSL_DISTRO_NAME:-}" || -n "${WSL_INTEROP:-}" ]]; then
    printf '%s\n' wsl
    return 0
  fi

  local proc_version="${DOTFILES_PROC_VERSION:-/proc/version}"
  if [[ -r "$proc_version" ]] && grep -qi microsoft "$proc_version"; then
    printf '%s\n' wsl
    return 0
  fi

  printf '%s\n' linux
}

dotfiles_host_is_headless() {
  case "$(dotfiles_host_kind)" in
    darwin|wsl) return 0 ;;
    *) return 1 ;;
  esac
}

# Desktop / session features that should stay off on WSL and macOS.
# Matches the desktop catalog category plus clipboard and display-session extras.
dotfiles_graphical_features() {
  cat <<'EOF'
desktop_sway
hyprpicker
still
wayneko
swayfx
swappy
kanshi
wayland_session
wezterm
dunst
rofi
desktop_utils
dropbox
onlyoffice
anki
freecad
sunshine
keyd
wl_clipboard
displays_resume
hdmi_audio
EOF
}

dotfiles_is_graphical_feature() {
  local fid="$1"
  local known
  while IFS= read -r known; do
    [[ -z "$known" ]] && continue
    if [[ "$known" == "$fid" ]]; then
      return 0
    fi
  done < <(dotfiles_graphical_features)
  return 1
}

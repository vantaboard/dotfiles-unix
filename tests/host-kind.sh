#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../scripts/lib/host.sh
source "$REPO_ROOT/scripts/lib/host.sh"

echo "=== host kind ==="

DOTFILES_HOST_KIND=darwin
[[ "$(dotfiles_host_kind)" == "darwin" ]] || { echo "FAIL: override darwin"; exit 1; }
dotfiles_host_is_headless || { echo "FAIL: darwin should be headless"; exit 1; }
echo "OK: override darwin"

DOTFILES_HOST_KIND=wsl
[[ "$(dotfiles_host_kind)" == "wsl" ]] || { echo "FAIL: override wsl"; exit 1; }
dotfiles_host_is_headless || { echo "FAIL: wsl should be headless"; exit 1; }
echo "OK: override wsl"

DOTFILES_HOST_KIND=linux
[[ "$(dotfiles_host_kind)" == "linux" ]] || { echo "FAIL: override linux"; exit 1; }
if dotfiles_host_is_headless; then
  echo "FAIL: linux should not be headless"
  exit 1
fi
echo "OK: override linux"

DOTFILES_HOST_KIND=android
[[ "$(dotfiles_host_kind)" == "android" ]] || { echo "FAIL: override android"; exit 1; }
if dotfiles_host_is_headless; then
  echo "FAIL: android should not use the WSL/macOS headless path"
  exit 1
fi
echo "OK: override android"

unset DOTFILES_HOST_KIND
export DOTFILES_UNAME_S=Darwin
[[ "$(dotfiles_host_kind)" == "darwin" ]] || { echo "FAIL: uname Darwin"; exit 1; }
echo "OK: uname Darwin"

export DOTFILES_UNAME_S=Linux
unset WSL_DISTRO_NAME WSL_INTEROP
DOTFILES_PROC_VERSION="$(mktemp)"
trap 'rm -f "$DOTFILES_PROC_VERSION"' EXIT
echo "Linux version 5.15.167.4-microsoft-standard-WSL2 (gcc version 11.2.0)" > "$DOTFILES_PROC_VERSION"
export DOTFILES_PROC_VERSION
[[ "$(dotfiles_host_kind)" == "wsl" ]] || { echo "FAIL: microsoft /proc/version"; exit 1; }
echo "OK: microsoft /proc/version"

echo "Linux version 6.14.0-29-generic (buildd@lcy02-amd64-001)" > "$DOTFILES_PROC_VERSION"
[[ "$(dotfiles_host_kind)" == "linux" ]] || { echo "FAIL: generic /proc/version"; exit 1; }
echo "OK: generic linux /proc/version"

export WSL_DISTRO_NAME=Ubuntu
[[ "$(dotfiles_host_kind)" == "wsl" ]] || { echo "FAIL: WSL_DISTRO_NAME"; exit 1; }
echo "OK: WSL_DISTRO_NAME"
unset WSL_DISTRO_NAME

dotfiles_is_graphical_feature wayland_session || { echo "FAIL: wayland_session is graphical"; exit 1; }
dotfiles_is_graphical_feature desktop_sway || { echo "FAIL: desktop_sway is graphical"; exit 1; }
dotfiles_is_graphical_feature wl_clipboard || { echo "FAIL: wl_clipboard is graphical"; exit 1; }
dotfiles_is_graphical_feature displays_resume || { echo "FAIL: displays_resume is graphical"; exit 1; }
dotfiles_is_graphical_feature hdmi_audio || { echo "FAIL: hdmi_audio is graphical"; exit 1; }
if dotfiles_is_graphical_feature zsh; then
  echo "FAIL: zsh is not graphical"
  exit 1
fi
echo "OK: graphical feature list"

echo "=== host kind passed ==="

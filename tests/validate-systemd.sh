#!/usr/bin/env bash
set -euo pipefail

echo "=== systemd unit validation ==="

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SLEEP_HOOK="${REPO_ROOT}/home/system/systemd-sleep/displays-resume.tmpl"
LLAMA_UNIT="${REPO_ROOT}/home/system/systemd/llama-swap.service.tmpl"
IWLWIFI_SCRIPT="${REPO_ROOT}/home/system/bin/iwlwifi-recover"
IWLWIFI_HOOK="${REPO_ROOT}/home/system/systemd-sleep/iwlwifi-recover"
IWLWIFI_UNIT="${REPO_ROOT}/home/system/systemd/iwlwifi-recover.service"

if ! command -v systemd-analyze >/dev/null 2>&1; then
  echo "SKIP: systemd-analyze not available"
  exit 0
fi

TMP_HOOK="$(mktemp)"
FAKE_HOME=""
if command -v chezmoi >/dev/null 2>&1; then
  chezmoi execute-template < "$SLEEP_HOOK" > "$TMP_HOOK"
else
  FAKE_HOME="$(mktemp -d)"
  sed \
    -e "s|{{ .chezmoi.homeDir }}|${FAKE_HOME}|g" \
    -e "s|{{ .chezmoi.username }}|testuser|g" \
    "$SLEEP_HOOK" > "$TMP_HOOK"
fi
bash -n "$TMP_HOOK"
rm -f "$TMP_HOOK"
[[ -n "$FAKE_HOME" ]] && rm -rf "$FAKE_HOME"
echo "OK: systemd-sleep/displays-resume validates"

bash -n "$IWLWIFI_SCRIPT"
bash -n "$IWLWIFI_HOOK"
IWLWIFI_BIN_STUB=false
if ! [[ -x /usr/local/bin/iwlwifi-recover ]]; then
  sudo mkdir -p /usr/local/bin
  printf '#!/bin/sh\nexit 0\n' | sudo tee /usr/local/bin/iwlwifi-recover >/dev/null
  sudo chmod +x /usr/local/bin/iwlwifi-recover
  IWLWIFI_BIN_STUB=true
fi
systemd-analyze verify "$IWLWIFI_UNIT"
if [[ "$IWLWIFI_BIN_STUB" == true ]]; then
  sudo rm -f /usr/local/bin/iwlwifi-recover
fi
echo "OK: iwlwifi-recover validates"

if [[ -f "$LLAMA_UNIT" ]]; then
  LLAMA_BIN_STUB=false
  SWAP_BIN_STUB=false
  if ! command -v llama-server >/dev/null 2>&1 && ! [[ -x /usr/local/bin/llama-server ]]; then
    sudo mkdir -p /usr/local/bin
    printf '#!/bin/sh\n' | sudo tee /usr/local/bin/llama-server >/dev/null
    sudo chmod +x /usr/local/bin/llama-server
    LLAMA_BIN_STUB=true
  fi
  if ! command -v llama-swap >/dev/null 2>&1 && ! [[ -x /usr/local/bin/llama-swap ]]; then
    sudo mkdir -p /usr/local/bin
    printf '#!/bin/sh\n' | sudo tee /usr/local/bin/llama-swap >/dev/null
    sudo chmod +x /usr/local/bin/llama-swap
    SWAP_BIN_STUB=true
  fi
  TMP_UNIT="${REPO_ROOT}/tests/llama-swap.service"
  if command -v chezmoi >/dev/null 2>&1; then
    chezmoi execute-template < "$LLAMA_UNIT" > "$TMP_UNIT"
  else
    FAKE_HOME="$(mktemp -d)"
    sed \
      -e "s|{{ .chezmoi.homeDir }}|${FAKE_HOME}|g" \
      -e "s|{{ .chezmoi.username }}|testuser|g" \
      "$LLAMA_UNIT" > "$TMP_UNIT"
  fi
  systemd-analyze verify "$TMP_UNIT"
  rm -f "$TMP_UNIT"
  [[ -n "${FAKE_HOME:-}" ]] && rm -rf "$FAKE_HOME"
  if [[ "$LLAMA_BIN_STUB" == true ]]; then
    sudo rm -f /usr/local/bin/llama-server
  fi
  if [[ "$SWAP_BIN_STUB" == true ]]; then
    sudo rm -f /usr/local/bin/llama-swap
  fi
  echo "OK: llama-swap.service validates"
fi

echo "=== systemd validation passed ==="

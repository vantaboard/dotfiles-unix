#!/usr/bin/env bash
set -euo pipefail

echo "=== systemd unit validation ==="

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SLEEP_HOOK="${REPO_ROOT}/home/system/systemd-sleep/displays-resume.tmpl"

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

UNIT="${REPO_ROOT}/home/system/systemd/ollama.service"
if [[ -f "$UNIT" ]]; then
  OLLAMA_BIN_STUB=false
  if ! command -v ollama >/dev/null 2>&1 && ! [[ -x /usr/local/bin/ollama ]]; then
    sudo mkdir -p /usr/local/bin
    printf '#!/bin/sh\n' | sudo tee /usr/local/bin/ollama >/dev/null
    sudo chmod +x /usr/local/bin/ollama
    OLLAMA_BIN_STUB=true
  fi
  systemd-analyze verify "$UNIT"
  if [[ "$OLLAMA_BIN_STUB" == true ]]; then
    sudo rm -f /usr/local/bin/ollama
  fi
  echo "OK: ollama.service validates"
fi

echo "=== systemd validation passed ==="

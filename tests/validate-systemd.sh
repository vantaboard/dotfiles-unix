#!/usr/bin/env bash
set -euo pipefail

echo "=== systemd unit validation ==="

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UNIT="${REPO_ROOT}/home/system/systemd/displays-resume.service.tmpl"

if ! command -v systemd-analyze >/dev/null 2>&1; then
  echo "SKIP: systemd-analyze not available"
  exit 0
fi

# systemd-analyze verify requires ExecStart to exist and be executable.
stub_execstart_binary() {
  local unit_file="$1"
  local exec_start bin
  exec_start="$(grep -m1 '^ExecStart=' "$unit_file" | cut -d= -f2- | tr -d '\r')"
  bin="${exec_start%% *}"
  [[ -n "$bin" && ! -x "$bin" ]] || return 0
  mkdir -p "$(dirname "$bin")"
  printf '#!/bin/sh\n' > "$bin"
  chmod +x "$bin"
  printf '%s' "$bin"
}

remove_stub_binary() {
  local bin="${1:-}"
  if [[ -n "$bin" && -f "$bin" ]]; then
    rm -f "$bin"
  fi
}

# Render the template with chezmoi if available, otherwise use sed placeholders
TMP_UNIT="$(mktemp --suffix=.service)"
FAKE_HOME=""
if command -v chezmoi >/dev/null 2>&1; then
  chezmoi execute-template < "$UNIT" > "$TMP_UNIT"
else
  FAKE_HOME="$(mktemp -d)"
  sed \
    -e "s|{{ .chezmoi.homeDir }}|${FAKE_HOME}|g" \
    -e "s|{{ .chezmoi.username }}|testuser|g" \
    -e "s|{{ .chezmoi.uid }}|1001|g" \
    "$UNIT" > "$TMP_UNIT"
fi

DISPLAYS_RESUME_STUB="$(stub_execstart_binary "$TMP_UNIT")"
systemd-analyze verify "$TMP_UNIT"
remove_stub_binary "$DISPLAYS_RESUME_STUB"
rm -f "$TMP_UNIT"
[[ -n "$FAKE_HOME" ]] && rm -rf "$FAKE_HOME"
echo "OK: displays-resume.service validates"

OLLAMA_UNIT="${REPO_ROOT}/home/system/systemd/ollama.service"
if [[ -f "$OLLAMA_UNIT" ]]; then
  OLLAMA_BIN_STUB=false
  if ! command -v ollama >/dev/null 2>&1 && ! [[ -x /usr/local/bin/ollama ]]; then
    sudo mkdir -p /usr/local/bin
    printf '#!/bin/sh\n' | sudo tee /usr/local/bin/ollama >/dev/null
    sudo chmod +x /usr/local/bin/ollama
    OLLAMA_BIN_STUB=true
  fi
  systemd-analyze verify "$OLLAMA_UNIT"
  if [[ "$OLLAMA_BIN_STUB" == true ]]; then
    sudo rm -f /usr/local/bin/ollama
  fi
  echo "OK: ollama.service validates"
fi

echo "=== systemd validation passed ==="

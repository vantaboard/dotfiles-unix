#!/usr/bin/env bash
set -euo pipefail

echo "=== systemd unit validation ==="

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UNIT="${REPO_ROOT}/home/system/systemd/displays-resume.service.tmpl"

if ! command -v systemd-analyze >/dev/null 2>&1; then
  echo "SKIP: systemd-analyze not available"
  exit 0
fi

# Render the template with chezmoi if available, otherwise use sed placeholders
TMP_UNIT="$(mktemp --suffix=.service)"
if command -v chezmoi >/dev/null 2>&1; then
  chezmoi execute-template < "$UNIT" > "$TMP_UNIT"
else
  sed \
    -e "s|{{ .chezmoi.homeDir }}|/home/testuser|g" \
    -e "s|{{ .chezmoi.username }}|testuser|g" \
    -e "s|{{ .chezmoi.uid }}|1001|g" \
    "$UNIT" > "$TMP_UNIT"
fi

systemd-analyze verify "$TMP_UNIT"
rm -f "$TMP_UNIT"
echo "OK: displays-resume.service validates"

OLLAMA_UNIT="${REPO_ROOT}/home/system/systemd/ollama.service"
if [[ -f "$OLLAMA_UNIT" ]]; then
  systemd-analyze verify "$OLLAMA_UNIT"
  echo "OK: ollama.service validates"
fi

echo "=== systemd validation passed ==="

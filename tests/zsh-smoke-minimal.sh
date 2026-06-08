#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/zsh-smoke-common.sh
source "$SCRIPT_DIR/lib/zsh-smoke-common.sh"

echo "=== zsh minimal smoke test ==="

for f in .zshrc .zshenv .export .functions .alias .bindings; do
  [[ -f "${HOME}/${f}" ]] || { echo "FAIL: missing ${HOME}/${f}"; exit 1; }
  echo "OK: ${f} exists"
done

# fzf.zsh and OMZ plugins may be absent in minimal profile
zsh_smoke_run '
  set -e
  type whatport >/dev/null 2>&1 || { echo "FAIL: whatport not defined"; exit 1; }
  echo "OK: whatport defined"
  type move_to_config_env >/dev/null 2>&1 || { echo "FAIL: move_to_config_env not defined"; exit 1; }
  echo "OK: move_to_config_env defined"
  echo "OK: minimal zsh session loaded"
'

echo "=== zsh minimal smoke test passed ==="

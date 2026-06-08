#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/zsh-smoke-common.sh
source "$SCRIPT_DIR/lib/zsh-smoke-common.sh"

echo "=== zsh smoke test ==="

# Verify chezmoi-managed dotfiles exist
for f in .zshrc .zshenv .export .functions .alias .bindings; do
  [[ -f "${HOME}/${f}" ]] || { echo "FAIL: missing ${HOME}/${f}"; exit 1; }
  echo "OK: ${f} exists"
done

# Verify custom functions and aliases load in an interactive zsh session
zsh_smoke_run '
  set -e
  type whatport >/dev/null 2>&1 || { echo "FAIL: whatport not defined"; exit 1; }
  echo "OK: whatport defined"

  type move_to_config_env >/dev/null 2>&1 || { echo "FAIL: move_to_config_env not defined"; exit 1; }
  echo "OK: move_to_config_env defined"

  type gmr >/dev/null 2>&1 || { echo "FAIL: gmr not defined"; exit 1; }
  echo "OK: gmr defined"

  type copy-path >/dev/null 2>&1 || { echo "FAIL: copy-path not defined"; exit 1; }
  echo "OK: copy-path defined"

  alias vi >/dev/null 2>&1 || { echo "FAIL: vi alias not defined"; exit 1; }
  echo "OK: vi alias defined"

  echo "OK: zsh interactive session loaded"
'

echo "=== zsh smoke test passed ==="

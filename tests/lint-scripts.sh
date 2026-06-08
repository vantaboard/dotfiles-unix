#!/usr/bin/env bash
set -euo pipefail

echo "=== script lint ==="

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOME_DIR="${REPO_ROOT}/home"

# chezmoi only sets +x when the source filename uses the executable_ prefix.
for script in "${HOME_DIR}"/dot_local/bin/*; do
  [[ -f "$script" ]] || continue
  base="$(basename "$script")"
  if [[ "$base" != executable_* ]]; then
    echo "FAIL: dot_local/bin scripts must be named executable_<name>: $script"
    exit 1
  fi
done
echo "OK: dot_local/bin executable_ naming"

shopt -s globstar nullglob
for script in "${HOME_DIR}"/run_*.sh.tmpl "${HOME_DIR}"/dot_local/bin/* "${HOME_DIR}"/dot_screenlayout/*.sh "${HOME_DIR}"/system/udev/*.sh; do
  [[ -f "$script" ]] || continue
  # Skip large vendored scripts and binary-ish files
  case "$(basename "$script")" in
    betterlockscreen|cameractrls2) continue ;;
  esac
  if head -1 "$script" | grep -qE '^#!.*(bash|sh|zsh)'; then
    bash -n "$script" 2>/dev/null || {
      # Templates may contain {{ }} which bash -n rejects; lint the non-template scripts only
      if [[ "$script" != *.tmpl ]]; then
        echo "FAIL: bash -n $script"
        exit 1
      fi
      echo "SKIP (template): $script"
    }
    [[ "$script" != *.tmpl ]] && echo "OK: $script"
  fi
done

# Lint non-template shell scripts explicitly
bash -n "${REPO_ROOT}/scripts/dotfiles-setup"
echo "OK: ${REPO_ROOT}/scripts/dotfiles-setup"
bash -n "${REPO_ROOT}/scripts/lib/setup-catalog.sh"
echo "OK: ${REPO_ROOT}/scripts/lib/setup-catalog.sh"
bash -n "${REPO_ROOT}/scripts/lib/setup-ui.sh"
echo "OK: ${REPO_ROOT}/scripts/lib/setup-ui.sh"
bash -n "${REPO_ROOT}/tests/lib/zsh-smoke-common.sh"
echo "OK: ${REPO_ROOT}/tests/lib/zsh-smoke-common.sh"

for script in \
  "${HOME_DIR}/dot_local/bin/executable_deploy-dotfiles" \
  "${HOME_DIR}/dot_local/bin/executable_gimmekeys" \
  "${HOME_DIR}/dot_local/bin/executable_cursor-clip" \
  "${HOME_DIR}/system/udev/hotplug_monitor.sh"; do
  [[ -f "$script" ]] || continue
  bash -n "$script"
  echo "OK: $script"
done

echo "=== script lint passed ==="

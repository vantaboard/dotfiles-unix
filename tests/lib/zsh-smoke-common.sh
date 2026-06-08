#!/usr/bin/env bash
# Shared helpers for zsh smoke tests.

zsh_smoke_run() {
  local script="$1"
  local stderr_file wrapped
  stderr_file="$(mktemp)"
  trap 'rm -f "$stderr_file"' RETURN

  # Load dotfiles like a login shell without zsh -ic teardown noise in non-TTY CI.
  wrapped="emulate -L zsh
[[ -f \"\$HOME/.zshenv\" ]] && source \"\$HOME/.zshenv\"
[[ -f \"\$HOME/.zshrc\" ]] && source \"\$HOME/.zshrc\"
${script}"

  if ! zsh -f -c "$wrapped" 2>"$stderr_file"; then
    [[ -s "$stderr_file" ]] && cat "$stderr_file" >&2
    echo "FAIL: zsh exited non-zero"
    return 1
  fi

  if [[ -s "$stderr_file" ]]; then
    cat "$stderr_file" >&2
    echo "FAIL: zsh emitted errors while loading dotfiles"
    return 1
  fi

  return 0
}

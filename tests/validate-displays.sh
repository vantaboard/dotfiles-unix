#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "=== validate displays ==="

bash -n "$REPO_ROOT/home/dot_local/bin/executable_sway-displays"
echo "OK: sway-displays syntax"

# Empty layout file → undocked laptop panel (no sway session needed).
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/sway"
cat > "$tmp/sway/displays.json" <<'EOF'
{
  "laptop": { "match": "eDP-1" },
  "devices": {},
  "layouts": []
}
EOF
got="$(XDG_CONFIG_HOME="$tmp" SWAYSOCK="" bash "$REPO_ROOT/home/dot_local/bin/executable_sway-displays" match)"
layout="$(jq -r '.layout' <<<"$got")"
action="$(jq -r '.laptop.action' <<<"$got")"
if [[ "$layout" != "undocked" || "$action" != "enable" ]]; then
  echo "FAIL: empty displays.json should match undocked/enable, got: $got"
  exit 1
fi
echo "OK: empty displays.json matches undocked"

# Example profile must not bake in machine EDID serials.
if grep -E 'ETN5N03598SL0|N7LMQS030618|N7LMQS030621' \
  "$REPO_ROOT/home/.chezmoidata/profile.example.yaml" \
  "$REPO_ROOT/home/.chezmoidata/profile-ci.yaml"; then
  echo "FAIL: example/CI profiles contain machine EDID serials"
  exit 1
fi
echo "OK: example profiles have no machine EDID serials"

if command -v chezmoi >/dev/null 2>&1; then
  rendered="$(CHEZMOI_CI=1 chezmoi execute-template < "$REPO_ROOT/home/dot_config/kanshi/config.tmpl")"
  grep -q '^profile undocked {' <<<"$rendered" || {
    echo "FAIL: CI kanshi template did not render undocked profile"
    echo "$rendered"
    exit 1
  }
  if grep -E 'ETN5N03598SL0|N7LMQS030618|N7LMQS030621' <<<"$rendered"; then
    echo "FAIL: CI kanshi render contains machine EDID serials"
    exit 1
  fi
  echo "OK: CI kanshi template is laptop-only"
else
  echo "SKIP: chezmoi not available for kanshi template render"
fi

echo "=== displays validation passed ==="

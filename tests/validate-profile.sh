#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CATALOG="$REPO_ROOT/home/.chezmoidata/setup-catalog.yaml"
PROFILE="${1:-$REPO_ROOT/home/.chezmoidata/profile.example.yaml}"

# shellcheck source=../scripts/lib/setup-catalog.sh
source "$REPO_ROOT/scripts/lib/setup-catalog.sh"
export CATALOG_FILE="$CATALOG"

echo "=== validate profile ==="

if [[ ! -f "$PROFILE" ]]; then
  echo "FAIL: profile not found: $PROFILE"
  exit 1
fi

# Extract feature flags from profile YAML (simple grep)
declare -A ENABLED=()
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]+([a-z_]+):[[:space:]]+(true|false) ]]; then
    fid="${BASH_REMATCH[1]}"
    val="${line##*:}"
    val="${val// /}"
    [[ "$val" == "true" ]] && ENABLED[$fid]=1 || ENABLED[$fid]=0
  fi
done < <(awk '/^(profile|profile_example|profile_ci):/{f=1;next} f && /^[a-z_]/ && !/^  /{f=0} f' "$PROFILE")

for fid in $(catalog_all_feature_ids); do
  if [[ -z "${ENABLED[$fid]:-}" ]]; then
    ENABLED[$fid]=0
    for cat in $(catalog_get_categories); do
      while IFS=: read -r cfid def req; do
        [[ "$cfid" == "$fid" && ( "$def" == "true" || "$req" == "true" ) ]] && ENABLED[$fid]=1
      done < <(catalog_get_features_in_category "$cat")
    done
  fi
done

for fid in "${!ENABLED[@]}"; do
  catalog_get_feature_field "$fid" "label" >/dev/null 2>&1 || {
    if ! grep -q "^    ${fid}:" "$CATALOG"; then
      echo "FAIL: unknown feature id in profile: $fid"
      exit 1
    fi
  }
done

# Dependency check
for fid in $(catalog_all_feature_ids); do
  [[ "${ENABLED[$fid]:-0}" == "1" ]] || continue
  while IFS= read -r req; do
    [[ -z "$req" ]] && continue
    if [[ "${ENABLED[$req]:-0}" != "1" ]]; then
      echo "FAIL: $fid requires $req but $req is disabled"
      exit 1
    fi
  done < <(catalog_get_requires "$fid")
done

echo "OK: profile validates against catalog"

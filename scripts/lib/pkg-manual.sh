#!/usr/bin/bash
# Parse and update pkg-manual.yaml without external YAML libraries.

PKG_MANUAL_REPO_ROOT="${PKG_MANUAL_REPO_ROOT:-}"
PKG_MANUAL_FILE="${PKG_MANUAL_FILE:-}"
PACKAGES_FILE="${PACKAGES_FILE:-}"

declare -A PKG_MANUAL_STATUS=()
declare -A PKG_MANUAL_FIRST_SEEN=()
PKG_MANUAL_EXCLUDE=()

pkg_manual_resolve_paths() {
  local script_dir repo_root
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  repo_root="${PKG_MANUAL_REPO_ROOT:-$(cd "$script_dir/../.." && pwd)}"
  PKG_MANUAL_REPO_ROOT="$repo_root"
  PKG_MANUAL_FILE="${PKG_MANUAL_FILE:-$repo_root/home/.chezmoidata/pkg-manual.yaml}"
  PACKAGES_FILE="${PACKAGES_FILE:-$repo_root/home/.chezmoidata/packages.yaml}"
}

pkg_manual_load() {
  pkg_manual_resolve_paths
  PKG_MANUAL_STATUS=()
  PKG_MANUAL_FIRST_SEEN=()
  PKG_MANUAL_EXCLUDE=()

  [[ -f "$PKG_MANUAL_FILE" ]] || return 0

  local pkg status seen line
  while IFS= read -r line; do
    case "$line" in
      "    "*) ;;
      *) continue ;;
    esac
    if [[ "$line" =~ ^[[:space:]]{4}([a-z0-9][a-z0-9+.-]*):$ ]]; then
      pkg="${BASH_REMATCH[1]}"
      status=""
      seen=""
      continue
    fi
    if [[ -n "${pkg:-}" && "$line" =~ ^[[:space:]]{6}status:[[:space:]]+(pending|install|ignore)$ ]]; then
      status="${BASH_REMATCH[1]}"
    fi
    if [[ -n "${pkg:-}" && "$line" =~ ^[[:space:]]{6}first_seen:[[:space:]]+\"([^\"]*)\"$ ]]; then
      seen="${BASH_REMATCH[1]}"
    fi
    if [[ -n "${pkg:-}" && -n "$status" && -n "$seen" ]]; then
      PKG_MANUAL_STATUS[$pkg]="$status"
      PKG_MANUAL_FIRST_SEEN[$pkg]="$seen"
      pkg=""
      status=""
      seen=""
    fi
  done < "$PKG_MANUAL_FILE"

  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+)$ ]] || continue
    PKG_MANUAL_EXCLUDE+=("${BASH_REMATCH[1]}")
  done < <(awk '
    /^  exclude:/{f=1; next}
    f && /^  packages:/{exit}
    f && /^      - /{print}
  ' "$PKG_MANUAL_FILE" 2>/dev/null || true)
}

pkg_manual_save() {
  pkg_manual_resolve_paths
  mkdir -p "$(dirname "$PKG_MANUAL_FILE")"

  {
    cat <<'EOF'
# Manually installed Termux packages discovered on this machine.
#
# Run scripts/pkg-manual-sync to scan for new packages and set status:
#   pending  — seen but not yet decided (not installed by chezmoi)
#   install  — include in chezmoi apt install on apply
#   ignore   — tracked only; never installed by chezmoi
#
# Entries are never removed; change status with: pkg-manual-sync mark <pkg> <status>
pkg_manual:
  exclude:
EOF
    if ((${#PKG_MANUAL_EXCLUDE[@]})); then
      local item
      for item in "${PKG_MANUAL_EXCLUDE[@]}"; do
        printf '    - %s\n' "$item"
      done
    else
      echo "    []"
    fi
    echo "  packages:"
    if ((${#PKG_MANUAL_STATUS[@]})); then
      local pkg
      for pkg in $(printf '%s\n' "${!PKG_MANUAL_STATUS[@]}" | sort); do
        printf '    %s:\n' "$pkg"
        printf '      status: %s\n' "${PKG_MANUAL_STATUS[$pkg]}"
        printf '      first_seen: "%s"\n' "${PKG_MANUAL_FIRST_SEEN[$pkg]}"
      done
    fi
  } > "$PKG_MANUAL_FILE"
}

pkg_manual_today() {
  date +%Y-%m-%d
}

pkg_manual_managed_packages() {
  pkg_manual_resolve_paths
  awk '/^  termux:/{f=1; next} f && /^  [a-z_]+:/ && $0 !~ /^    /{f=0} f && /^    pkg:/{p=1; next} p && /^      - /{print $2}' "$PACKAGES_FILE"

  local file
  for file in "$PKG_MANUAL_REPO_ROOT/home/.chezmoidata"/profile*.yaml; do
    [[ -f "$file" ]] || continue
    awk '/^  packages:/{f=1; next} f && /^  [a-z_]+:/ && $0 !~ /^    /{f=0} f && /^    - /{print $2}' "$file"
  done
}

pkg_manual_all_managed_sorted() {
  {
    pkg_manual_managed_packages
    printf '%s\n' "${!PKG_MANUAL_STATUS[@]}"
  } | awk 'NF && !seen[$0]++' | sort -u
}

pkg_manual_is_excluded() {
  local pkg="$1" pattern item
  for item in "${PKG_MANUAL_BUILTIN_EXCLUDE[@]}" "${PKG_MANUAL_EXCLUDE[@]}"; do
    [[ "$pkg" == "$item" ]] && return 0
  done
  for pattern in "${PKG_MANUAL_BUILTIN_EXCLUDE_PATTERNS[@]}"; do
    [[ "$pkg" =~ $pattern ]] && return 0
  done
  return 1
}

# Bootstrap / core Termux packages that are rarely worth tracking.
PKG_MANUAL_BUILTIN_EXCLUDE=(
  termux-tools
  termux-exec
  termux-keyring
  termux-am
)
PKG_MANUAL_BUILTIN_EXCLUDE_PATTERNS=(
  '^termux-'
)

pkg_manual_system_manual_packages() {
  if ! command -v apt-mark >/dev/null 2>&1; then
    echo "apt-mark not found; is this Termux (apt-based)?" >&2
    return 1
  fi
  if ! command -v pkg >/dev/null 2>&1 && [[ ! -d "${PREFIX:-}/bin" ]]; then
    echo "Not a Termux environment (pkg/PREFIX missing)." >&2
    return 1
  fi
  apt-mark showmanual | sort -u
}

pkg_manual_set_status() {
  local pkg="$1" status="$2" today
  today="$(pkg_manual_today)"
  case "$status" in
    pending|install|ignore) ;;
    *) echo "Invalid status: $status (use pending, install, or ignore)" >&2; return 1 ;;
  esac
  PKG_MANUAL_STATUS[$pkg]="$status"
  PKG_MANUAL_FIRST_SEEN[$pkg]="${PKG_MANUAL_FIRST_SEEN[$pkg]:-$today}"
}

pkg_manual_add_pending() {
  local pkg="$1"
  [[ -n "${PKG_MANUAL_STATUS[$pkg]:-}" ]] && return 1
  pkg_manual_set_status "$pkg" "pending"
  return 0
}

pkg_manual_find_new_packages() {
  pkg_manual_load
  local managed pkg
  managed="$(pkg_manual_all_managed_sorted)"
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    pkg_manual_is_excluded "$pkg" && continue
    grep -qxF "$pkg" <<< "$managed" && continue
    echo "$pkg"
  done < <(pkg_manual_system_manual_packages)
}

pkg_manual_count_by_status() {
  local want="$1" pkg count=0
  for pkg in "${!PKG_MANUAL_STATUS[@]}"; do
    [[ "${PKG_MANUAL_STATUS[$pkg]}" == "$want" ]] && ((count++)) || true
  done
  echo "$count"
}

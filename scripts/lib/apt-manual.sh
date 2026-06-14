#!/usr/bin/bash
# Parse and update apt-manual.yaml without external YAML libraries.

APT_MANUAL_REPO_ROOT="${APT_MANUAL_REPO_ROOT:-}"
APT_MANUAL_FILE="${APT_MANUAL_FILE:-}"
PACKAGES_FILE="${PACKAGES_FILE:-}"

declare -A APT_MANUAL_STATUS=()
declare -A APT_MANUAL_FIRST_SEEN=()
APT_MANUAL_EXCLUDE=()

apt_manual_resolve_paths() {
  local script_dir repo_root
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  repo_root="${APT_MANUAL_REPO_ROOT:-$(cd "$script_dir/../.." && pwd)}"
  APT_MANUAL_REPO_ROOT="$repo_root"
  APT_MANUAL_FILE="${APT_MANUAL_FILE:-$repo_root/home/.chezmoidata/apt-manual.yaml}"
  PACKAGES_FILE="${PACKAGES_FILE:-$repo_root/home/.chezmoidata/packages.yaml}"
}

apt_manual_load() {
  apt_manual_resolve_paths
  APT_MANUAL_STATUS=()
  APT_MANUAL_FIRST_SEEN=()
  APT_MANUAL_EXCLUDE=()

  [[ -f "$APT_MANUAL_FILE" ]] || return 0

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
      APT_MANUAL_STATUS[$pkg]="$status"
      APT_MANUAL_FIRST_SEEN[$pkg]="$seen"
      pkg=""
      status=""
      seen=""
    fi
  done < "$APT_MANUAL_FILE"

  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+)$ ]] || continue
    APT_MANUAL_EXCLUDE+=("${BASH_REMATCH[1]}")
  done < <(awk '
    /^  exclude:/{f=1; next}
    f && /^  packages:/{exit}
    f && /^      - /{print}
  ' "$APT_MANUAL_FILE" 2>/dev/null || true)
}

apt_manual_save() {
  apt_manual_resolve_paths
  mkdir -p "$(dirname "$APT_MANUAL_FILE")"

  {
    cat <<'EOF'
# Manually installed apt packages discovered on this machine.
#
# Run scripts/apt-manual-sync to scan for new packages and set status:
#   pending  — seen but not yet decided (not installed by chezmoi)
#   install  — include in chezmoi apt install on apply
#   ignore   — tracked only; never installed by chezmoi
#
# Entries are never removed; change status with: apt-manual-sync mark <pkg> <status>
apt_manual:
  exclude:
EOF
    if ((${#APT_MANUAL_EXCLUDE[@]})); then
      local item
      for item in "${APT_MANUAL_EXCLUDE[@]}"; do
        printf '    - %s\n' "$item"
      done
    else
      echo "    []"
    fi
    echo "  packages:"
    if ((${#APT_MANUAL_STATUS[@]})); then
      local pkg
      for pkg in $(printf '%s\n' "${!APT_MANUAL_STATUS[@]}" | sort); do
        printf '    %s:\n' "$pkg"
        printf '      status: %s\n' "${APT_MANUAL_STATUS[$pkg]}"
        printf '      first_seen: "%s"\n' "${APT_MANUAL_FIRST_SEEN[$pkg]}"
      done
    fi
  } > "$APT_MANUAL_FILE"
}

apt_manual_today() {
  date +%Y-%m-%d
}

apt_manual_list_yaml_packages() {
  local file="$1" key="$2"
  [[ -f "$file" ]] || return 0
  awk -v key="$key" '
    $0 ~ "^"key":$"{f=1; next}
    f && /^[a-z_]+:/ && $0 !~ /^  /{exit}
    f && /^  packages:/{p=1; next}
    p && /^  [a-z_]+:/ && $0 !~ /^    /{p=0}
    p && /^    - /{print $2}
  ' "$file"
}

apt_manual_managed_packages() {
  apt_manual_resolve_paths
  awk '/^    apt:/{f=1; next} f && /^    apt_ci:/{f=0} f && /^      - /{print $2}' "$PACKAGES_FILE"
  awk '/^    apt_ci:/{f=1; next} f && /^  termux:/{f=0} f && /^      - /{print $2}' "$PACKAGES_FILE"

  local file
  for file in "$APT_MANUAL_REPO_ROOT/home/.chezmoidata"/profile*.yaml; do
    [[ -f "$file" ]] || continue
    awk '/^  packages:/{f=1; next} f && /^  [a-z_]+:/ && $0 !~ /^    /{f=0} f && /^    - /{print $2}' "$file"
  done
}

apt_manual_all_managed_sorted() {
  {
    apt_manual_managed_packages
    printf '%s\n' "${!APT_MANUAL_STATUS[@]}"
  } | awk 'NF && !seen[$0]++' | sort -u
}

apt_manual_is_excluded() {
  local pkg="$1" pattern item
  for item in "${APT_MANUAL_BUILTIN_EXCLUDE[@]}" "${APT_MANUAL_EXCLUDE[@]}"; do
    [[ "$pkg" == "$item" ]] && return 0
  done
  for pattern in "${APT_MANUAL_BUILTIN_EXCLUDE_PATTERNS[@]}"; do
    [[ "$pkg" =~ $pattern ]] && return 0
  done
  return 1
}

# Meta/kernel/language packages that are rarely worth tracking.
APT_MANUAL_BUILTIN_EXCLUDE=(
  ubuntu-minimal ubuntu-standard ubuntu-desktop ubuntu-desktop-minimal
  systemd-sysv systemd-timesyncd
)
APT_MANUAL_BUILTIN_EXCLUDE_PATTERNS=(
  '^linux-image-'
  '^linux-headers-'
  '^linux-modules-'
  '^language-pack-'
  '^liblocale-'
)

apt_manual_system_manual_packages() {
  if ! command -v apt-mark >/dev/null 2>&1; then
    echo "apt-mark not found; is this a Debian/Ubuntu system?" >&2
    return 1
  fi
  apt-mark showmanual | sort -u
}

apt_manual_pkg_status() {
  local pkg="$1"
  echo "${APT_MANUAL_STATUS[$pkg]:-}"
}

apt_manual_set_status() {
  local pkg="$1" status="$2" today
  today="$(apt_manual_today)"
  case "$status" in
    pending|install|ignore) ;;
    *) echo "Invalid status: $status (use pending, install, or ignore)" >&2; return 1 ;;
  esac
  APT_MANUAL_STATUS[$pkg]="$status"
  APT_MANUAL_FIRST_SEEN[$pkg]="${APT_MANUAL_FIRST_SEEN[$pkg]:-$today}"
}

apt_manual_add_pending() {
  local pkg="$1"
  [[ -n "${APT_MANUAL_STATUS[$pkg]:-}" ]] && return 1
  apt_manual_set_status "$pkg" "pending"
  return 0
}

apt_manual_find_new_packages() {
  apt_manual_load
  local managed pkg
  managed="$(apt_manual_all_managed_sorted)"
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    apt_manual_is_excluded "$pkg" && continue
    grep -qxF "$pkg" <<< "$managed" && continue
    echo "$pkg"
  done < <(apt_manual_system_manual_packages)
}

apt_manual_count_by_status() {
  local want="$1" pkg count=0
  for pkg in "${!APT_MANUAL_STATUS[@]}"; do
    [[ "${APT_MANUAL_STATUS[$pkg]}" == "$want" ]] && ((count++)) || true
  done
  echo "$count"
}

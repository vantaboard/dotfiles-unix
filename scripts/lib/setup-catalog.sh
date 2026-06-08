#!/usr/bin/bash
# Parse setup-catalog.yaml without external YAML libs.

CATALOG_FILE="${CATALOG_FILE:-}"

catalog_get_categories() {
  awk '/^  categories:/{found=1; next} found && /^    - id:/{print $3}' "$CATALOG_FILE"
}

catalog_get_category_label() {
  local cat_id="$1"
  awk -v id="$cat_id" '
    /^    - id:/{cid=$3; next}
    cid==id && /label:/{sub(/^      label: /,""); print; exit}
  ' "$CATALOG_FILE"
}

catalog_get_category_required() {
  local cat_id="$1"
  awk -v id="$cat_id" '
    /^    - id:/{cid=$3; next}
    cid==id && /required: true/{print "true"; exit}
  ' "$CATALOG_FILE"
}

catalog_get_features_in_category() {
  local cat_id="$1"
  awk -v cat="$cat_id" '
    /^  features:/{inf=1; next}
    !inf{next}
    /^    [a-z_][a-z0-9_]*:$/{
      if (fid != "" && feat_cat == cat) print fid ":" def ":" req
      fid = $1; gsub(/:/, "", fid)
      feat_cat = ""; def = "false"; req = "false"
      next
    }
    /^      category:/{feat_cat = $2; next}
    /^      default: true/{def = "true"; next}
    /^      required: true/{req = "true"; next}
    END{
      if (fid != "" && feat_cat == cat) print fid ":" def ":" req
    }
  ' "$CATALOG_FILE"
}

catalog_get_feature_field() {
  local feat="$1"
  local field="$2"
  awk -v f="$feat" -v field="$field" '
    $0 ~ "^    "f":$"{found=1; next}
    found && /^    [a-z_]/ && $0 !~ "^      "{exit}
    found && $0 ~ "^      "field": "{
      sub("^      "field": ",""); gsub(/^ /,""); print; exit
    }
  ' "$CATALOG_FILE"
}

catalog_get_requires() {
  local feat="$1"
  awk -v f="$feat" '
    $0 ~ "^    "f":$"{found=1; next}
    found && /^    [a-z_]/ && $0 !~ "^      "{exit}
    found && /^      requires:/{getline; while(/^        - /){print $2; getline}}
  ' "$CATALOG_FILE"
}

catalog_get_packages() {
  local feat="$1"
  awk -v f="$feat" '
    $0 ~ "^    "f":$"{found=1; next}
    found && /^    [a-z_]/ && $0 !~ "^      "{exit}
    found && /^      packages: \[/{
      line = $0
      sub(/^      packages: \[/, "", line)
      sub(/\].*$/, "", line)
      n = split(line, arr, ", ")
      for (i = 1; i <= n; i++) {
        gsub(/^ +| +$/, "", arr[i])
        if (arr[i] != "") print arr[i]
      }
      next
    }
    found && /^      packages:/{getline; while(/^        - /){if($2!="") print $2; getline}}
  ' "$CATALOG_FILE"
}

catalog_all_feature_ids() {
  awk '/^  features:/{found=1; next} found && /^    [a-z_][a-z0-9_]*:$/{print $1}' "$CATALOG_FILE" | tr -d ':'
}

catalog_get_systemd_unit() {
  catalog_get_feature_field "$1" "systemd_unit"
}

catalog_get_system_deploy() {
  catalog_get_feature_field "$1" "system_deploy"
}

catalog_get_systemd_units_list() {
  local feat="$1"
  awk -v f="$feat" '
    $0 ~ "^    "f":$"{found=1; next}
    found && /^    [a-z_]/ && $0 !~ "^      "{exit}
    found && /^      systemd_units:/{getline; while(/^        - /){print $2; getline}}
    found && /^      systemd_unit:/{print $2; exit}
  ' "$CATALOG_FILE"
}

# Resolve dependencies: disable features whose requires are not enabled
catalog_resolve_features() {
  local -n _enabled="$1"
  local changed=1
  while (( changed )); do
    changed=0
    local fid
    for fid in $(catalog_all_feature_ids); do
      [[ "${_enabled[$fid]:-0}" == "1" ]] || continue
      local req
      for req in $(catalog_get_requires "$fid"); do
        if [[ "${_enabled[$req]:-0}" != "1" ]]; then
          _enabled[$fid]=0
          echo "WARN: disabled $fid (requires $req)" >&2
          changed=1
        fi
      done
    done
  done
}

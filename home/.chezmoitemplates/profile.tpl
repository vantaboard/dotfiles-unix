{{/*
  Effective profile merge (reference — copy this block into templates).

  Chezmoi cannot pipe {{ template }} output through fromYaml, so consumers
  inline the logic below instead of including this file.

  Priority (low → high): profile_example → android auto (profile_termux_example)
  → profile.yaml → CHEZMOI_CI → profile-host.yaml mergeOverwrite
*/}}
{{- $p := .profile_example -}}
{{- if eq .chezmoi.os "android" -}}{{- $p = .profile_termux_example -}}{{- end -}}
{{- if index . "profile" -}}{{- $p = .profile -}}{{- end -}}
{{- if env "CHEZMOI_CI" -}}{{- $p = .profile_ci -}}{{- end -}}
{{- if index . "profile_host" -}}{{- $p = mergeOverwrite $p .profile_host -}}{{- end -}}
{{- $p | toYaml -}}

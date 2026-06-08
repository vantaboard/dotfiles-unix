{{/*
  Effective profile merge (reference — copy this block into templates).

  Chezmoi cannot pipe {{ template }} output through fromYaml, so consumers
  inline the logic below instead of including this file.
*/}}
{{- $p := .profile_example -}}
{{- if index . "profile" -}}{{- $p = .profile -}}{{- end -}}
{{- if env "CHEZMOI_CI" -}}{{- $p = .profile_ci -}}{{- end -}}
{{- if index . "profile_host" -}}{{- $p = mergeOverwrite $p .profile_host -}}{{- end -}}
{{- $p | toYaml -}}

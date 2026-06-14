{{/*
  Effective profile merge (reference — copy this block into templates).

  Chezmoi cannot pipe {{ template }} output through fromYaml, so consumers
  inline the logic below instead of including this file.

  On Android: profile.yaml merges on top of profile_termux_example (does not
  replace it), then Termux feature flags are re-applied so desktop/mise/vivid
  stay off even if the setup wizard wrote a Linux-oriented profile.yaml.
*/}}
{{- $p := .profile_example -}}
{{- if eq .chezmoi.os "android" -}}{{- $p = .profile_termux_example -}}{{- end -}}
{{- if index . "profile" -}}
{{-   if eq .chezmoi.os "android" -}}{{- $p = mergeOverwrite $p .profile -}}
{{-   else -}}{{- $p = .profile -}}
{{-   end -}}
{{- end -}}
{{- if env "CHEZMOI_CI" -}}{{- $p = .profile_ci -}}{{- end -}}
{{- if index . "profile_host" -}}{{- $p = mergeOverwrite $p .profile_host -}}{{- end -}}
{{- if eq .chezmoi.os "android" -}}
{{- $p = mergeOverwrite $p (dict "features" (mergeOverwrite $p.features .profile_termux_example.features)) -}}
{{- end -}}
{{- $p | toYaml -}}

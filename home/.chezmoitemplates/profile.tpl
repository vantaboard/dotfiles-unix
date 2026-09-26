{{/*
  Effective profile. Consumers should do:

    {{- $p := includeTemplate "profile.tpl" . | fromYaml -}}

  Base profile:
    android -> profile_termux_example
    darwin  -> profile_macos_example
    wsl     -> profile_wsl_example
    linux   -> profile_example

  CHEZMOI_CI selects profile_ci (Linux) or profile_ci_macos (Darwin).
  profile.yaml / profile-host.yaml then merge. Termux and WSL/macOS
  force-off desktop / Wayland / GDM features so a copied Linux profile
  cannot enable a graphical session on those hosts.
*/}}
{{- $os := .chezmoi.os -}}
{{- $kernel := "" -}}
{{- if and (index .chezmoi "kernel") (index .chezmoi.kernel "osrelease") -}}
{{-   $kernel = .chezmoi.kernel.osrelease -}}
{{- end -}}
{{- $hostKindOverride := env "DOTFILES_HOST_KIND" -}}
{{- $wslEnv := or (env "WSL_DISTRO_NAME") (env "WSL_INTEROP") -}}
{{- $kernelWSL := or (contains "microsoft" (lower $kernel)) (contains "wsl" (lower $kernel)) -}}
{{- $isAndroid := or (eq $os "android") (eq $hostKindOverride "android") -}}
{{- $isDarwin := or (eq $os "darwin") (eq $hostKindOverride "darwin") -}}
{{- $isWSL := and (not $isDarwin) (not $isAndroid) (or (eq $hostKindOverride "wsl") (and (eq $os "linux") (or $wslEnv $kernelWSL))) -}}
{{- $graphicalOff := dict
      "desktop_sway" false
      "hyprpicker" false
      "still" false
      "wayneko" false
      "swayfx" false
      "swappy" false
      "kanshi" false
      "wayland_session" false
      "wezterm" false
      "dunst" false
      "rofi" false
      "desktop_utils" false
      "dropbox" false
      "onlyoffice" false
      "anki" false
      "freecad" false
      "sunshine" false
      "keyd" false
      "wl_clipboard" false
      "displays_resume" false
      "hdmi_audio" false
-}}
{{- $p := .profile_example -}}
{{- if $isAndroid -}}{{- $p = .profile_termux_example -}}{{- end -}}
{{- if $isDarwin -}}{{- $p = .profile_macos_example -}}{{- end -}}
{{- if $isWSL -}}{{- $p = .profile_wsl_example -}}{{- end -}}
{{- if index . "profile" -}}
{{-   if or $isAndroid $isDarwin $isWSL -}}{{- $p = mergeOverwrite $p .profile -}}
{{-   else -}}{{- $p = .profile -}}
{{-   end -}}
{{- end -}}
{{- if env "CHEZMOI_CI" -}}
{{-   if $isDarwin -}}{{- $p = .profile_ci_macos -}}
{{-   else -}}{{- $p = .profile_ci -}}
{{-   end -}}
{{- end -}}
{{- if index . "profile_host" -}}{{- $p = mergeOverwrite $p .profile_host -}}{{- end -}}
{{- if $isAndroid -}}
{{- $p = mergeOverwrite $p (dict "features" (mergeOverwrite $p.features .profile_termux_example.features)) -}}
{{- end -}}
{{- if or $isDarwin $isWSL -}}
{{- $p = mergeOverwrite $p (dict "features" (mergeOverwrite $p.features $graphicalOff)) -}}
{{-   if $isDarwin -}}
{{-     $p = mergeOverwrite $p (dict "system_deploy" (list) "systemd_units" (list)) -}}
{{-   else -}}
{{-     $filteredDeploy := list -}}
{{-     range ($p.system_deploy | default list) -}}
{{-       if not (has . (list "sway_session" "displays_resume" "hdmi_audio")) -}}
{{-         $filteredDeploy = append $filteredDeploy . -}}
{{-       end -}}
{{-     end -}}
{{-     $p = mergeOverwrite $p (dict "system_deploy" $filteredDeploy) -}}
{{-   end -}}
{{- end -}}
{{- $p | toYaml -}}

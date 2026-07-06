# System configuration audit

Review of system-level configuration for Ubuntu 24.04. This is a **public** repository — no secret-bearing files are tracked.

**Legend:** ✅ Tracked · 📋 Manual setup only · ❌ Never track

---

## Tracked in this repo

| Item | Location in repo | Deployed to |
|------|------------------|-------------|
| displays-resume sleep hook | `home/system/systemd-sleep/displays-resume.tmpl` | `/usr/lib/systemd/system-sleep/displays-resume` |
| GRUB defaults | `home/system/grub/default` | `/etc/default/grub` |
| SSH pubkey-only config | `home/system/ssh/sshd_config.d/99-keyonly-port.conf` | `/etc/ssh/sshd_config.d/` |
| SSH socket port override | `home/system/ssh/ssh.socket.d/port.conf` | `/etc/systemd/system/ssh.socket.d/` |
| llama-swap systemd unit | `home/system/systemd/llama-swap.service.tmpl` | `/etc/systemd/system/` |
| llama-swap model config | `home/dot_config/llama-swap/config.yaml.tmpl` | `~/.config/llama-swap/config.yaml` |
| keyd key remapping | `home/system/keyd/default.conf` | `/etc/keyd/default.conf` (Debian binary: `keyd.rvaiya`) |
| libinput pointer overrides | `home/system/libinput/local-overrides.quirks.tmpl` | `/etc/libinput/local-overrides.quirks` (from `profile.input_devices.pointers`) |
| Sway Wayland session | `home/system/wayland-sessions/sway.desktop` | `/usr/share/wayland-sessions/sway.desktop` |
| Sway session wrapper | `home/system/bin/sway-session` | `/usr/local/bin/sway-session` (sources `wayland.conf` before exec) |
| GDM Wayland enable | `home/system/gdm3/custom.conf` | `/etc/gdm3/custom.conf` (with `sway_session` deploy) |
| Enabled services list | `home/.chezmoidata/enabled-services.yaml` | `systemctl enable` via script |
| Kanshi profiles | `home/dot_config/kanshi/` | `~/.config/kanshi/` |

Deploy and enable scripts:

- `home/run_onchange_after_deploy-system.sh.tmpl` — systemd units, GRUB, SSH, keyd, libinput
- `home/run_onchange_after_enable-services.sh.tmpl` — enables units from `enabled-services.yaml`

---

## Enabled services (tracked, no VPN)

These units are enabled automatically on `chezmoi apply` (when the unit file exists on the machine):

| Unit | Purpose |
|------|---------|
| `keyd.service` | Kernel-level key remapping (Caps→Escape, Alt+hjkl nav) |
| `earlyoom.service` | OOM killer daemon |
| `thermald.service` | Thermal management |
| `docker.service` | Docker daemon |
| `llama-swap.service` | Local LLM proxy (llama.cpp + model hot-swap) |
| `displays-resume` (systemd-sleep) | Re-apply sway layout after suspend/hibernate |

---

## Manual setup only (never tracked)

VPN and credential-bearing configuration is documented in [vpn-setup.md](vpn-setup.md) and must be configured per-machine:

| Item | Why not tracked |
|------|-----------------|
| `/etc/wireguard/wg0.conf` | Contains private key |
| `wg-quick@wg0.service` | References secret WireGuard config |
| `openvpn.service` + profiles | Contains credentials |
| `me.proton.vpn.split_tunneling.service` | Proton VPN managed config |
| `/etc/ssh/ssh_host_*_key` | Per-machine host private keys |

---

## Reference only (package-managed, not tracked)

| Item | Notes |
|------|-------|
| `nvidia-hibernate/resume/suspend.service` | Installed by NVIDIA drivers |
| Snap units (`snap-*`) | Managed by snapd |
| User systemd units (`~/.config/systemd/user/`) | GNOME/snap defaults |

---

## Machine-specific display config

Display layout is managed by **kanshi** (`~/.config/kanshi/config`) and the sway postswitch script (`~/.config/kanshi/postswitch.d/10-sway`). Adjust output names and positions when setting up on different monitor hardware.

---

## Resolved items

| Item | Resolution |
|------|------------|
| Stale `/home/blackboardd` paths | Templatized or removed |
| Stale `/home/brighten-tompkins` paths | Templatized with `{{ .chezmoi.homeDir }}` |
| NvIM `.luarc.json` packer paths | Replaced with minimal templated library paths |
| Ollama base unit bloated PATH | Replaced by llama-swap running as user with pinned GGUF models |

---

## Confirmation checklist (completed)

- [x] SSH hardening (port 9701)
- [x] GRUB config
- [x] llama-swap systemd unit + llama.cpp binaries
- [x] enabled-services.yaml (VPN units excluded)
- [x] WireGuard — **not tracked** (manual setup doc)
- [x] OpenVPN / Proton VPN — **not tracked** (manual setup doc)
- [x] kanshi + sway display layout
- [x] nvim .luarc.json cleanup

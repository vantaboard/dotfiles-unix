# System configuration audit

Review of system-level configuration for Ubuntu 24.04. This is a **public** repository — no secret-bearing files are tracked.

**Legend:** ✅ Tracked · 📋 Manual setup only · ❌ Never track

---

## Tracked in this repo

| Item | Location in repo | Deployed to |
|------|------------------|-------------|
| displays-resume.service | `home/system/systemd/displays-resume.service.tmpl` | `/etc/systemd/system/` |
| Dock hotplug udev rule | `home/system/udev/99-dock-hotplug.rules` | `/etc/udev/rules.d/` |
| hotplug_monitor.sh | `home/system/udev/hotplug_monitor.sh` | `/usr/local/bin/` |
| GRUB defaults | `home/system/grub/default` | `/etc/default/grub` |
| SSH pubkey-only config | `home/system/ssh/sshd_config.d/99-keyonly-port.conf` | `/etc/ssh/sshd_config.d/` |
| SSH socket port override | `home/system/ssh/ssh.socket.d/port.conf` | `/etc/systemd/system/ssh.socket.d/` |
| Ollama base unit (clean PATH) | `home/system/systemd/ollama.service` | `/etc/systemd/system/` |
| Ollama GPU tuning | `home/system/systemd/ollama.service.d/override.conf` | `/etc/systemd/system/ollama.service.d/` |
| keyd key remapping | `home/system/keyd/default.conf` | `/etc/keyd/default.conf` (Debian binary: `keyd.rvaiya`) |
| Sway Wayland session | `home/system/wayland-sessions/sway.desktop` | `/usr/share/wayland-sessions/sway.desktop` |
| Sway session wrapper | `home/system/bin/sway-session` | `/usr/local/bin/sway-session` (sources `wayland.conf` before exec) |
| GDM Wayland enable | `home/system/gdm3/custom.conf` | `/etc/gdm3/custom.conf` (with `sway_session` deploy) |
| Enabled services list | `home/.chezmoidata/enabled-services.yaml` | `systemctl enable` via script |
| Autorandr profiles | `home/dot_config/autorandr/docked-home/`, `undocked/` | `~/.config/autorandr/` |

Deploy and enable scripts:

- `home/run_onchange_after_deploy-system.sh.tmpl` — udev, systemd units, GRUB, SSH, keyd
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
| `ollama.service` | Local LLM server |
| `autorandr-lid-listener.service` | Laptop lid display switching |
| `autorandr.service` | Display profile management |
| `displays-resume.service` | Resume monitors after suspend |

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

| File | Status |
|------|--------|
| `~/.screenlayout/main.sh` | Tracked; hardware-specific `xrandr` geometry |
| `~/.screenlayout/main-one-monitor.sh` | Tracked; hardware-specific `xrandr` geometry |
| `~/.config/autorandr/docked-home/` | **Now tracked** |
| `~/.config/autorandr/undocked/` | **Now tracked** |

Screenlayout scripts remain hardware-specific. Adjust coordinates when setting up on different monitor hardware.

---

## Resolved items

| Item | Resolution |
|------|------------|
| Stale `/home/blackboardd` paths | Templatized or removed |
| Stale `/home/brighten-tompkins` paths | Templatized with `{{ .chezmoi.homeDir }}` |
| NvIM `.luarc.json` packer paths | Replaced with minimal templated library paths |
| Ollama base unit bloated PATH | Replaced with clean unit using system PATH only |

---

## Confirmation checklist (completed)

- [x] SSH hardening (port 9701)
- [x] GRUB config
- [x] Ollama override + clean base unit
- [x] enabled-services.yaml (VPN units excluded)
- [x] WireGuard — **not tracked** (manual setup doc)
- [x] OpenVPN / Proton VPN — **not tracked** (manual setup doc)
- [x] autorandr display profiles
- [x] nvim .luarc.json cleanup

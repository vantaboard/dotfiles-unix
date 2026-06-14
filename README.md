# dotfiles-unix

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), targeting Ubuntu 24.04 and Termux (Android).

## Fresh install

```bash
# Install chezmoi
sh -c "$(curl -fsSL https://get.chezmoi.io/lb)" -- -b ~/.local/bin

# Optional but recommended: gum powers the interactive setup wizard
# (the wizard will offer to install it if missing)
version=$(curl -fsSL https://api.github.com/repos/charmbracelet/gum/releases/latest \
  | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' | head -1)
mkdir -p ~/.local/bin
tmpdir=$(mktemp -d)
curl -fsSL "https://github.com/charmbracelet/gum/releases/download/v${version}/gum_${version}_Linux_x86_64.tar.gz" \
  | tar -xz -C "$tmpdir" --wildcards '*/gum'
install -m 755 "$tmpdir"/gum_*/gum ~/.local/bin/gum
rm -rf "$tmpdir"

# Clone this repo, then run the setup wizard (configures chezmoi source automatically)
git clone git@github.com:vantaboard/dotfiles-unix.git /tmp/dotfiles-unix
/tmp/dotfiles-unix/scripts/dotfiles-setup --apply

# Or from an existing clone:
./scripts/dotfiles-setup --apply
```

`dotfiles-setup --apply` writes `sourceDir` / `workingTree` in `~/.config/chezmoi/chezmoi.toml` when needed, so you do not need a separate `chezmoi init` step for local development.

The wizard lets you choose feature categories (shell, desktop, dev, system), individual packages and zsh plugins, and whether to save a global profile, host-specific overrides, or both. Selections are written to gitignored `profile.yaml` files and drive conditional templates so disabled plugins never get sourced.

**Profile auto-selection:** When no `profile.yaml` exists, chezmoi picks a base profile from the environment: [profile.example.yaml](home/.chezmoidata/profile.example.yaml) on Linux, [profile.termux.example.yaml](home/.chezmoidata/profile.termux.example.yaml) when `.chezmoi.os == "android"`. Explicit `profile.yaml`, `CHEZMOI_CI=1`, or `profile-host.yaml` overrides still take precedence (see [profile.tpl](home/.chezmoitemplates/profile.tpl)). Inspect the effective profile with:

```bash
chezmoi execute-template -f home/.chezmoitemplates/profile.tpl
```

### Wizard options

```bash
./scripts/dotfiles-setup              # interactive wizard (recommended or custom)
./scripts/dotfiles-setup --apply      # write profile + chezmoi apply
./scripts/dotfiles-setup --yes        # accept catalog defaults (non-interactive)
./scripts/dotfiles-setup --dry-run    # preview profile YAML
```

The interactive wizard offers **recommended** setup (catalog defaults, no checkbox drill-down) or **custom** setup to pick categories and features individually.

## Day-to-day usage

```bash
chezmoi apply          # Apply changes from source to home + run install scripts
chezmoi edit ~/.zshrc  # Edit a tracked file
chezmoi cd             # Open the source directory
chezmoi update         # Pull upstream and re-apply
./scripts/dotfiles-setup --apply  # Re-run wizard to change feature selections
```

## What gets installed automatically

| Step | Script | Action |
|------|--------|--------|
| Setup wizard | `scripts/dotfiles-setup` | Writes `profile.yaml` from [setup-catalog.yaml](home/.chezmoidata/setup-catalog.yaml) |
| Before dotfiles | `run_onchange_before_install-packages` | `apt install` (Linux) or `apt full-upgrade` + `apt install` (Android/Termux); Linux also installs `apt_manual` packages marked `install` |
| Dotfiles | chezmoi | Apply home config; fetch externals per profile |
| After dotfiles | `run_onchange_after_set-default-shell` | Termux: `chsh -s zsh` when zsh is enabled in profile |
| After dotfiles | `run_after_install-fzf` | Sync `~/.fzf/bin` with the git external (if fzf enabled) |
| After dotfiles | `run_onchange_after_install-tools` | mise (Termux `pkg` on Android, `mise.run` on Linux), fzf-tab (OMZ plugin), zsh-abbr (v6.3.3), trash-cli (git + venv), vivid (`.deb` on Linux / `pkg` on Termux); Linux also rust/zoxide via cargo when mise enabled |
| After dotfiles | `run_onchange_after_deploy-system` | systemd, GRUB, SSH, udev (if enabled) |
| After dotfiles | `run_onchange_after_enable-services` | `systemctl enable` for profile units |

Set `CHEZMOI_SKIP_SYSTEM_DEPLOY=1` to skip sudo system deploy (e.g. in containers).

### Tracking manually installed apt packages

After installing packages by hand, run [scripts/apt-manual-sync](scripts/apt-manual-sync) to discover new ones and record them in [apt-manual.yaml](home/.chezmoidata/apt-manual.yaml):

```bash
./scripts/apt-manual-sync scan      # add unseen manual packages as pending
./scripts/apt-manual-sync review    # mark each pending: install | ignore | keep pending
./scripts/apt-manual-sync list      # show tracked packages
./scripts/apt-manual-sync mark foo install
```

Entries are **append-only** (status changes, never deleted). Packages marked `install` are appended to chezmoi's `apt install` on apply. `ignore` keeps them tracked but out of automated install. Already-managed packages (`packages.yaml`, profiles) are skipped on scan.

## Termux / Android

On Termux, chezmoi reports `.chezmoi.os == "android"`. The Termux profile in [profile.termux.example.yaml](home/.chezmoidata/profile.termux.example.yaml) is **selected automatically** — no manual copy to `profile.yaml` required. Dotfile templates and git externals apply from that profile's `features:`; desktop/system run-scripts are Linux-only and no-op on Android. Package install uses the curated list in [packages.yaml](home/.chezmoidata/packages.yaml) (`packages.termux.pkg`), not the profile `packages:` array.

```bash
# Bootstrap Termux (full-upgrade before adding packages — partial upgrades break curl/openssl)
pkg update && apt full-upgrade -y
pkg install chezmoi git zsh openssh

git clone git@github.com:vantaboard/dotfiles-unix.git ~/Code/dotfiles-unix
chezmoi init --source="$HOME/Code/dotfiles-unix" --working-tree="$HOME/Code/dotfiles-unix"
chezmoi apply   # full-upgrade, installs packages, sets default shell to zsh (restart Termux after)
```

Verify OS detection and effective profile:

```bash
chezmoi execute-template '{{ .chezmoi.os }}'   # expect: android
chezmoi execute-template -f home/.chezmoitemplates/profile.tpl | head
```

To customize on Termux, write `home/.chezmoidata/profile.yaml` or `profile-host.yaml` (same as on Linux). If you ran `dotfiles-setup` on Termux, its `profile.yaml` is **merged** with the Termux profile — desktop/system flags stay off; shell tools (mise, vivid, fzf-tab, zsh-abbr) install via `run_onchange_after_install-tools`. The setup wizard targets Linux (x86_64 gum binary); prefer editing the Termux profile or a host override instead.

**Caveats on Termux:**

- **Default shell:** `chezmoi apply` runs Termux `chsh -s zsh` when the zsh feature is enabled. **Restart the Termux app** (not just `exec zsh`) so new sessions pick up `~/.termux/shell`.
- **Package upgrades:** Termux is rolling-release; never run bare `pkg install` / `pkg upgrade` on a stale system. Always `apt full-upgrade` first (chezmoi does this before installing dotfile packages). Partial upgrades desync `openssl`, `libcurl`, and `libngtcp2` and break `curl`/`git`.
- **Git / HTTPS clones:** If HTTPS git still fails after a full upgrade, use SSH (default via `~/.gitconfig`) or `apt reinstall openssl libngtcp2 libcurl curl git`.
- **Externals / plugins:** fzf-tab and zsh-abbr install via `run_onchange_after_install-tools` (not chezmoi externals). Re-run `chezmoi apply` if they fail to load; ensure GitHub SSH or HTTPS git works.
- **fzf binary:** `run_after_install-fzf` is Linux-only. The git external `~/.fzf` is still fetched; rely on `pkg install fzf` (included in the Termux package list) rather than `~/.fzf/bin/fzf`.
- **trash-cli:** Installed via `run_onchange_after_install-tools` (git clone + Python venv; `trash-*` in `~/.local/bin`). On Termux, psutil is installed from the `python-psutil` pkg when available, otherwise built from source with Termux’s [Android patch](https://github.com/termux/termux-packages/blob/master/packages/python-psutil/android.patch). Some volume-scan commands may need `TRASH_VOLUMES=$PWD` — see [trash-cli#348](https://github.com/andreafrancia/trash-cli/issues/348).
- **Powerlevel10k:** Install a Nerd Font in the Termux app (e.g. `~/.termux/font.ttf` + `termux-reload-settings`) for prompt icons.
- **mise:** Termux only — `pkg install mise` ([termux-packages#29075](https://github.com/termux/termux-packages/pull/29075)). Do **not** use `curl https://mise.run` on Android (produces unrunnable glibc binaries). `install-tools` removes any broken `~/.local/bin/mise` and installs via pkg only. If `pkg install mise` fails, your mirror may lag — run `termux-change-repo` or wait for sync. Set `mise: false` in profile until pkg works. Linux uses `mise.run` as usual.
- **xclip / desktop / system:** Leave disabled in the Termux profile; no X11, systemd, or GRUB on Android.

## CI / E2E testing

```bash
docker build -f Dockerfile.test -t dotfiles-e2e .
docker run --rm dotfiles-e2e
```

CI uses the committed minimal profile in [profile-ci.yaml](home/.chezmoidata/profile-ci.yaml).

## System config and VPN

- [docs/system-audit.md](docs/system-audit.md) — what system config is tracked vs manual
- [docs/vpn-setup.md](docs/vpn-setup.md) — WireGuard/OpenVPN/Proton setup (never committed to this public repo)

## Repo layout

```
.chezmoiroot              → "home"
home/                     → chezmoi source state (dot_* files)
home/.chezmoidata/        → setup-catalog, profiles, apt-manual.yaml
scripts/apt-manual-sync   → track manual apt installs for chezmoi
scripts/dotfiles-setup    → interactive setup wizard
.github/workflows/        → CI
tests/                    → smoke tests and lint
docs/                     → system config audit
```

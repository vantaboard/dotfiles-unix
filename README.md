# dotfiles-unix

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), targeting Ubuntu 24.04.

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
| Before dotfiles | `run_onchange_before_install-packages` | `apt install` from profile package list |
| Dotfiles | chezmoi | Apply home config; fetch externals per profile |
| After dotfiles | `run_onchange_after_install-tools` | mise, rust, zoxide (if enabled in profile) |
| After dotfiles | `run_onchange_after_deploy-system` | systemd, GRUB, SSH, udev (if enabled) |
| After dotfiles | `run_onchange_after_enable-services` | `systemctl enable` for profile units |

Set `CHEZMOI_SKIP_SYSTEM_DEPLOY=1` to skip sudo system deploy (e.g. in containers).

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
home/.chezmoidata/        → setup-catalog, profile.example, profile-ci
scripts/dotfiles-setup    → interactive setup wizard
.github/workflows/        → CI
tests/                    → smoke tests and lint
docs/                     → system config audit
```

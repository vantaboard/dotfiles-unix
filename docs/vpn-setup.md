# VPN setup (manual, not tracked)

This is a **public** dotfiles repository. VPN credentials, private keys, and provider-specific configs are **never** committed here.

Configure VPN on each machine manually after running `chezmoi apply`.

## WireGuard

1. Install the package: `sudo apt install wireguard`
2. Create `/etc/wireguard/wg0.conf` with your provider's config (contains a private key — keep local only).
3. Enable the interface: `sudo systemctl enable --now wg-quick@wg0`

Do not add `wg0.conf` or WireGuard keys to this repo.

## OpenVPN

1. Install: `sudo apt install openvpn`
2. Place your `.ovpn` profile and credentials under `/etc/openvpn/` or `~/.config/openvpn/` per your provider's instructions.
3. Enable: `sudo systemctl enable --now openvpn@<profile-name>`

## Proton VPN

Proton VPN manages its own systemd units (`me.proton.vpn.*`) via the official app. Install from [protonvpn.com](https://protonvpn.com/) and configure split tunneling in the GUI — nothing from that setup belongs in this repo.

## SSH host keys

Never copy `/etc/ssh/ssh_host_*_key` between machines. Let `openssh-server` generate fresh host keys on each install.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Rebuild local system
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### Test without switching (build only)
```bash
nixos-rebuild build --flake .#<hostname>
```

### Deploy to remote host
```bash
./deploy.sh <hostname>         # single host
./deploy.sh host1,host2        # multiple hosts (comma-separated)
```

### Update flake inputs
```bash
nix flake update
nix flake update <input-name>  # update a specific input
```

### Enter dev shell
```bash
nix develop
```

## Architecture

### Entry Point

`flake.nix` defines all system configurations. Two builder functions are used:
- `mkSystem` — single user (`maltalef`) machines
- `mkSystem_wk` — multi-user machines (`maltalef` + `mw`), currently only `mw420`

### Hosts

Each host lives in `hosts/<hostname>/`. Hosts share common modules from `hosts/common/` and selectively import optional modules from `hosts/common/optional/` (bluetooth, hyprland, pipewire, grub, etc.).

| Hostname | Machine | Notes |
|----------|---------|-------|
| `c64`    | Main desktop (Intel CPU, NVIDIA GPU) | |
| `c128`   | Lenovo ThinkPad X1 Carbon | fingerprint auth |
| `vic20`  | Dell Latitude 5480 (Intel 7th gen) | |
| `kim1`   | Home server (Phenom II X4 945) | |
| `mw420`  | Work ThinkPad E14 AMD | dual-user |

### Home Manager

Home-manager is integrated at the system level (`home-manager.nixosModules.home-manager`). Each user has:
- A `home/<user>/global.nix` — imported by all host configs for that user
- A `home/<user>/<hostname>.nix` — host-specific overrides that import global + additional features

Features are organized under `home/<user>/features/`:
- `cli/` — shell tools (zsh, tmux, nvim, git, gpg, nushell, starship, etc.)
- `desktop/common/` — shared desktop apps (alacritty, firefox, dunst, zathura, xdg, etc.)
- `desktop/hyprland/` — Hyprland compositor stack (waybar, wofi, hyprlock, hypridle, swaync, hyprpaper)
- `desktop/leftwm/` — X11 tiling WM (legacy/alternative)
- `games/` — Steam and gaming setup
- `emacs/` — Emacs configuration
- `tex/` — LaTeX tooling

### Secrets

SOPS-nix is used for secrets management. Keys are configured in `.sops.yaml` (PGP for `maltalef`, age keys per host). Secrets files live under `hosts/<hostname>/secrets/`.

### Overlays & Custom Packages

- `overlays/` — extends nixpkgs; imports custom packages from `pkgs/`
- `pkgs/` — custom packages and scripts (screenshot tools, etc.)

### Color Scheme

`nix-colors` (input) provides theming. Default scheme is `gruvbox-dark-hard`, set in `home/<user>/global.nix` and propagated via `config.colorScheme` to all modules.

### Key Flake Inputs

- `nixpkgs` → `nixos-unstable`
- `home-manager` follows nixpkgs
- `hyprland`, `hyprlock`, `hyprgrass`, `hyprspace`, `hyprpaper` — Wayland compositor ecosystem (each follows hyprland's nixpkgs)
- `sops-nix` — secrets
- `nix-gaming` — gaming optimizations
- `nix-minecraft` — Minecraft server support
- `firefox-addons` — declarative Firefox extensions

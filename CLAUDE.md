# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This repository is public. Work-related configuration does not belong here: it lives in the private `infra` input
(see below). Don't add employer domains, IPs, hostnames or internal names to any file, comment or commit message.

## Common Commands

### Build (the way to verify a change)
```bash
nixos-rebuild build --flake .#pirincho
```
From a sandboxed agent, if nix fails with "unable to open database file" on `~/.cache/nix/fetcher-cache-v4.sqlite`,
run it with `XDG_CACHE_HOME=/tmp/<dir>`.

### Switch the live system (the operator does this, not agents)
```bash
doas nixos-rebuild switch --flake .#pirincho
```
`sudo` is disabled: privilege escalation is doas (`hosts/common/doas.nix`), with `doas-sudo-shim` so tools that
call `sudo` still work.

### Checks
```bash
nix build .#checks.x86_64-linux.tema       # the theme and maltalef's desktop on pirincho
nix build .#checks.x86_64-linux.hyprland   # VM test: pirincho's Hyprland, plugin, hyprland.conf, hyprlock
nix flake check --no-build --keep-going    # evaluation only
```
Run the checks one by one. `nix flake check` reports two failures that predate everything else: `c64` (see Hosts)
and `devShells` (`shell.nix` returns a `mkShell` derivation, not `{ default = …; }`, so `nix develop` doesn't work
either; use `nix-shell`).

### Test browsers and the trial VM
```bash
nix run .#firefox-prueba          # Firefox with native vertical tabs, Tridactyl, dense CSS (pkgs/firefox-prueba)
nix run .#qutebrowser-prueba      # qutebrowser with tree tabs and tab groups (pkgs/qutebrowser-prueba)
nixos-rebuild build-vm --flake .#prueba-pirincho
```
Both browsers read `nixosConfigurations.pirincho` (its theme) and need no switch. The qutebrowser patches are rebased
on qutebrowser 3.7.0: a newer nixpkgs qutebrowser will likely need them rebased.

### Comparing builds
`hosts/common/nix.nix` puts every input, `self` included, in `nix.registry`, so pirincho's toplevel `drvPath`
changes with **any** commit (`etc-nix-registry.json`). To check that a refactor changes nothing, compare with
`nix-diff` and discount that file.

### Update flake inputs (the operator does this)
```bash
nix flake update
nix flake update <input-name>
```

### Deploy to a remote host
`./deploy.sh <host>[,<host>…]` runs `nixos-rebuild switch --target-host`. It's not used today: no remote host is
alive, and `trusted-users` is root only (see the comment in `hosts/common/nix.nix`).

## Architecture

### Entry Point

`flake.nix` defines all system configurations. Two builder functions are used:
- `mkSystem` — single user (`maltalef`) machines
- `mkSystem_wk` — multi-user machines (`maltalef` + `mw`), currently only `pirincho`

Besides `nixosConfigurations`, the flake exports `overlays`, `packages`, `checks`, `homeManagerModules.tema` and a
`devShells` that doesn't work (see Checks).

### Hosts

Each host lives in `hosts/<hostname>/`. Hosts share common modules from `hosts/common/` (locale, mdns, nix, openssh,
doas, users) and selectively import optional modules from `hosts/common/optional/` (bluetooth, hyprland, pipewire,
networkmanager, fprintd, gdm, impresion, keychron, etc.).

| Hostname | Machine | State |
|----------|---------|-------|
| `pirincho` | Work ThinkPad, AMD (ex `mw420`; nixos-hardware `lenovo-thinkpad-t14-amd-gen2`) | **alive**, builds; dual-user |
| `prueba-pirincho` | pirincho in a VM (`pirincho.extendModules` with the `infra` trial module) | builds |
| `c128` | Lenovo ThinkPad X1 Carbon | evaluates; not in use |
| `c64` | Main desktop (Intel CPU, NVIDIA GPU) | doesn't evaluate: needs `hardware.nvidia.open` set |
| `vic20` | Dell Latitude 5480 (Intel 7th gen) | commented out in `flake.nix` |
| `kim1` | Home server (Phenom II X4 945) | commented out in `flake.nix` |

pirincho specifics: `hosts/pirincho/firewall.nix` (firewall on and sshd off; it accepts only ESP and the DHCP/DNS of
NetworkManager's shared connections), `nix-security-box/`
(security tooling package sets), and the work profile from `infra` (`hosts/pirincho/default.nix` imports it and sets
its options).

### The `infra` input (private)

Everything work-related on pirincho (network, VPN, identity, the work tools, the agents' launcher, the boot splash
module, a second theme palette, the trial VM module) comes from `infra`: a private flake, the `nixos/` directory of a
local repository, pinned by rev in `flake.nix` (`git+file:`, not fetchable from a clone of this repo). It's not
added here: changes go to that repository.
- Pinned to a rev of its `origin/main`, never its local main. To bump: set the rev in `flake.nix` and run
  `nix flake lock` (it only touches the `infra` node).
- To iterate on an uncommitted infra change:
  `--override-input infra 'git+file:///home/maltalef/documents/infra?dir=nixos'` (in zsh, as separate arguments,
  not inside a variable).
- Only `pirincho`, `prueba-pirincho`, the test browsers and the checks need it. The other hosts evaluate without it:
  `hosts/common/nix.nix` lists `infra` in `nix.registry` only on hosts that import its modules.

### Home Manager

Home-manager is integrated at the system level (`home-manager.nixosModules.home-manager`, `useGlobalPkgs`). Each user
has:
- A `home/<user>/global.nix` — imported by all host configs for that user
- A `home/<user>/<hostname>.nix` — host-specific overrides that import global + additional features

maltalef's features under `home/maltalef/features/`:
- `cli/` — zsh, nvim, tmux, git, gpg, ssh, pass, starship, superfile; `optional/claude-swap.nix`
- `desktop/common/` — foot, firefox (+ `firefox-tema.nix`), zathura, fonts, mimeapps, xdg; `optional/` (batsignal,
  piper, network). birdtray, dragon, redshift, rofi and unclutter are X11 leftovers, not imported.
- `desktop/hyprland/` — Hyprland (with `animaciones.nix`), waybar (+ `vpn.nix`), fuzzel, hyprlock, hypridle,
  hyprsunset, hyprpaper, swaync, tessen, clipse, `laptop-scale.nix`
- `emacs/`, `games/` (Steam), `tex/`

`home/mw/` has its own, older tree (alacritty, wofi, its own waybar and swaync).

### Theme

`modules/tema/` is exported as `homeManagerModules.tema` and imported by `home/maltalef/global.nix`. It's off by
default and enabled per host (pirincho): `tema = { enable; paleta; fondo.imagen; }`. Palettes live in
`tema.paletas.<name>` (open to other modules); `gruvbox-verde` (gruvbox-dark-hard with a green accent,
`modules/tema/gruvbox-verde.nix`) is the default and the only one here. With the theme on, the palette's nix-colors
scheme becomes the user's `colorScheme`, overriding the `mkDefault` gruvbox-dark-hard of `global.nix`; desktop tools
read `config.tema.colores` and `config.colorScheme.palette`. mw doesn't use the theme.

### Secrets

No secrets are managed by this repo. `.sops.yaml`, `hosts/common/sops.nix` and `hosts/common/secrets.yaml` are
leftovers: nothing imports sops-nix. Never put secrets (keys, passwords, keytabs) in the repo or the Nix store.

### Overlays & Custom Packages

- `overlays/default.nix` — `additions` (everything in `pkgs/`) and `modifications`: Hyprland and waybar with local
  patches, the split-monitor-workspaces plugin, a test skip for sh4d0wup.
- `pkgs/` — `scripts/` (hyprshot-*, hypr-*, hyprlock-lock, pass-otp-add, mdview, start-hyprland-login…),
  `claude-swap` (built from the `claude-swap` input), and the test browsers `firefox-prueba` and `qutebrowser-prueba`
  (exported as packages from `flake.nix`, not through the overlay, because they read pirincho).

### Key Flake Inputs

- `nixpkgs` → `nixos-unstable`
- `home-manager` follows nixpkgs
- `hardware` — nixos-hardware profiles
- `nix-colors` — base16 schemes (used by the theme and `global.nix`)
- Hyprland comes from nixpkgs, not from an input: `overlays/default.nix` patches `pkgs.hyprland` (with `withUWSM = false`), so `programs.hyprland`, home-manager, the portal and plugins all share one derivation, with the system's glibc and mesa. An input with its own nixpkgs (the old `hyprland` input) made Hyprland crash loading the system mesa.
- `split-monitor-workspaces` — plugin source only (`flake = false`), built with `hyprlandPlugins.mkHyprlandPlugin` in the overlay; bump in tandem with nixpkgs' Hyprland series
- `hyprlock` — follows nixpkgs
- `firefox-addons` — declarative Firefox extensions
- `claude-swap` — `git+file` to a local checkout, source only
- `infra` — private, see above
- Unused: `nixpkgs-unstable` (only in a commented-out overlay), `sops-nix`, `nix-gaming`; `nix-minecraft` only by
  `kim1`.

# NixOS Configuration

My NixOS and home-manager configuration, as a flake: Hyprland on `nixos-unstable`, with home-manager at the system
level and a small theme module of my own.

## Hosts

| Host | Machine | State |
|------|---------|-------|
| `pirincho` | ThinkPad, AMD (work laptop; users `maltalef` and `mw`) | in use |
| `prueba-pirincho` | `pirincho` in a VM | for trying changes |
| `c128` | ThinkPad X1 Carbon | evaluates, not in use |
| `c64` | Desktop, Intel + NVIDIA | needs `hardware.nvidia.open` set |
| `vic20`, `kim1` | Dell Latitude 5480, an old home server | commented out in `flake.nix` |

## Layout

- `flake.nix` — inputs, the host builders, and the flake's outputs.
- `hosts/<host>/` — each machine; `hosts/common/` is shared, `hosts/common/optional/` is picked per host.
- `home/<user>/` — home-manager: `global.nix`, one `<host>.nix` per machine, and `features/` (cli, desktop, emacs,
  games, tex).
- `modules/tema/` — the desktop theme (`homeManagerModules.tema`): palettes with named colours, fonts, wallpaper,
  GTK/Qt/icons and an nvim colorscheme. The default palette is gruvbox-dark-hard with a green accent.
- `overlays/`, `pkgs/` — patched Hyprland and waybar, the split-monitor-workspaces plugin, and small scripts.
- `checks/` — a theme check and a VM test of the Hyprland setup.

## Usage

```bash
nixos-rebuild build --flake .#pirincho          # build
doas nixos-rebuild switch --flake .#pirincho    # switch (sudo is disabled; doas instead)
nix build .#checks.x86_64-linux.tema
nixos-rebuild build-vm --flake .#prueba-pirincho
```

## The `infra` input

`pirincho` takes its work profile from the `infra` input, a private flake pinned by rev (`git+file:`, not fetchable
from a clone). Only `pirincho`, `prueba-pirincho`, the test browsers (`firefox-prueba`, `qutebrowser-prueba`) and the
checks need it: the other hosts evaluate without it (`nix.registry` lists `infra` only on hosts that import its
modules).

## Ideas

+ [xidlehook](https://nix-community.github.io/home-manager/options.html#opt-services.xidlehook.enable)
+ vdirsyncer (todo: find corresponding documentation)
+ tailscale, headscale: mesh netwoking between all defined hosts

{ lib, writeShellApplication, hyprlock, coreutils, gnused, procps, systemd }:
(writeShellApplication {
  name = "hyprlock-lock";
  # systemd por busctl/loginctl, procps por pgrep; hyprlock es overrideable
  # para envolver el mismo paquete que programs.hyprlock (el del flake).
  runtimeInputs = [ hyprlock coreutils gnused procps systemd ];
  text = builtins.readFile ./hyprlock-lock;
}) // {
  meta = with lib; {
    description = "Screen lock wrapper that mirrors the lock state to the logind LockedHint";
    platforms = platforms.linux;
  };
}

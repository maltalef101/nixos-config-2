{ lib, writeShellApplication, jq, socat, coreutils, fuzzel, libnotify }:
(writeShellApplication {
  name = "hypr-pantallas";
  # hyprctl no va en runtimeInputs: tiene que ser el del hyprland corriendo
  # (el del flake, en el PATH de la sesión), no el de nixpkgs.
  runtimeInputs = [ jq socat coreutils fuzzel libnotify ];
  text = builtins.readFile ./hypr-pantallas;
}) // {
  meta = with lib; {
    description = "Per-station monitor layout for Hyprland: a fuzzel menu to place each external monitor, and a watcher that reapplies it on hotplug";
    platforms = platforms.linux;
  };
}

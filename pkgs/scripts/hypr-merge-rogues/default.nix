{ lib, writeShellApplication, jq, socat, coreutils }:
(writeShellApplication {
  name = "hypr-merge-rogues";
  # hyprctl no va en runtimeInputs: tiene que ser el del hyprland corriendo
  # (el del flake, en el PATH de la sesión), no el de nixpkgs.
  runtimeInputs = [ jq socat coreutils ];
  text = builtins.readFile ./hypr-merge-rogues;
}) // {
  meta = with lib; {
    description = "Merge rogue split-monitor-workspaces windows into the surviving monitor's set on monitor disconnect";
    platforms = platforms.linux;
  };
}

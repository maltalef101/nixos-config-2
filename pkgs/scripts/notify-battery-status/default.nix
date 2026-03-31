{ lib, writeShellApplication, makeWrapper, }:
(writeShellApplication {
  name = "notify-battery-status";
  runtimeInputs = [ systemd notify-send bash jq];
  text = builtins.readFile ./notify-battery-status;
}) // {
  meta = with lib; {
    description = "Trigger Low-battery notification on all graphical users";
    platforms = platforms.all;
  };
}

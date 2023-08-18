{ pkgs, lib, ... }:
let
  commands = {
    shutdown = lib.mkDefault "${pkgs.systemd}/bin/systemctl shutdown";
    reboot = lib.mkDefault "reboot";
  };
in {
  services.greetd = {
    enable = true;
    settings.default_session.command = lib.mkDefault ''
      ${pkgs.greetd.tuigreet}/bin/tuigreet --time --rememeber-session --power-shutdown "${commands.shutdown}" --power-reboot "${commands.reboot}"'';
  };
}

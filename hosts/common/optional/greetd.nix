{ pkgs, lib, ... }:
let
  commands = {
    shutdown = "${pkgs.systemd}/bin/systemctl shutdown";
    reboot = "reboot";
  };
in {
  services.greetd = {
    enable = true;
    settings.default_session.command = ''
      ${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember-session --power-shutdown "${commands.shutdown}" --power-reboot "${commands.reboot}"'';
  };
}

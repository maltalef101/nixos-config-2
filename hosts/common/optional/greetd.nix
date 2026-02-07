{ pkgs, lib, config, ... }:
let
  commands = {
    shutdown = "${pkgs.systemd}/bin/systemctl shutdown";
    reboot = "reboot";
  };

  dbus-run-session = lib.getExe' pkgs.dbus "dbus-run-session";
  hyprland = lib.getExe config.programs.hyprland.package;
  hyprland-conf = pkgs.writeText "greetd-hyprland.conf" ''
	bind = SUPER SHIFT, E, killactive

	misc {
	  disable_hyprland_logo = true
	}

	animations {
	  enabled = true
	}

	exec-once = ${lib.getExe config.programs.regreet.package}; hyprctl dispatch exit
  '';
in {
  config.programs.regreet = {
	enable = true;

	iconTheme.name = "Papirus-Dark";
	iconTheme.package = pkgs.papirus-icon-theme;

	theme.name = "Gruvbox-Dark";
	theme.package = pkgs.gruvbox-gtk-theme;

	cursorTheme.name = "capitaine-cursors";
	cursorTheme.package = pkgs.capitaine-cursors;

	settings = {
	  appearance = {
		greeting_msg = "Login to ${config.system.name}";
		application_prefer_dark_theme = true; 
	  };
	};
  };

  config.services.greetd = {
    enable = true;
	#settings.default_session.command = "${dbus-run-session} ${hyprland} --config ${hyprland-conf} &> /dev/null";
    #settings.default_session.command = ''
    #  ${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember-session --power-shutdown "${commands.shutdown}" --power-reboot "${commands.reboot}"'';
  };

  config.environment.etc."greetd/environments".text = ''
  start-hyprland
  '';
}

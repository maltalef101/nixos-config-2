{ pkgs, ... }: {
  programs.emacs = {
    package = pkgs.emacs;
    enable = true;
  };

  services.emacs = {
	enable = true;
  };

  systemd.user.services.emacs = {
	Unit = {
		After = [ "network-online.target" ];
		Wants = [ "network-online.target" ];
	};
  };

  xdg.configFile."emacs" = {
    source = ./config;
    recursive = true;
  };
}

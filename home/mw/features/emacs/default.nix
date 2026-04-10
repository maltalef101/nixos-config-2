{ pkgs, ... }: {
  programs.emacs = {
    package = pkgs.emacs;
    enable = true;
  };

  services.emacs = {
	enable = true;
  };

  xdg.configFile."emacs" = {
    source = ./config;
    recursive = true;
  };

  home.packages = with pkgs; [
   (aspellWithDicts (
	dicts: with dicts; [
		es
	]
   ))
  ];
}

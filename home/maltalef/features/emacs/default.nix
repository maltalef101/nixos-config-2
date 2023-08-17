{
  programs.emacs.enable = true;

  xdg.configFile."emacs" = {
    source = ./config;
	recursive = true;
  };
}

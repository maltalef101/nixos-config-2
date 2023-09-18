{ pkgs, ... }: {
  programs.emacs = {
    package = pkgs.emacs29;
    enable = true;
  };

  xdg.configFile."emacs" = {
    source = ./config;
    recursive = true;
  };
}

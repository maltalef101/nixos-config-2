{ pkgs, ... }: {
  programs.emacs = {
    package = pkgs.emacs;
    enable = true;
  };

  xdg.configFile."emacs" = {
    source = ./config;
    recursive = true;
  };
}

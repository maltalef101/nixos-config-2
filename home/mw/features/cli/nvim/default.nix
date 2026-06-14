{
  programs.neovim = {
    enable = true;

    withRuby = false;
    withPython3 = false;
  };
  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}

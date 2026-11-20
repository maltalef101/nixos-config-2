{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    withRuby = false;
    withPython3 = false;

    # El colorscheme: gruvbox.nvim tal cual (init.lua lo configura)
    plugins = [ pkgs.vimPlugins.gruvbox-nvim ];
  };
  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}

{ pkgs, lib, config, ... }:
let
  tema = config.tema;

  # Con el tema (pirincho): la misma configuración, con el colorscheme de la
  # paleta (generado por tema.nvim: gruvbox-verde, u otra) en lugar de
  # gruvbox.vim. Si no, ./config tal cual, en
  # gruvbox, como siempre.
  gruvbox = "vim.cmd('source ~/.config/nvim/gruvbox.vim')";
  init = builtins.readFile ./config/init.lua;
  initTema =
    if !(lib.hasInfix gruvbox init)
    then throw "nvim: init.lua ya no carga gruvbox con `${gruvbox}`: revisá cómo elige el colorscheme con el tema"
    else builtins.replaceStrings [ gruvbox ] [ "vim.cmd.colorscheme('${tema.paleta}')" ] init;

  configTema = pkgs.runCommand "nvim-config-${tema.paleta}" { init = initTema; passAsFile = [ "init" ]; } ''
    cp -r ${./config} $out
    chmod -R u+w $out
    rm $out/gruvbox.vim
    cp $initPath $out/init.lua
    mkdir $out/colors
    ln -s ${tema.nvim}/colors/${tema.paleta}.lua $out/colors/${tema.paleta}.lua
  '';
in
{
  programs.neovim = {
    enable = true;

    withRuby = false;
    withPython3 = false;
  };
  xdg.configFile."nvim" = {
    source = if tema.enable then configTema else ./config;
    recursive = true;
  };
}

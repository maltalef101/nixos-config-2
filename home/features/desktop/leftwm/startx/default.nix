{ pkgs, config, ... }: {
  home.packages = [ pkgs.xorg.xinit ];

  home.file.".xinitrc".text = ". ${config.home.homeDirectory}/${config.xsession.scriptPath}";
}

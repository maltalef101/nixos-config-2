{ pkgs, ... }: {
  home.packages = [ pkgs.xorg.xinit ];

  home.file.".xinitrc".source = ./config/xinitrc;
  home.file.".xprofile".source = ./config/xprofile;
}

{ pkgs, lib, config, ... }:
let homeDirectory = config.users.users.maltalef.home;
in {
  xdg.userDirs = lib.mkDefault {
    enable = true;
    documents = "${homeDirectory}/documents";
    downloads = "${homeDirectory}/downloads";
    videos = "${homeDirectory}/videos";
    music = "${homeDirectory}/music";
    pictures = "${homeDirectory}/pictures";
    desktop = "${homeDirectory}/desktop";
    publicShare = "${homeDirectory}/public";
    templates = "${homeDirectory}/templates";
  };
}

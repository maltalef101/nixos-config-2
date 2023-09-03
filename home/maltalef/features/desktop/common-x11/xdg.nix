{ pkgs, lib, config, ... }:
let homeDirectory = config.home.homeDirectory;
in {
  xdg.userDirs = lib.mkDefault {
    enable = true;
    createDirectories = true;
    documents = "${homeDirectory}/documents";
    download = "${homeDirectory}/downloads";
    videos = "${homeDirectory}/videos";
    music = "${homeDirectory}/music";
    pictures = "${homeDirectory}/pictures";
    desktop = "${homeDirectory}/desktop";
    publicShare = "${homeDirectory}/public";
    templates = "${homeDirectory}/templates";
  };
}

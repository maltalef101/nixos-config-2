{ pkgs, config, lib, ... }:
let
  asap-pub = "${config.home.homeDirectory}/.ssh/asap";
in {
  home.file.".ssh/asap.pub".source = ./asap.pub;

	programs.ssh = {
    matchBlocks = {
      asap-gh = {
        host = "asap.gh";
        hostname = "github.com";
        identityFile = asap-pub;
        identitiesOnly = true;
        user = "git";
        port = 22;
      };

      asap-xpdev = {
        host = "asap-xp-dev.com";
        hostname = "asaptech.xp-dev.com";
        user = "asap-maltalef";
        identityFile = asap-pub;
        identitiesOnly = true;
      };
    };
	};
}

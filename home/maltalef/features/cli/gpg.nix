{ pkgs, config, lib, ... }:
let
  pinentry =
    if config.gtk.enable then {
      packages = [ pkgs.pinentry-gnome3 pkgs.gcr ];
	  package = pkgs.pinentry-gnome3;
      name = "gnome3";
    } else {
      packages = [ pkgs.pinentry-curses ];
	  package = pkgs.pinentry-curses;
      name = "curses";
    };
in
{
  home.packages = pinentry.packages;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [
      "3141D25FCB21C3C5983FDC7F0AF6A3B35EC98BDE" # subclave [A] mw420
      "E294C66794E9E22191FB6634752EAA9E7D7DF411" # subclave [A] c128
      "64066B720D8F296B5354D4F04860E35BED9412E8" # subclave [A] nistp256 (servicio ECDSA)
      "6D8AFDC9A44712E1DC4D6549FFB7FB2D9B1A751B" # ~/.ssh/id_rsa (maltalef@c64)
      "E92249E0C38B55DBEF53420C63301B0EF83F070E" # ~/.ssh/id_ecdsa (maltalef@mw420)
      "53674FE15AD57618B2D3937F1526B8C1900EBBDE" # ~/.ssh/id_ed25519 (maltalef@mw420)
    ];
    pinentry.package = pinentry.package;
    #enableExtraSocket = true;
  };

  programs.gpg = {
    enable = true;
	  homedir = "${config.xdg.dataHome}/gnupg";
    settings.trust-model = "tofu+pgp";

	publicKeys = [
		{
			source = ../../pgp.asc;
			trust = 5;
		}
	];
  };

  #  systemd.user.services = {
  #    # Link /run/user/$UID/gnupg to ~/.gnupg-sockets
  #    # So that SSH config does not have to know the UID
  #    link-gnupg-sockets = {
  #      Unit = {
  #        Description = "link gnupg sockets from /run to /home";
  #      };
  #      Service = {
  #        Type = "oneshot";
  #        ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
  #        ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
  #        RemainAfterExit = true;
  #      };
  #      Install.WantedBy = [ "default.target" ];
  #    };
  #  };
}
  # vim: filetype=nix

{ inputs, outputs, config, lib, ... }: {
  imports = [
    ./global.nix
    ./features/desktop/leftwm
    ./features/desktop/common-x11/optional/piper.nix
    ./features/emacs
    ./features/games

    ./features/asap # werk
  ];

  systemd.user.tmpfiles.rules = [
    "L ${config.home.homeDirectory}/storage - - - - /var/lib/mount/storage"
	  "L ${config.home.homeDirectory}/music - - - - /var/lib/mount/storage/00music/hifi"
  ];
}

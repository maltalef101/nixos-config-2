{ inputs, outputs, lib, ... }: {
  imports = [
    ./global.nix
    ./features/desktop/leftwm
    ./features/desktop/common-x11/optional/piper.nix
    ./features/emacs
    ./features/games

    ./features/asap # werk
  ];

  systemd.user.tmpfiles.rules = [
    "L %h/storage - - - - /var/lib/mount/storage"
	"L %h/music - - - - /var/lib/mount/storage/00music/hifi"
  ];
}

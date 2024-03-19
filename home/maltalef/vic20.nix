{ inputs, outputs, lib, ... }: {
  imports = [
    ./global.nix
    ./features/desktop/leftwm
    ./features/desktop/common-x11/optional/piper.nix
    ./features/desktop/common-x11/optional/network.nix
    ./features/emacs
    ./features/games
	./features/tex

    ./features/asap # werk
  ];
}

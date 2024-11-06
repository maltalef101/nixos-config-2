{ inputs, outputs, lib, ... }: {
  imports = [
    ./global.nix
    #./features/desktop/leftwm
    ./features/desktop/hyprland
    ./features/desktop/common/optional/piper.nix
    ./features/desktop/common/optional/network.nix
    ./features/emacs
    ./features/games
	./features/tex
  ];
}

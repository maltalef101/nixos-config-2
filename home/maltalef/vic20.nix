{ inputs, outputs, ...}: {
  imports = [
    ./global.nix
    ./features/desktop/leftwm
	./features/emacs
  ];
}

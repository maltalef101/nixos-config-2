{ pkgs, ... }: {
  imports = [ ./git.nix ./ssh.nix ./nushell ./nvim ./tmux.nix ./starship.nix ];

  home.packages = with pkgs; [
    bc # Calclator
    bottom # System resource viewer
    ncdu # Nicer disk usage
    exa # Better ls
    ripgrep # Better (and faster) grep
    fd # Better find
    httpie # Better curl
    nixfmt # For formatting nix files
	bandwhich # Bandwidth utilization tool
  ];
}

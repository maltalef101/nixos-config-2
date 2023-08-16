{ inputs, lib, pkgs, config, outputs, ...}:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule
    ./features/cli
  ];

  nixpkgs = {
    # overlays = { };
    config.allowUnfree = true;
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    };
  };
  
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "maltalef";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
  };
	
	colorscheme = lib.mkDefault colorSchemes.gruvbox-dark-hard;
  home.file.".colorscheme".text = config.colorscheme.slug;
}

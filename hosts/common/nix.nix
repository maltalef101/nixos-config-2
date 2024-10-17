{ inputs, lib, ...}:
{
  nix = {
    settings = {
      allowed-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

	  substituters = [ "https://hyprland.cachix.org" ];
	  trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };

    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
  };
}

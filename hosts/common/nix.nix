{ inputs, lib, ...}:
{
  nix = {
    settings = {
      allowed-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" "nix-repl" ]:
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };

    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    nixPath = [ "nixpkgs=${input.nixpkgs.outPath}" ];
  };
}

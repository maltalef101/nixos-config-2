{
  description = "maltalef's NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
	nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
    sops-nix.url = "github:mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

	aquamarine = {
		type = "git";
		url = "https://github.com/hyprwm/aquamarine";
		ref = "refs/tags/v0.4.3";
		submodules = true;
		inputs.nixpkgs.follows = "nixpkgs-unstable";
	};

	hyprland = {
		type = "git";
		url = "https://github.com/hyprwm/Hyprland";
		ref = "refs/tags/v0.42.0";
		submodules = true;
		inputs.nixpkgs.follows = "nixpkgs";
		#inputs.aquamarine.follows = "aquamarine";
	};

	hyprlock = {
		url = "github:hyprwm/hyprlock";
		inputs.nixpkgs.follows = "nixpkgs";
	};

	nix-gaming.url = "github:fufexan/nix-gaming";
	nix-minecraft = {
	  url = "github:Infinidoge/nix-minecraft";
	  inputs.nixpkgs.follows = "nixpkgs";
	};
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      # This could be expanded to multiple architectures when that comes to need.
      systems = [ "x86_64-linux" ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = nixpkgs.legacyPackages;

      mkSystem = system: hostname:
        lib.nixosSystem {
          system = system;
          modules = [
            { networking.hostName = hostname; }
            (./. + "/hosts/${hostname}")
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.maltalef =
                  (import (./. + "/home/maltalef/${hostname}.nix") {
                    inherit inputs lib outputs;
                  });
              };
            }
          ];
          specialArgs = { inherit inputs outputs; };
        };
    in {
      inherit lib;
      overlays = import ./overlays { inherit inputs outputs; };

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      nixosConfigurations = {
        # Main desktop
        c64 = mkSystem "x86_64-linux" "c64";
        # Laptop (Positivo BGH)
        # c128 = mkSystem "x86_64-linux" "c128";
        # Laptop (Dell Latitude 5480 Intel 7th gen)
        vic20 = mkSystem "x86_64-linux" "vic20";
        # Home server (Old Phenom II X4 945, 2Gb RAM)
        kim1 = mkSystem "x86_64-linux" "kim1";
      };
    };
}

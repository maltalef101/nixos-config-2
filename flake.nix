{
  description = "maltalef's NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      config = config;
      # This could be expanded to multiple architectures when that comes to need.
      systems = [ "x86_64-linux" ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = nixpkgs.legacyPackages;

      mkSystem = system: hostname:
        lib.nixosSystem {
          system = system;
          modules = [
            { networking.hostname = hostname; }
            (./. + "/hosts/${hostname}")
            home-manager.nixosModule.home-manager
	    {
              home-manager = {
                useUserPackages = true;
		useGlobalPkgs = true;
		extraSpecialArgs = { inherit inputs; };
		users.maltalef = ( import "./home/maltalef/${hostname}" { inherit inputs lib config; });
              };
            }
          ];
	  specialArgs = { inherit inputs; };
        };
    in
    {
      inherit lib;
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      nixosConfigurations = {
        # Main desktop
        # c64 = mkSystem "x86_64-linux" "c64";
        # Laptop (Positivo BGH)
        # c128 = mkSystem "x86_64-linux" "c128";
        # Laptop (Dell Latitude 5480 Intel 7th gen)
        vic20 = mkSystem "x86_64-linux" "vic20";
      };
    };
}

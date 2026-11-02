{
  description = "maltalef's NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	#nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
	nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
    sops-nix.url = "github:mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

	# Hyprland sale de nixpkgs (overlays/default.nix), no de un input: un
	# input con su propio nixpkgs trae otra glibc, y Hyprland no puede cargar
	# el mesa del sistema (/run/opengl-driver) si ese mesa pide una glibc más
	# nueva que la suya. Con el bump de nixpkgs del 2026-10-23 pasó eso:
	# glibc 2.42 del input contra el mesa 26.2.5 de glibc 2.44, y Hyprland
	# crasheaba al arrancar.

	hyprlock = {
		url = "github:hyprwm/hyprlock";
		inputs.nixpkgs.follows = "nixpkgs";
	};

	split-monitor-workspaces = {
		# Workspaces por monitor, estilo dwm/awesome. Taguea por release de
		# hyprland (a diferencia de shezdy/hyprsplit, sin port a 0.55+ hoy).
		# Sólo la fuente: se construye con mkHyprlandPlugin contra el Hyprland
		# de nixpkgs (overlays/default.nix). Bumpear en tándem con nixpkgs
		# cuando cambie la serie de Hyprland (pkgs.hyprland.version).
		url = "github:Duckonaut/split-monitor-workspaces/v0.56.0";
		flake = false;
	};

	claude-swap = {
		# Sin derivación en nixpkgs: se buildea en pkgs/claude-swap desde el
		# checkout local. git+file solo toma archivos trackeados y queda
		# lockeado por rev. Bumpear: git pull en ~/dev/claude-swap y
		# `nix flake update claude-swap`.
		url = "git+file:///home/maltalef/dev/claude-swap";
		flake = false;
	};

	infra = {
		# El flake privado de infra (nixos/ del repo de infra): los módulos
		# chaska de NixOS y home-manager, los paquetes de trabajo y su
		# overlay. Lo usa sólo pirincho.
		# Fijado a un rev de origin/main, nunca al main local de
		# ~/documents/infra (puede tener commits sin revisar ni subir).
		# Bumpear: cambiar el rev por el de
		# `git -C ~/documents/infra rev-parse origin/main` y `nix flake lock`.
		# Para iterar sobre un cambio de infra sin commitear:
		# --override-input infra 'git+file:///home/maltalef/documents/infra?dir=nixos'
		url = "git+file:///home/maltalef/documents/infra?dir=nixos&ref=main&rev=d6cef5bb3ec40fde29dbdf48376190c3f1b38629";
		inputs.nixpkgs.follows = "nixpkgs";
		inputs.home-manager.follows = "home-manager";
	};

	nix-gaming.url = "github:fufexan/nix-gaming";
	nix-minecraft = {
	  url = "github:Infinidoge/nix-minecraft";
	  inputs.nixpkgs.follows = "nixpkgs";
	};
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      # This could be expanded to multiple architectures when that comes to need.
      systems = [ "x86_64-linux" ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
		  inherit system;
		  config.allowUnfree = true;
	  });

      mkSystem = system: hostname:
        lib.nixosSystem {
          system = system;
          modules = [
            { networking.hostName = hostname; }
            (./. + "/hosts/${hostname}")
            home-manager.nixosModules.home-manager
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

      mkSystem_wk = system: hostname:
        lib.nixosSystem {
          system = system;
          modules = [
            { networking.hostName = hostname; }
            (./. + "/hosts/${hostname}")
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
				useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.maltalef =
                  (import (./. + "/home/maltalef/${hostname}.nix") {
                    inherit inputs lib outputs;
                  });
				users.mw = 
				  (import (./. + "/home/mw/${hostname}.nix") {
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

      # El tema del escritorio (`tema`, con gruvbox-verde y nvim; modules/tema). home/maltalef/global.nix lo importa.
      homeManagerModules.tema = {
        imports = [ ./modules/tema ];
        # el base16 de la paleta gruvbox-verde
        tema.esquemaGruvbox = lib.mkDefault inputs.nix-colors.colorSchemes.gruvbox-dark-hard;
      };

      checks = forEachSystem (pkgs: {
        hyprland = import ./checks/hyprland.nix { inherit pkgs inputs outputs; };
        tema = import ./checks/tema.nix { inherit pkgs inputs outputs; };
      });

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs inputs; } // {
        # Leen nixosConfigurations.pirincho, así que van acá y no en pkgs/default.nix (lo importa el overlay)
        firefox-prueba = import ./pkgs/firefox-prueba {
          maquina = self.nixosConfigurations.pirincho;
          addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
        };
        # el qutebrowser de prueba, con el tema de pirincho: nix run .#qutebrowser-prueba (pkgs/qutebrowser-prueba)
        qutebrowser-prueba = pkgs.callPackage ./pkgs/qutebrowser-prueba (
          let hm = self.nixosConfigurations.pirincho.config.home-manager.users.maltalef; in {
            inherit (hm) tema;
            # las direcciones de trabajo (el correo y el login), del perfil de maestro de pirincho
            web = hm.chaska.maestro.web or null;
          });
      });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      nixosConfigurations = {
        # Main desktop
        c64 = mkSystem "x86_64-linux" "c64";
        # Laptop (X1 Carbon)
        c128 = mkSystem "x86_64-linux" "c128";
        # Laptop (Dell Latitude 5480 Intel 7th gen)
        # deshabilitada temporalmente: laptop en desuso; descomentar para revivirla
        # vic20 = mkSystem "x86_64-linux" "vic20";
		# vic20 = lib.homeManagerConfiguration {
		# 	modules = [ ./home/maltalef/vic20.nix ];
		# 	pkgs = pkgsFor.x86_64-linux;
		# 	extraSpecialArgs = { inherit inputs outputs; };
		# };
        # Home server (Old Phenom II X4 945, 2Gb RAM)
        # deprecado: no hay hardware cumpliendo este rol hoy; descomentar para revivirlo
        # kim1 = mkSystem "x86_64-linux" "kim1";
		# Work machine (E14)
		pirincho = mkSystem_wk "x86_64-linux" "pirincho";
		# pirincho en una VM, para el ensayo del perfil de maestro (nixosModules.ensayo del input infra):
		# nixos-rebuild build-vm --flake .#prueba-pirincho
		prueba-pirincho = self.nixosConfigurations.pirincho.extendModules {
		  modules = [
		    inputs.infra.nixosModules.ensayo
		    {
		      chaska.ensayo = {
		        # la cuenta de prueba, con el home de maltalef en pirincho y el de maestro, como maltalef
		        home = {
		          imports = [
		            (import ./home/maltalef/pirincho.nix { inherit inputs lib outputs; })
		            inputs.infra.homeManagerModules.maestro
		          ];
		          chaska.maestro.firefox.perfil = "maltalef";
		        };
		        uidsLocales = { maltalef = 1001; mw = 1002; };
		      };
		    }
		  ];
		};
      };
    };
}

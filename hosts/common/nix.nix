{ inputs, lib, options, ...}:
{
  nix = {
    settings = {
      allowed-users = [ "root" "@wheel" ];
      # sin @wheel: un usuario de confianza del daemon es root en los hechos. deploy.sh no se usa hoy;
      # si vuelve, firmar los closures (secret-key-files + trusted-public-keys) o construir en el destino
      trusted-users = [ "root" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

	  substituters = [ "https://hyprland.cachix.org" ];
	  trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      # 14 días: un problema que aparece al tercer día todavía tiene a dónde volver
      options = "--delete-older-than 14d";
    };

    # El input infra (privado), sólo en las máquinas que importan sus módulos: así las demás evalúan sin acceso a él
    registry = lib.mapAttrs (_: value: { flake = value; })
      (if options ? chaska then inputs else removeAttrs inputs [ "infra" ]);

    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
  };
}

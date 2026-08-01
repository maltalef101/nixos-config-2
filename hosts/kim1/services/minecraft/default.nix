{ inputs, config, lib, ... }: {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./servers/casa-house.nix
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
  };
}

{ inputs, config, lib, pkgs, ... }: {
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  services.minecraft-server = {
    enable = true;
    eula = true;
    servers = {
      casa-house = {
        enable = true;
        enableReload = true;
        package = pkgs.inputs.nix-minecraft.paperServers.paper-1_20_1;
        serverProperties = {
          server-port = 25565;
          online-mode = false;
          gamemode = "survival";
          white-list = false;
          motd = "MOJO DOJO MINECRAFT MINECRAFT";
        };
      };
    };
  };
}

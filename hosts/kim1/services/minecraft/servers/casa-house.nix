{ pkgs, inputs, ... }: {
  services.minecraft-servers.servers.casa-house = {
    enable = true;
    enableReload = true;
    package = inputs.nix-minecraft.legacyPackages.${pkgs.stdenv.hostPlatform.system}.paperServers.paper-1_20_1;
    serverProperties = {
      server-port = 25565;
      online-mode = false;
      gamemode = "survival";
      white-list = false;
      motd = "MOJO DOJO MINECRAFT MINECRAFT";
    };
  };
}

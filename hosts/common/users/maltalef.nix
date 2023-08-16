{ pkgs, config, ... }: {
  users.users.maltalef = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" "video" "audio" ];
  };

  services.geoclue2.enable = true;
}

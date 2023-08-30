{ pkgs, config, ... }: {
  users.users.maltalef = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "wheel" "video" "audio" ];
  };

  services.geoclue2.enable = true;
}

{ pkgs, config, ... }: {
  users.mutableUsers = false;
  users.users.maltalef = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "wheel" "video" "audio" ];

	  openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/maltalef/ssh.pub) ];
	  # password = (builtins.readFile config.sops.secrets.maltalef-password.path);
  };

  sops.secrets.maltalef-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  services.geoclue2.enable = true;
}

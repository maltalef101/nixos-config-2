{ pkgs, config, ... }: {
  users.mutableUsers = true;
  users.users.maltalef = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.zsh;

	  openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/maltalef/ssh.pub) ];
	 # passwordFile = config.sops.secrets.maltalef-password.path;
  };

  # sops.secrets.maltalef-password = {
  #   sopsFile = ../../secrets.yaml;
  #   neededForUsers = true;
  # };

  services.geoclue2.enable = true;

  programs.zsh = {
	  enableCompletion = false;
	  enable = true;
  };
}

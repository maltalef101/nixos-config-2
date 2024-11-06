{ pkgs, config, ... }: {
  users.mutableUsers = true;
  users.users.maltalef = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "nm-openvpn" "libvirtd" ];

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

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}

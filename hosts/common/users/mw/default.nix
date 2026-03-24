{ pkgs, config, ... }: {
  users.mutableUsers = true;
  users.users.mw = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "nm-openvpn" "libvirtd" "ubridge" "dialout" ];
  };

  programs.zsh = {
	  enableCompletion = false;
	  enable = true;
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}

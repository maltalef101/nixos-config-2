{ pkgs, lib, config, ... }:
let
  # cada .pub en home/maltalef/keys es una máquina autorizada en toda la flota;
  # autorizar = agregar el archivo, revocar = borrarlo
  keysDir = ../../../../home/maltalef/keys;
  pubFiles = lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".pub" n)
    (builtins.readDir keysDir);
in {
  users.mutableUsers = true;
  users.users.maltalef = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "nm-openvpn" "libvirtd" "ubridge" "dialout" ];

	  openssh.authorizedKeys.keyFiles = lib.mapAttrsToList (n: _: keysDir + "/${n}") pubFiles;
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

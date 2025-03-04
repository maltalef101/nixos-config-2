{ pkgs, config, ...}: {
  networking.networkmanager.enable = true;
  environment.systemPackages = [ pkgs.networkmanager-openvpn pkgs.strongswanNM ];
}

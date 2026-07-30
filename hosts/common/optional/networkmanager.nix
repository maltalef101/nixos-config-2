{ pkgs, config, ...}: {
  networking.networkmanager.enable = true;
  environment.systemPackages = [ pkgs.networkmanager-openvpn pkgs.strongswanNM ];
  networking.networkmanager.plugins = with pkgs; [ networkmanager-strongswan ];

  systemd.services.NetworkManager.environment.STRONGSWAN_CONF = 
	pkgs.writeText "strongswan.conf" ''
	  include ${pkgs.strongswanNM}/etc/strongswan.conf
	'';
}

{ pkgs, config, ...}: {
  networking.networkmanager.enable = true;
  environment.systemPackages = [ pkgs.strongswanNM ];
  networking.networkmanager.plugins = with pkgs; [ networkmanager-strongswan networkmanager-openvpn ];

  systemd.services.NetworkManager.environment.STRONGSWAN_CONF = 
	pkgs.writeText "strongswan.conf" ''
	  include ${pkgs.strongswanNM}/etc/strongswan.conf
	'';
}

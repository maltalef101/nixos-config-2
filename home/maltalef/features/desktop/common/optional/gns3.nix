{ pkgs, lib, config, ... }:
  {
	home.pkgs = with pkgs; [ 
	  gns3-server gns3-gui 
	  dynamips ubridge
	  vpcs docker
	  inetutils
	];

	config.securit.wrappers.ubridge = {
	  source = "${pkgs.ubridge}/bin/ubridge";
	  capabilities = "cap_net_admin,cap_net_raw=ep";
	  owner = "root";
	  group = "users";
	  permissions = "u+rx,g+x";
	};
  };
}

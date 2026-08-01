{ pkgs, inputs, outputs, lib, ... }: {
  imports = [
    ./auto-upgrade.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./doas.nix
  ];

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = { allowUnfree = true; };
  };

  environment = {
	enableAllTerminfo = true;
	systemPackages = [ pkgs.git ];
	pathsToLink = [ "/share/zsh" ]; # for zsh completion
	# va acá (sistema) y no en systemd.user porque /etc/set-environment sourcea el
	# EDITOR=nano (default de NixOS) y pisa lo que ponga systemd.user en el shell.
	# mkDefault le gana igual al nano; para override por host: environment.sessionVariables.
	sessionVariables = {
	  EDITOR = lib.mkDefault "nvim";
	  VISUAL = lib.mkDefault "nvim";
	};
  };

  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
	{
	  domain = "@wheel";
	  item = "memlock";
	  type = "hard";
	  value = "unlimited";
	}
	{
	  domain = "@wheel";
	  item = "memlock";
	  type = "soft";
	  value = "unlimited";
	}
  ];

  hardware.enableRedistributableFirmware = true;

  # FUCK MY ISP FOR BLOCKING TPB
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];

  system.stateVersion = "23.11";
}

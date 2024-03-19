{ pkgs, inputs, outputs, ... }: {
  imports = [
    ./auto-upgrade.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./doas.nix
    ./sops.nix
  ];

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = { allowUnfree = true; };
  };

  environment = {
	enableAllTerminfo = true;
	systemPackages = [ pkgs.git ];
	pathsToLink = [ "/share/zsh" ]; # for zsh completion
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
  ];

  hardware.enableRedistributableFirmware = true;

  # FUCK MY ISP FOR BLOCKING TPB
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];

  system.stateVersion = "23.11";
}

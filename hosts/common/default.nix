{ pkgs, inputs, outputs, ... }: {
  imports = [
    ./auto-upgrade.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./systemd-boot.nix
    ./doas.nix
  ];

  nixpkgs = {
    # overlays = {};
    config = { allowUnfree = true; };
  };

  environment = {
	enableAllTerminfo = true;
	systemPackages = [ pkgs.git ];
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

  system.stateVersion = "23.11";
}

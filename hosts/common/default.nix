{ inputs, outputs, ...}: {
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
    allowUnfree = true;
  };

  environment.enableAllTermInfo = true;

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
}

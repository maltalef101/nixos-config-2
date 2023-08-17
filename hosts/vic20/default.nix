{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
    common-cpu-intel
    common-gpu-intel
    common-pc-ssd

    ./hardware-configuration.nix

    ../common
    ../common/users/maltalef.nix

    ../common/optional/networkmanager.nix
    ../common/optional/xserver.nix
    ../common/optional/pulseaudio.nix
    ../common/optional/bluetooth.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
	Option "DRI" "2"
	Option "TearFree" "true"
  '';

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
}

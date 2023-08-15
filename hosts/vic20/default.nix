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
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
}

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
	../common/optional/greetd.nix
    ../common/optional/pulseaudio.nix
    ../common/optional/bluetooth.nix
	../common/optional/gamemode.nix
	../common/optional/auto-cpufreq.nix
	../common/optional/thermald.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
	Option "DRI" "2"
	Option "TearFree" "true"
  '';

  programs.dconf.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.logind = {
	  lidSwitchDocked = "ignore";
	  lidSwitchExternalPower = "ignore";
  };
}

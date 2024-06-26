{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
    common-cpu-intel
    common-gpu-nvidia
    common-pc-ssd

    ./hardware-configuration.nix

    ../common
    ../common/users/maltalef

	  ../common/optional/auto-cpufreq.nix
	  ../common/optional/gamemode.nix
	  ../common/optional/greetd.nix
	  ../common/optional/thermald.nix
	  ../common/optional/systemd-boot.nix
    ../common/optional/pipewire.nix
    ../common/optional/xserver.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  environment.systemPackages = with pkgs; [
    vulkan-loader
    vulkan-tools
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  services.ratbagd.enable = true;

  programs.dconf.enable = true;

  hardware = {
    nvidia = {
      nvidiaSettings = true;
      modesetting.enable = true;
      forceFullCompositionPipeline = true;
      prime.offload.enable = false;
    };

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = [ pkgs.nvidia-vaapi-driver ];
    };
  };
}

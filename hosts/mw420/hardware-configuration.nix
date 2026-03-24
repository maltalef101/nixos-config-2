{
  boot = {
	tmp.cleanOnBoot = true;
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ "cryptd" ];

	  luks.devices."cryptroot".device = "/dev/disk/by-label/nix-crypt";
    };
	loader = {
		limine = {
			enable = true;
			secureBoot.enable = true;
		}; 
		efi = {
			canTouchEfiVariables = true;
			efiSysMountPoint = "/boot/efi";
		};
		timeout = 3;
	};
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nix-root";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-label/nix-swap"; } ];
  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;

  hardware.graphics = {
	  enable = true;
	  enable32Bit = true;
  };

  networking = {
	  firewall.enable = false;
  };
}

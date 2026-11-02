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
			# la ESP es de 1 GB y cada initrd distinto pesa ~89 MB: 6 entradas, y el install copia
			# antes de borrar, así que en el peor caso hay 7 initrds y 2 kernels (~650 MB)
			maxGenerations = 6;
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
}

{ pkgs, inputs, outputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
     lenovo-thinkpad-t14-amd-gen2
     inputs.infra.nixosModules.maestro

    ./hardware-configuration.nix
    ./firewall.nix

    ../common
    ../common/users/maltalef
	../common/users/mw

	../common/optional/brightness.nix
	../common/optional/gamemode.nix
	../common/optional/gdm.nix
	../common/optional/thermald.nix
    ../common/optional/bluetooth.nix
    ../common/optional/networkmanager.nix
    ../common/optional/pipewire.nix
	../common/optional/hyprland.nix
	../common/optional/fprintd.nix
	../common/optional/impresion.nix
	../common/optional/keychron.nix
	./nix-security-box
  ];

  # La estación de maestro, del flake de infra: lo de trabajo (red, VPN, padrón, sus herramientas y el home de
  # maltalef) y la hoja de servicio de los agentes. Los valores son del perfil, no de acá.
  chaska.maestro = {
    enable = true;
    usuario = "maltalef";
    rulobot.enable = true;
  };
  # el login con el ticket de la sesión, en el perfil de Firefox de maltalef (features/desktop/common/firefox.nix)
  home-manager.users.maltalef.chaska.maestro.firefox.perfil = "maltalef";

  # La pantalla de arranque del perfil: también pide la frase de cryptroot (amdgpu ya va en el initrd). En gruvbox con
  # el acento verde, como el escritorio (tema.paleta de maltalef), en FiraCode Nerd Font, la de interfaz de
  # gruvbox-verde (la del campo del bloqueo).
  chaska.tema.plymouth = {
    enable = true;
    colores = (import ../../modules/tema/gruvbox-verde.nix null).colores // {
      nombre = "gruvbox";
      descripcion = "en gruvbox con el acento verde";
    };
    fuente = {
      nombre = "FiraCode Nerd Font";
      archivo = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Regular.ttf";
      paquete = pkgs.nerd-fonts.fira-code;
    };
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_7_2;

  # Cuelgues del 30/10: un Oops por un bit dado vuelta en el texto del kernel (0x0f leído como 0x0d), así que
  # memtest86+ en el menú de Limine para probar la RAM. Es un EFI sin firmar: sólo arranca con Secure Boot apagado.
  boot.loader.limine = {
    additionalFiles."efi/memtest86plus/mt86plus.efi" = pkgs.memtest86plus.efi;
    extraEntries = ''
      /memtest86+
        protocol: efi_chainload
        path: boot():/efi/memtest86plus/mt86plus.efi
    '';
  };

  boot.kernel.sysctl = {
    # SysRq completo (por defecto 16, sólo sync): ante un cuelgue, Alt+SysRq+REISUB dice si el kernel sigue vivo
    "kernel.sysrq" = 1;
    # un Oops cuelga la máquina a medias: mejor pánico y reinicio solo a los 10 s, con la traza ya en el journal
    "kernel.panic_on_oops" = 1;
    "kernel.panic" = 10;
  };

  services.flatpak.enable = true;
  programs.dconf.enable = true;

  # scapy (packet-generators) arrastra python-ecdsa, marcado inseguro por
  # CVE-2024-23342 (timing side-channel "Minerva", sin fix upstream). Solo se
  # usa como dep transitiva de tooling, no para firmar secretos propios -> OK.
  nixpkgs.config.permittedInsecurePackages = [ "python3.14-ecdsa-0.19.2" ];

  services.fwupd.enable = true;
  services.tlp = {
	enable = true;
	settings = {
		START_CHARGE_THRESH_BAT0 = 85;
		STOP_CHARGE_THRESH_BAT0 = 95;
		TPSMAPI_ENABLE = 1;

		CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
		CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
		CPU_ENERGY_PERF_POLICY_ON_SAV = "power";

		PLATFORM_PROFILE_ON_AC = "performance";
		PLATFORM_PROFILE_ON_BAT = "balanced";
		PLATFORM_PROFILE_ON_SAV = "low-power";

		CPU_SCALING_GOVERNOR_ON_AC = "performance";
		CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
		CPU_SCALING_GOVERNOR_ON_SAV = "powersave";

		CPU_HWP_DYN_BOOST_ON_AC = 1;
		CPU_HWP_DYN_BOOST_ON_BAT = 0;
		CPU_HWP_DYN_BOOST_ON_SAV = 0;
	};
  };

  services.logind.settings.Login = {
	  HandleLidSwitchExternalPower = "ignore";
  };

  environment.systemPackages = with pkgs; [
	sbctl
  ];
}

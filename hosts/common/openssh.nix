{ outputs, lib, config, ... }:
let 
  inherit (config.networking) hostName;
  # sólo las que tienen clave de host: las variantes de VM (prueba-pirincho) no son máquinas de la flota
  hosts = lib.filterAttrs (name: _: builtins.pathExists (pubKey name)) outputs.nixosConfigurations;
  pubKey = host: ../${host}/ssh_host_ed25519_key.pub;
in {
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = false;
      # sin keyboard-interactive: con fprintd en PAM, un intento remoto leía el lector de huellas
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
	  LogLevel = "INFO";
    };

    hostKeys = [{
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };
  
  programs.ssh = {
    # Each hosts public key
    knownHosts = builtins.mapAttrs
      (name: _: {
        publicKeyFile = pubKey name;
        extraHostNames =
          (lib.optional (name == hostName) "localhost"); # Alias for localhost if it's the same host
      })
      hosts;
  };

  # la huella nunca aprueba un login remoto (fprintd la agrega a todas las pilas de PAM). Con el mkIf, una máquina sin
  # sshd (pirincho) no gana un /etc/pam.d/sshd suelto
  security.pam.services.sshd = lib.mkIf config.services.openssh.enable { fprintAuth = false; };
}
  

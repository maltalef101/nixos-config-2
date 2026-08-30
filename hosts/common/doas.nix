{ pkgs, lib, ... }:
{
  # deploy.sh usa nixos-rebuild --use-remote-sudo, que invoca `sudo` en el
  # host destino; con sudo deshabilitado, el shim traduce sudo -> doas.
  environment.systemPackages = [ pkgs.doas-sudo-shim ];

  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          keepEnv = true;
          persist = true;
        }
      ];
    };

    # nixpkgs' doas module enables sshAgentAuth for the doas PAM service
    # unconditionally (not as a default), so doas would authenticate via the
    # SSH agent (gpg-agent). Force it off to use fingerprint/password instead.
    pam.services.doas.sshAgentAuth = lib.mkForce false;
  };
}

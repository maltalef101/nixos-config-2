{ outputs, lib, config, ... }:
{
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
    };
  };
  
  # TODO: put the public keys of each host in the knownHosts
  #  (probably need secrets)
  # programs.ssh = { };
}
  

# SSL/TLS testing tools

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cero
    gsan
    sslscan
    ssldump
    # sslsplit # build roto en nixpkgs actual: falla el link (ld exit 1), incompat openssl
    sslstrip
    testssl
    tlsinfo
    tlsx
  ];
}

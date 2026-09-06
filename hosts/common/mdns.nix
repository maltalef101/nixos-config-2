{
  # resolución de nombres .local (mDNS) vía avahi + nss-mdns
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # solo queries: no anunciar este host ni sus servicios en la LAN
    publish.enable = false;
    # udp 5353: las respuestas mDNS llegan por multicast, conntrack no las asocia
    openFirewall = true;
  };
}

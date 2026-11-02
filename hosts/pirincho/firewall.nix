# El firewall de pirincho. Entra lo que ya está declarado con openFirewall (mDNS)
# y lo que responde a lo que sale (conntrack); el resto se descarta.
{ ... }: {
  networking.firewall.enable = true;

  # Nadie entra por ssh, ni por la VPN de infra: sin sshd. hosts/common/openssh.nix lo prende con
  # mkDefault en las demás máquinas. El cliente (programs.ssh, los knownHosts, el agente) sigue igual. La llave de host
  # queda en el disco y su .pub en el repo: las otras máquinas la siguen conociendo, y si el sshd vuelve, vuelve con ella.
  services.openssh.enable = false;

  # libvirt no necesita nada: con el backend iptables (el de NixOS sin nftables) inserta su LIBVIRT_INP, con el DHCP y
  # el DNS de virbr0, antes de nixos-fw.
  networking.firewall.extraCommands = ''
    # El ESP de las VPN. Sin NAT va crudo (encap = false), y conntrack lo sigue sólo por direcciones: lo que el borde
    # manda primero por el túnel, o después de 10 minutos sin ESP de acá, llega como NEW y se descartaría. Sin sshd ya
    # no entra ningún servicio por la VPN de infra, pero queda: abrirlo no expone nada (el kernel tira el ESP sin una SA
    # que lo conozca, y lo descifrado vuelve a pasar por el firewall, entrado por la interfaz XFRM, donde ya no se abre
    # ningún puerto), y sin él lo que el borde empiece (un ping, que el firewall acepta) se pierde en silencio con el
    # túnel quieto. El IKE (500/4500) no se abre: lo empieza charon (la conexión, los rekeys, la reautenticación) y lo
    # que contesta el borde entra por conntrack; con NAT, el ESP va en ese mismo flujo UDP.
    ip46tables -A nixos-fw -p esp -j nixos-fw-accept

    # Las conexiones compartidas de NetworkManager (ipv4.method shared): NM pone el NAT y el reenvío en su tabla
    # nftables (nm-shared-<if>), pero no abre la entrada (un accept suyo no salvaría el drop de nixos-fw), y su dnsmasq
    # quedaría sin DHCP ni DNS. La interfaz compartida cambia, así que va por dirección: el DHCP llega por broadcast
    # desde 0.0.0.0 (sin una conexión compartida nadie lo atiende; el dnsmasq de libvirt sólo contesta en virbr0), y el
    # DNS, sólo de y hacia las redes de NM (10.42.<n>.0/24).
    iptables -A nixos-fw -p udp --sport 68 --dport 67 -j nixos-fw-accept
    iptables -A nixos-fw -s 10.42.0.0/16 -d 10.42.0.0/16 -p udp --dport 53 -j nixos-fw-accept
    iptables -A nixos-fw -s 10.42.0.0/16 -d 10.42.0.0/16 -p tcp --dport 53 -j nixos-fw-accept
  '';
}

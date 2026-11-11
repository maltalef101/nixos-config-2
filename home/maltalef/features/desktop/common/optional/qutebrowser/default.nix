# qutebrowser, el navegador por omisión: los enlaces, xdg-open y BROWSER. Firefox (firefox.nix) sigue instalado y
# queda detrás en xdg-mime, para lo que qutebrowser no hace bien (las extensiones, Sidebery, los sitios que lo
# rechazan). El paquete, su config.py y el envoltorio están en paquete.nix.
{ config, lib, pkgs, ... }:
let
  qutebrowser = pkgs.callPackage ./paquete.nix {
    inherit (config) tema;
    # las direcciones de trabajo (el correo y el login con el ticket), del home de maestro del input infra; sin él,
    # nada de eso
    web = config.chaska.maestro.web or null;
  };
  escritorio = "org.qutebrowser.qutebrowser.desktop";
in
{
  home.packages = [ qutebrowser ];

  xdg.configFile = {
    # Un qutebrowser abierto alguna vez sin config deja un config.py vacío; éste lo reemplaza. Lo cambiado con :set
    # va a autoconfig.yml, que no se toca.
    "qutebrowser/config.py" = {
      source = qutebrowser.configPy;
      force = true;
    };
    "qutebrowser/greasemonkey/youtube-publicidad.user.js".source = ./youtube-publicidad.user.js;
  };

  systemd.user.sessionVariables.BROWSER = "qutebrowser";

  # adelante de los de firefox.nix: el primero de cada lista es el que se abre, y Firefox queda como alternativa
  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "text/html"
    "text/xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ] (_: lib.mkBefore [ escritorio ]);
}

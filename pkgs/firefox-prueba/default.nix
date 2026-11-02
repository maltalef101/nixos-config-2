# El Firefox de prueba de pirincho: corre al lado del Firefox de siempre, sin switch, con su perfil
# aparte (~/.local/share/firefox-prueba/perfil) y sin tocar el de home-manager.
#   nix run ~/dev/nixos-config-2#firefox-prueba
# Trae las pestañas verticales nativas en vez de Sidebery, Tridactyl, el máximo de espacio para la página y las
# pestañas fijas de Rulo. Toma del perfil maltalef de pirincho (firefox.nix) sus preferencias, el tema y uBlock.
# Para borrarlo: rm -rf ~/.local/share/firefox-prueba (el store lo limpia el gc).
#
# `maquina` es nixosConfigurations.pirincho: el Firefox es el mismo paquete que el del sistema (sólo cambia el
# envoltorio), y las preferencias y el tema salen de su home-manager.
{ maquina, addons }:
let
  pkgs = maquina.pkgs;
  lib = pkgs.lib;
  hm = maquina.config.home-manager.users.maltalef;
  perfil = hm.programs.firefox.profiles.maltalef;
  cssTema = import ../../home/maltalef/features/desktop/common/firefox-tema.nix hm.tema;
  # las direcciones de trabajo, del perfil de maestro (chaska.maestro.web); sin él, sin el correo
  web = hm.chaska.maestro.web or null;

  # WhatsApp, Telegram, el correo, el calendario y YouTube Music. El correo y el calendario son el webmail de trabajo: no
  # tiene una URL que abra el calendario (sus acciones por URL son sólo mailto y profile), así que es la misma, y en
  # esa pestaña se pasa a Calendario
  fijas = [
    "https://web.whatsapp.com/"
    "https://web.telegram.org/a/"
  ] ++ lib.optionals (web != null) [
    "${web.correo}/web/"
    "${web.correo}/web/"
  ] ++ [
    "https://music.youtube.com/"
  ];

  # Las preferencias de firefox.nix, sin las del sidebar con Sidebery y la barra de siempre, más las de acá
  preferencias = removeAttrs perfil.settings [
    "sidebar.visibility"
    "sidebar.verticalTabs"
    "browser.uiCustomization.state"
    "browser.toolbarbuttons.introduced.sidebar-button"
  ] // {
    # Las pestañas verticales nativas, con la columna siempre visible: Ctrl+Alt+Z la colapsa a íconos y la vuelve
    # a abrir. Las fijas van arriba, en una grilla de íconos
    "sidebar.revamp" = true;
    "sidebar.verticalTabs" = true;
    "sidebar.visibility" = "always-show";
    "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
    "sidebar.new-sidebar.has-used" = true;
    # Abajo de la columna, sólo historial y marcadores (sin el chat de IA ni las pestañas sincronizadas)
    "sidebar.main.tools" = "history,bookmarks";
    "browser.ml.chat.enabled" = false;
    # La barra de arriba: la de direcciones, las descargas (aparece sólo cuando hay una) y el menú de las
    # extensiones (los botones de las tres van adentro: default_area en las políticas). Sin recargar ni inicio
    # (r de Tridactyl, o F5). Firefox 158 (browser.nova) agrega por su cuenta atrás y adelante a la derecha, y en
    # vertical no pone el botón del sidebar. Las pestañas, en la columna (vertical-tabs). Se cambia con
    # «Personalizar barra de herramientas».
    "browser.uiCustomization.state" = builtins.toJSON {
      placements = {
        widget-overflow-fixed-list = [ ];
        unified-extensions-area = [ ];
        nav-bar = [ "urlbar-container" "downloads-button" "unified-extensions-button" ];
        toolbar-menubar = [ "menubar-items" ];
        TabsToolbar = [ ];
        vertical-tabs = [ "tabbrowser-tabs" ];
        PersonalToolbar = [ "personal-bookmarks" ];
      };
      seen = [ ];
      dirtyAreaCache = [ ];
      currentVersion = 28;
      newElementCount = 0;
    };
    "browser.toolbarbuttons.introduced.sidebar-button" = true;
    # Los grupos de pestañas nativos (encendidos por omisión desde la 139; los atajos, en grupos.js), sin las
    # sugerencias de grupos con IA. Al arrancar, la sesión anterior, con sus grupos (como el perfil de siempre)
    "browser.tabs.groups.enabled" = true;
    "browser.tabs.groups.smart.enabled" = false;
    "browser.tabs.groups.smart.userEnabled" = false;
    "browser.startup.page" = 3;
    # Sin la bienvenida, el aviso de privacidad ni la pregunta del navegador por omisión en el primer arranque
    "browser.aboutwelcome.enabled" = false;
    "trailhead.firstrun.didSeeAboutWelcome" = true;
    "browser.startup.homepage_override.mstone" = "ignore";
    "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
  };

  # Van como valores por omisión en el mozilla.cfg: valen desde el primer arranque, y lo que se cambie en
  # about:config queda (en el prefs.js del perfil) y les gana
  porOmision = lib.concatStrings (lib.mapAttrsToList
    (k: v: "defaultPref(${builtins.toJSON k}, ${builtins.toJSON v});\n") preferencias);

  xpi = a: "file://${a}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${a.addonId}.xpi";
  extension = a: { installation_mode = "force_installed"; install_url = xpi a; default_area = "menupanel"; };

  # Ctrl+I de Tridactyl: nvim en una ventana de foot, con el XDG_CONFIG_HOME de la sesión (el native messenger
  # corre con el de abajo)
  editor = pkgs.writeShellScript "firefox-prueba-editor" ''
    export XDG_CONFIG_HOME="$FIREFOX_PRUEBA_XDG_CONFIG_HOME"
    exec foot nvim "$@"
  '';

  rc = pkgs.replaceVars ./tridactylrc { inherit editor; };

  # El native messenger de Tridactyl, por el que lee el rc en cada arranque (desde el segundo: en el primero, el de
  # la instalación, Tridactyl abre su tutorial y su página nueva todavía es la suya). Lo busca en
  # $XDG_CONFIG_HOME/tridactyl/tridactylrc: el envoltorio le apunta XDG_CONFIG_HOME al directorio de la prueba, así
  # el rc queda con el perfil y no en ~/.config. Va sólo en este Firefox (MOZ_SYSTEM_DIR de su envoltorio): el de
  # siempre no lo ve.
  nativo = pkgs.writeShellScript "tridactyl-native-prueba" ''
    export FIREFOX_PRUEBA_XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_CONFIG_HOME="''${FIREFOX_PRUEBA_DIR:-$HOME/.local/share/firefox-prueba}"
    exec ${pkgs.tridactyl-native}/bin/native_main "$@"
  '';
  nativoHost = pkgs.runCommand "tridactyl-native-prueba" { } ''
    mkdir -p $out/lib/mozilla/native-messaging-hosts
    sed 's|"path": *"[^"]*"|"path": "${nativo}"|' \
      ${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts/tridactyl.json \
      > $out/lib/mozilla/native-messaging-hosts/tridactyl.json
  '';

  firefox = hm.programs.firefox.package.override {
    nativeMessagingHosts = [ nativoHost ];
    # el mozilla.cfg con privilegios de chrome, para fijas.js
    extraAutoConfig = ''pref("general.config.sandbox_enabled", false);'';
    extraPrefs = porOmision;
    # (grupos.js, copiado al store: el envoltorio pierde el contexto de una ruta dentro de la fuente del flake)
    extraPrefsFiles = [
      (pkgs.replaceVars ./fijas.js { fijas = builtins.toJSON fijas; })
      (pkgs.writeText "grupos.js" (builtins.readFile ./grupos.js))
    ];
    extraPolicies = {
      # Desde el store (las mismas fuentes que firefox.nix): se instalan sin red, en el primer arranque, y después
      # se actualizan desde AMO como cualquier extensión
      ExtensionSettings = {
        "tridactyl.vim@cmcaine.co.uk" = extension addons.tridactyl;
        "uBlock0@raymondhill.net" = extension addons.ublock-origin;
        "browserpass@maximbaz.com" = extension addons.browserpass;
      };
      SearchEngines.Default = "DuckDuckGo";
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        MoreFromMozilla = false;
        SkipOnboarding = true;
      };
    };
  };

  userChrome = pkgs.writeText "userChrome.css" (''
    /* Firefox de prueba (pkgs/firefox-prueba). firefox-prueba lo copia del store una vez y no lo vuelve a pisar
       si se cambia acá. */
  '' + builtins.readFile ./densidad.css + lib.optionalString hm.tema.enable cssTema.cromo);
  userContent = pkgs.writeText "userContent.css" (lib.optionalString hm.tema.enable cssTema.contenido);
in
pkgs.writeShellApplication {
  name = "firefox-prueba";
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    dir="''${FIREFOX_PRUEBA_DIR:-$HOME/.local/share/firefox-prueba}"
    export FIREFOX_PRUEBA_DIR="$dir"
    perfil="$dir/perfil"
    mkdir -p "$perfil/chrome" "$dir/tridactyl"

    # Copia un archivo del store al perfil si no está, o si está como lo dejó la última copia (así le llegan los
    # cambios del repo). Si se cambió a mano, lo deja: la suma de lo copiado queda en <destino>.sha256.
    instalar() {
      local fuente="$1" destino="$2" suma
      if [ -e "$destino" ]; then
        suma=$(sha256sum < "$destino")
        if [ ! -e "$destino.sha256" ] || [ "$suma" != "$(cat "$destino.sha256")" ]; then
          [ "$(sha256sum < "$fuente")" = "$suma" ] && return 0
          echo "firefox-prueba: $destino cambió a mano, no lo piso (la versión del repo: $fuente)" >&2
          return 0
        fi
      fi
      install -m 644 "$fuente" "$destino"
      sha256sum < "$fuente" > "$destino.sha256"
    }
    instalar ${userChrome} "$perfil/chrome/userChrome.css"
    instalar ${userContent} "$perfil/chrome/userContent.css"
    instalar ${rc} "$dir/tridactyl/tridactylrc"

    # --name: otra clase de ventana (y otro nombre para el remoto), así no se mezcla con el Firefox de siempre
    exec ${firefox}/bin/firefox --name firefox-prueba --profile "$perfil" "$@"
  '';
  passthru = { inherit firefox fijas; };
}

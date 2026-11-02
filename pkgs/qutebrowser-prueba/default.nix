# Un qutebrowser de prueba, al lado de todo y sin switch:
#   nix run ~/dev/nixos-config-2#qutebrowser-prueba
# El qutebrowser de nixpkgs con su propio --basedir (~/.local/share/qutebrowser-prueba): config, datos, sesiones,
# cookies y caché quedan ahí adentro, sin tocar ~/.config/qutebrowser ni otro qutebrowser abierto (cada basedir es
# su propia instancia, con su propio socket). Borrarlo: ese directorio, y la salida del flake.
#
# - config.py: generado acá, con los colores y la fuente del tema. Es un enlace al store que se rehace en
#   cada arranque; lo que Rulo cambie con :set queda en autoconfig.yml, que se carga al final y le gana.
# - Las 5 fijadas: en el primer arranque (sin data/state ni sesión guardada) se instala la sesión `default` con las
#   cinco pestañas `pinned` y se arranca con `-r default`. Después qutebrowser guarda y restaura la sesión solo
#   (auto_save.session), así que no se duplican.
# - El bloqueo de publicidad: python-adblock (adblock-rust de Brave) viene en el paquete de nixpkgs, con las listas
#   de uBlock, EasyList, EasyPrivacy y EasyList Spanish. qutebrowser no las baja solo: el envoltorio le pasa
#   `:adblock-update` en el primer arranque y cuando la caché tiene más de una semana. No hace filtrado cosmético
#   ni scriptlets (+js()): para YouTube va youtube-publicidad.user.js, un userscript propio.
# - Los colores: cada par de texto y fondo de la interfaz está en `pares`, y el build mide su contraste WCAG
#   (`contraste`, al menos 4,5:1); si uno no llega, el paquete no se construye.
# - Los grupos de pestañas (como «los tab groups» de Sidebery): ninguna versión publicada de
#   qutebrowser los tiene. Las pestañas en árbol (tabs.tree_tabs) están en una rama de qutebrowser que no se
#   publicó (tree-tabs-integration, PR #8082); arbol-de-pestanas.patch es el PR #8998 (tshiunghan, sin revisar
#   todavía, commit 1c0e628), que la porta a 3.7.0, rebasado acá sobre el tag v3.7.0 sin docs ni pruebas.
#   grupos.patch suma tres comandos propios: :tree-tab-reparent (mover una pestaña a un grupo),
#   :tree-tab-group-focus (pasar al grupo siguiente o anterior) y :tree-tab-open-in-group (abrir una pestaña al
#   final del grupo de la activa). Un grupo es una pestaña de primer nivel con
#   hijas, o la página qute://treegroup/<nombre> de :tree-tab-create-group, y se colapsa con :tree-tab-toggle-hide.
# `web`: las direcciones de trabajo (`correo`, `idp`), las de chaska.maestro.web del home de pirincho; null, sin el
# correo ni el login con el ticket.
{ lib, writeText, writeShellApplication, runCommand, python3, qutebrowser, coreutils, findutils, tema, web ? null }:
let
  c = tema.colores;
  dominioCorreo = lib.removePrefix "https://" web.correo;

  qutebrowserArbol = qutebrowser.overrideAttrs (viejo: {
    patches = (viejo.patches or [ ]) ++ [ ./arbol-de-pestanas.patch ./grupos.patch ];
  });

  # Las mismas cinco que el Firefox de prueba: el calendario del webmail de trabajo no
  # tiene URL propia (su URLActionMgr sólo entiende mailto y profile), así que la cuarta es el mismo webmail, y se
  # pasa a Calendario adentro.
  fijadas = [
    { url = "https://web.whatsapp.com/"; titulo = "WhatsApp"; }
    { url = "https://web.telegram.org/a/"; titulo = "Telegram"; }
  ] ++ lib.optionals (web != null) [
    { url = "${web.correo}/web/"; titulo = "Correo"; }
    { url = "${web.correo}/web/"; titulo = "Calendario"; }
  ] ++ [
    { url = "https://music.youtube.com/"; titulo = "YouTube Music"; }
  ];
  dominios = [ "web.whatsapp.com" "web.telegram.org" ] ++ lib.optional (web != null) dominioCorreo ++ [ "music.youtube.com" ];

  # La sesión inicial, con el formato de misc/sessions.py (en JSON, que también es YAML): `geometry: null` deja la
  # ventana por omisión, y `pinned` va en la entrada de la historia (así lo lee _load_tab).
  sesion = writeText "qutebrowser-prueba-sesion.yml" (builtins.toJSON {
    windows = [{
      active = true;
      geometry = null;
      tabs = lib.imap0 (i: f: {
        active = i == 0;
        history = [{ active = true; pinned = true; title = f.titulo; inherit (f) url; }];
      }) fijadas;
    }];
  });

  listas = [
    "https://ublockorigin.github.io/uAssets/filters/filters.txt"
    "https://ublockorigin.github.io/uAssets/filters/badware.txt"
    "https://ublockorigin.github.io/uAssets/filters/privacy.txt"
    "https://ublockorigin.github.io/uAssets/filters/quick-fixes.txt"
    "https://ublockorigin.github.io/uAssets/filters/unbreak.txt"
    "https://easylist.to/easylist/easylist.txt"
    "https://easylist.to/easylist/easyprivacy.txt"
    # la regional que uBlock prende solo con el idioma castellano (infobae, clarín…)
    "https://easylist-downloads.adblockplus.org/easylistspanish.txt"
  ];
  py = lib.concatMapStringsSep ", " (x: "'${x}'");

  # Los pares de texto y fondo de la interfaz: `fg` y `bg` son las opciones colors.* que toman ese texto y ese fondo
  # (vacías: el par sólo se mide, porque la opción ya está en otro). La barra de estado tiene el fondo oscuro en todos
  # los modos y el modo se ve en el color del texto: la URL conserva su color (colors.statusbar.url.*) en cualquier
  # modo, y sobre un fondo de color quedaba ilegible (el verde de https sobre el verde de insert daba 1,5:1).
  # Con la barra siempre visible, además, un fondo que cambia de color en cada modo distrae.
  pares = with c; [
    { que = "barra de estado, normal"; texto = texto; fondo = fondo; fg = [ "statusbar.normal.fg" ]; bg = [ "statusbar.normal.bg" ]; }
    { que = "barra de estado, insert"; texto = secundario; fondo = fondo; fg = [ "statusbar.insert.fg" ]; bg = [ "statusbar.insert.bg" ]; }
    { que = "barra de estado, passthrough"; texto = enlace; fondo = fondo; fg = [ "statusbar.passthrough.fg" ]; bg = [ "statusbar.passthrough.bg" ]; }
    { que = "barra de estado, caret"; texto = aviso; fondo = fondo; fg = [ "statusbar.caret.fg" ]; bg = [ "statusbar.caret.bg" ]; }
    { que = "barra de estado, caret con selección"; texto = ok; fondo = fondo; fg = [ "statusbar.caret.selection.fg" ]; bg = [ "statusbar.caret.selection.bg" ]; }
    { que = "barra de estado, command"; texto = textoClaro; fondo = fondoHondo; fg = [ "statusbar.command.fg" "statusbar.command.private.fg" ]; bg = [ "statusbar.command.bg" "statusbar.command.private.bg" ]; }
    { que = "barra de estado, privado"; texto = textoTenue; fondo = fondoHondo; fg = [ "statusbar.private.fg" ]; bg = [ "statusbar.private.bg" ]; }
    # la URL, sobre los dos fondos de la barra
    { que = "URL"; texto = texto; fondo = fondo; fg = [ "statusbar.url.fg" "statusbar.url.success.http.fg" ]; bg = [ ]; }
    { que = "URL, sobre command y privado"; texto = texto; fondo = fondoHondo; fg = [ ]; bg = [ ]; }
    { que = "URL https"; texto = secundario; fondo = fondo; fg = [ "statusbar.url.success.https.fg" ]; bg = [ ]; }
    { que = "URL https, sobre command y privado"; texto = secundario; fondo = fondoHondo; fg = [ ]; bg = [ ]; }
    { que = "URL de un enlace (hover)"; texto = enlace; fondo = fondo; fg = [ "statusbar.url.hover.fg" ]; bg = [ ]; }
    { que = "URL con aviso"; texto = aviso; fondo = fondo; fg = [ "statusbar.url.warn.fg" ]; bg = [ ]; }
    { que = "URL con error"; texto = error; fondo = fondo; fg = [ "statusbar.url.error.fg" ]; bg = [ ]; }
    { que = "URL con error, sobre command y privado"; texto = error; fondo = fondoHondo; fg = [ ]; bg = [ ]; }

    { que = "pestaña, impar y par"; texto = textoTenue; fondo = fondoHondo; fg = [ "tabs.odd.fg" "tabs.even.fg" ]; bg = [ "tabs.odd.bg" "tabs.even.bg" "tabs.bar.bg" ]; }
    { que = "pestaña fijada"; texto = texto; fondo = fondo; fg = [ "tabs.pinned.odd.fg" "tabs.pinned.even.fg" ]; bg = [ "tabs.pinned.odd.bg" "tabs.pinned.even.bg" ]; }
    { que = "pestaña seleccionada (también fijada)"; texto = fondoHondo; fondo = acento; fg = [ "tabs.selected.odd.fg" "tabs.selected.even.fg" "tabs.pinned.selected.odd.fg" "tabs.pinned.selected.even.fg" ]; bg = [ "tabs.selected.odd.bg" "tabs.selected.even.bg" "tabs.pinned.selected.odd.bg" "tabs.pinned.selected.even.bg" ]; }

    { que = "completado"; texto = texto; fondo = fondo; fg = [ "completion.fg" ]; bg = [ "completion.odd.bg" "completion.even.bg" "completion.scrollbar.bg" ]; }
    { que = "completado, coincidencia"; texto = aviso; fondo = fondo; fg = [ "completion.match.fg" ]; bg = [ ]; }
    { que = "completado, categoría"; texto = secundario; fondo = superficie; fg = [ "completion.category.fg" ]; bg = [ "completion.category.bg" "completion.category.border.top" "completion.category.border.bottom" ]; }
    { que = "completado, seleccionado"; texto = textoClaro; fondo = seleccion; fg = [ "completion.item.selected.fg" ]; bg = [ "completion.item.selected.bg" "completion.item.selected.border.top" "completion.item.selected.border.bottom" ]; }
    { que = "completado, coincidencia en el seleccionado"; texto = aviso; fondo = seleccion; fg = [ "completion.item.selected.match.fg" ]; bg = [ ]; }

    { que = "hints"; texto = fondo; fondo = aviso; fg = [ "hints.fg" ]; bg = [ "hints.bg" ]; }
    { que = "hints, lo ya tecleado"; texto = campoHover; fondo = aviso; fg = [ "hints.match.fg" ]; bg = [ ]; }
    { que = "ayuda de teclas"; texto = texto; fondo = fondoHondo; fg = [ "keyhint.fg" ]; bg = [ "keyhint.bg" ]; }
    { que = "ayuda de teclas, lo que falta"; texto = aviso; fondo = fondoHondo; fg = [ "keyhint.suffix.fg" ]; bg = [ ]; }

    { que = "mensaje info"; texto = texto; fondo = fondo; fg = [ "messages.info.fg" ]; bg = [ "messages.info.bg" "messages.info.border" ]; }
    { que = "mensaje warning"; texto = fondo; fondo = aviso; fg = [ "messages.warning.fg" ]; bg = [ "messages.warning.bg" "messages.warning.border" ]; }
    { que = "mensaje error"; texto = textoClaro; fondo = alerta; fg = [ "messages.error.fg" ]; bg = [ "messages.error.bg" "messages.error.border" ]; }
    { que = "prompt"; texto = texto; fondo = superficie; fg = [ "prompts.fg" ]; bg = [ "prompts.bg" ]; }
    { que = "prompt, seleccionado"; texto = textoClaro; fondo = seleccion; fg = [ "prompts.selected.fg" ]; bg = [ "prompts.selected.bg" ]; }

    { que = "menú contextual"; texto = texto; fondo = superficie; fg = [ "contextmenu.menu.fg" ]; bg = [ "contextmenu.menu.bg" ]; }
    { que = "menú contextual, seleccionado"; texto = textoClaro; fondo = seleccion; fg = [ "contextmenu.selected.fg" ]; bg = [ "contextmenu.selected.bg" ]; }
    { que = "descarga, empieza"; texto = fondo; fondo = enlace; fg = [ "downloads.start.fg" ]; bg = [ "downloads.start.bg" ]; }
    { que = "descarga, termina"; texto = fondo; fondo = acento; fg = [ "downloads.stop.fg" ]; bg = [ "downloads.stop.bg" ]; }
    { que = "descarga con error"; texto = textoClaro; fondo = alerta; fg = [ "downloads.error.fg" ]; bg = [ "downloads.error.bg" ]; }
  ];

  lineasPares = lib.concatMapStrings (p:
    lib.concatMapStrings (k: "c.colors.${k} = '#${p.texto}'\n") p.fg
    + lib.concatMapStrings (k: "c.colors.${k} = '#${p.fondo}'\n") p.bg) pares;

  # El contraste WCAG 2 de cada par (la luminancia relativa de sRGB), con la tabla en $out; falla si uno no llega
  # a 4,5:1 (AA para texto normal).
  contraste = runCommand "qutebrowser-prueba-contraste" {
    pares = builtins.toJSON (map (p: { inherit (p) que texto fondo; }) pares);
    passAsFile = [ "pares" ];
  } ''
    ${python3}/bin/python3 - "$paresPath" > $out <<'EOF'
    import json, sys
    def luminancia(h):
        canales = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
        r, g, b = [x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in canales]
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    def razon(a, b):
        claro, oscuro = sorted([luminancia(a), luminancia(b)], reverse=True)
        return (claro + 0.05) / (oscuro + 0.05)
    pares = json.load(open(sys.argv[1]))
    print("| qué | texto | fondo | contraste |")
    print("|---|---|---|---|")
    malos = []
    for p in pares:
        r = razon(p["texto"], p["fondo"])
        print(f"| {p['que']} | #{p['texto']} | #{p['fondo']} | {r:.1f}:1 |")
        if r < 4.5:
            malos.append(f"{p['que']}: {r:.2f}")
    if malos:
        sys.exit("contraste por debajo de 4,5:1: " + "; ".join(malos))
    EOF
    cat $out >&2
  '';

  configPy = writeText "config.py" ''
    # Generado por nix (~/dev/nixos-config-2, pkgs/qutebrowser-prueba): se rehace en cada arranque.
    # Los cambios con :set van a autoconfig.yml, que se carga al final y le gana a esto.

    # -- Pestañas a la izquierda, con íconos; xt las esconde (aparecen un momento al cambiar de pestaña) --
    # Compactas (el tamaño de siempre era muy grande para lo que muestra): angostas, bajas y con la letra de la interfaz
    c.tabs.position = 'left'
    c.tabs.width = 180
    c.tabs.show = 'always'
    c.tabs.show_switching_delay = 1200
    c.tabs.favicons.show = 'always'
    c.tabs.favicons.scale = 1.0
    c.tabs.title.format = '{tree}{collapsed}{audio}{index} {current_title}'
    c.tabs.title.format_pinned = '{tree}{collapsed}{audio}{index} {current_title}'
    # sin relleno arriba ni abajo: las líneas del árbol ({tree}) se dibujan con caracteres y sólo se tocan así
    c.tabs.padding = {'top': 0, 'bottom': 0, 'left': 3, 'right': 4}
    c.tabs.indicator.width = 2
    c.tabs.indicator.padding = {'top': 0, 'bottom': 0, 'left': 0, 'right': 4}
    c.tabs.new_position.unrelated = 'last'
    c.tabs.last_close = 'ignore'

    # -- Los grupos (arbol-de-pestanas.patch y grupos.patch) --
    # Las pestañas en árbol: lo que se abre desde una página (clic del medio, F) va adentro de ella, al final; lo
    # que se abre con O, al final del primer nivel. Un grupo es una pestaña de primer nivel con hijas, o el
    # encabezado que crea zG. Los atajos z* son los de la rama de qutebrowser (los de vim para los pliegues):
    #   zG nombre  crear un grupo         zg nombre  crear un subgrupo adentro de esta pestaña
    #   za         colapsar o abrir       zj / zk    ir al grupo siguiente / anterior (Alt+J / Alt+K también)
    #   N zm       mover esta pestaña al grupo de la pestaña N (con sus hijas)
    #   zO         nueva pestaña al final de este grupo      zt  lo mismo, pidiendo la URL (como O)
    #   zo         nueva pestaña adentro de esta
    #   zH / zL    sacar de un nivel / meter en la pestaña de arriba
    #   zJ / zK    hermana siguiente / anterior   zp  ir al encabezado   zd  cerrar con las hijas
    c.tabs.tree_tabs = True
    c.tabs.new_position.tree.new_child = 'last'
    c.tabs.new_position.tree.new_sibling = 'next'
    c.tabs.new_position.tree.new_toplevel = 'last'
    config.bind('zj', 'tree-tab-group-focus next')
    config.bind('zk', 'tree-tab-group-focus prev')
    config.bind('zm', 'tree-tab-reparent')
    # Abrir en el grupo: la pestaña nueva es la última hija del encabezado del grupo
    # (qute://treegroup) más cercano hacia arriba, aunque la activa esté varios niveles abajo; fuera de un grupo, al
    # final del primer nivel. El zO de la rama (`:open -tS`) la ponía al lado de la activa, en su mismo nivel.
    config.bind('zO', 'tree-tab-open-in-group')
    config.bind('zt', 'cmd-set-text -s :tree-tab-open-in-group')
    for modo in ['normal', 'insert']:
        config.bind('<Alt-j>', 'tree-tab-group-focus next', mode=modo)
        config.bind('<Alt-k>', 'tree-tab-group-focus prev', mode=modo)

    # -- El máximo de espacio para la página --
    # la barra de estado siempre, con lo justo: teclas, búsqueda, URL, posición y carga
    c.statusbar.show = 'always'
    c.statusbar.widgets = ['keypress', 'search_match', 'url', 'scroll', 'progress']
    c.scrolling.bar = 'overlay'
    c.downloads.position = 'bottom'
    c.downloads.remove_finished = 10000
    c.completion.height = '40%'
    c.window.hide_decoration = True
    c.messages.timeout = 4000

    # -- Las sesiones: la de las fijadas se guarda y se restaura sola --
    c.auto_save.session = True
    c.session.lazy_restore = False

    # -- El teclado: los binds de omisión (vim); Alt+1 a Alt+5 ya saltan a las fijadas --
    config.bind('xt', 'config-cycle tabs.show always switching')
    config.bind('<Alt-t>', 'config-cycle tabs.show always switching')
    config.bind('<Alt-t>', 'config-cycle tabs.show always switching', mode='insert')
    for n in range(1, 6):
        config.bind(f'<Alt-{n}>', f'tab-focus {n}', mode='insert')
    # Que nada cierre todo sin preguntar: sin Ctrl+Q, y cerrar la última ventana (Ctrl+Shift+W, ZZ,
    # ZQ o desde Hyprland) pide confirmación. confirm_quit sólo se mira al cerrar una ventana (closeEvent de
    # mainwindow.py), no en :quit, así que ZZ y ZQ (que eran :quit) pasan a cerrar la ventana; :quit escrito a mano
    # sigue saliendo sin preguntar.
    config.unbind('<Ctrl-q>')
    config.bind('ZZ', 'close')
    config.bind('ZQ', 'close')
    c.confirm_quit = ['always']

    # -- El bloqueo de publicidad --
    c.content.blocking.enabled = True
    c.content.blocking.method = 'both'
    c.content.blocking.adblock.lists = [${py listas}]

    ${lib.optionalString (web != null) ''
    # -- El login del IdP de trabajo con el ticket de Kerberos (SPNEGO). QtWebEngine trae Kerberos (webengine_kerberos)
    # y libgssapi_krb5 enlazada; la caché es la de default_ccache_name del krb5.conf, la misma de kinit. --
    c.qt.args = ['auth-server-allowlist=${web.idp}']

    ''}# -- Lo de los servicios fijos: avisos al escritorio (swaync), y nada de pedir permiso cada vez --
    c.content.notifications.presenter = 'libnotify'
    c.content.notifications.enabled = 'ask'
    ${lib.concatMapStrings (d: ''
    config.set('content.notifications.enabled', True, 'https://${d}/*')
    '') dominios}
    config.set('content.javascript.clipboard', 'access-paste', 'https://web.whatsapp.com/*')
    config.set('content.javascript.clipboard', 'access-paste', 'https://web.telegram.org/*')
    # sin videos que arrancan solos (los diarios), salvo en YouTube y YouTube Music
    c.content.autoplay = False
    config.set('content.autoplay', True, 'https://www.youtube.com/*')
    config.set('content.autoplay', True, 'https://music.youtube.com/*')

    # -- Privacidad, como el Firefox de siempre --
    c.content.geolocation = False
    c.content.webrtc_ip_handling_policy = 'default-public-interface-only'
    c.content.cookies.accept = 'no-3rdparty'
    c.content.headers.do_not_track = True
    c.url.searchengines = {'DEFAULT': 'https://duckduckgo.com/?q={}'}

    # -- El tema (tema, ${tema.paleta}) --
    # la letra de la interfaz, dos puntos más chica que la del escritorio
    c.fonts.default_family = ['${tema.fuentes.interfaz}']
    c.fonts.default_size = '${toString (tema.fuentes.tamano - 2)}pt'
    c.colors.webpage.preferred_color_scheme = 'dark'
    c.colors.webpage.bg = '#${c.fondo}'

    # los pares de texto y fondo (`pares`, con el contraste medido en el build)
    ${lineasPares}
    # lo que no es texto
    c.colors.tabs.indicator.start = '#${c.enlace}'
    c.colors.tabs.indicator.stop = '#${c.secundario}'
    c.colors.tabs.indicator.error = '#${c.error}'
    c.colors.statusbar.progress.bg = '#${c.acento}'
    c.colors.completion.scrollbar.fg = '#${c.campoHover}'
    c.colors.downloads.bar.bg = '#${c.fondo}'
    c.hints.border = '1px solid #${c.fondo}'
    c.colors.prompts.border = '1px solid #${c.campo}'

    # Lo que cambie Rulo con :set (autoconfig.yml), al final, así le gana a lo de arriba
    config.load_autoconfig(True)
  '';
in
writeShellApplication {
  name = "qutebrowser-prueba";
  runtimeInputs = [ coreutils findutils ];
  text = ''
    # los colores pasaron la medición de contraste: ${contraste}
    base="''${XDG_DATA_HOME:-$HOME/.local/share}/qutebrowser-prueba"
    mkdir -p "$base/config" "$base/data/greasemonkey" "$base/data/sessions"
    ln -sfn ${configPy} "$base/config/config.py"
    ln -sfn ${./youtube-publicidad.user.js} "$base/data/greasemonkey/prueba-youtube-publicidad.user.js"

    # las opciones van antes de los argumentos de Rulo, y los comandos después (argparse no junta posicionales
    # separados por opciones)
    opciones=()
    comandos=()
    # El primer arranque: la sesión con las cinco fijadas. Después la guarda y la restaura qutebrowser
    # (data/state dice cuál, o _autosave si se cortó), así que no se vuelve a instalar ni se duplica: sin
    # data/state ni _autosave, qutebrowser no restaura nada solo, y se carga una sola vez.
    if [ ! -e "$base/data/state" ] && [ ! -e "$base/data/sessions/_autosave.yml" ]; then
      [ -e "$base/data/sessions/default.yml" ] || install -m 644 ${sesion} "$base/data/sessions/default.yml"
      opciones+=(-r default)
    fi
    # Las listas de bloqueo: qutebrowser no las baja solo
    cache="$base/data/adblock-cache.dat"
    if [ ! -e "$cache" ] || [ -n "$(find "$cache" -mtime +7)" ]; then
      comandos+=(":adblock-update")
    fi
    # Siempre un comando que no hace nada: si ya hay uno abierto y lo vuelven a lanzar sin URL ni comando,
    # qutebrowser abre otra ventana con la página de inicio; con un comando, no (y al lado de una URL no molesta).
    comandos+=(":nop")

    # Qt en Wayland con la escala fraccionaria tal cual (wp_fractional_scale), sin redondear a entero
    export QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough
    export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-wayland;xcb}"
    exec ${qutebrowserArbol}/bin/qutebrowser --basedir "$base" "''${opciones[@]}" "$@" "''${comandos[@]}"
  '';
  passthru = { inherit configPy sesion contraste qutebrowserArbol; };
}

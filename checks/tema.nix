# Prueba del tema (modules/tema, la opción `tema`) y del escritorio de maltalef en pirincho:
# nix build .#checks.x86_64-linux.tema
#
# - La paleta gruvbox-verde (la de omisión): el esquema es gruvbox-dark-hard de nix-colors, y gana sobre un
#   `colorScheme = lib.mkDefault …` (el de home/<usuario>/global.nix); los colores con nombre (acento #689d6a…) y la
#   terminal son los de la copia de abajo; las fuentes, las de antes (FiraCode Nerd Font en las herramientas, la sans
#   sin tocar, sin instalar fuentes) y el fondo, el wallpaper.jpg de pirincho.
#   Las aplicaciones, las de antes del tema: Gruvbox (variante teal, la del acento verde) que carga en GTK3 sin quejas
#   y GTK4 importándolo, Papirus-Dark con las carpetas verdes (también las de maltalef en pirincho; las de mw, azules),
#   capitaine-cursors, acento green en dconf, la paleta Qt con el acento; nvim con el colorscheme gruvbox-verde sobre
#   el fondo de foot (sin errores y sin dejar grupos con los del colorscheme por omisión).
# - Una paleta de otro módulo (`tema.paletas.prueba`, con sus fuentes y su fondo, como las que suma el input infra):
#   se elige por nombre, instala sus fuentes, pone la sans (fc-match sans-serif la da con la configuración de
#   fontconfig del home), GTK, Qt y dconf con ella, y su fondo por omisión.
# - El centro de swaync de maltalef en pirincho: las notificaciones primero y los conmutadores al final de todo. El
#   cuerpo de las notificaciones llega a 4,5:1 (WCAG AA) contra la tarjeta, también las de baja urgencia.
# - Firefox de maltalef en pirincho: el tema del sistema (sigue al GTK), sin la columna de íconos del sidebar, con los
#   encabezados del sidebar ocultos en userChrome (y que el Firefox del lock todavía los tenga), el panel del sidebar
#   en píxeles de pantalla enteros a 1.25 (sin el margen izquierdo, el de abajo en 8 px y el ancho en múltiplos de
#   4 px, como todavía lo arma Firefox) y sin esquinas redondeadas, sombra ni contorno (la máscara), sin el botón del
#   sidebar en la barra (y que Firefox todavía lo introduzca como hoy), la Browser Toolbox habilitada y preguntando
#   antes de conectar, y sólo el foco encima. El de mw, sin layout.css.devPixelsPerPx.
# - La waybar de maltalef en pirincho: sin el módulo de red, con el módulo VPN, el volumen y la batería en la isla del
#   estado, los emojis, las métricas sin ancho fijo (cada isla mide lo que su texto) y con el número pegado al
#   emoji, el calendario en el reloj, y sólo los workspaces ocupados y el activo.
# - Qt con cada paleta: una app Qt 6 y una Qt 5 (PyQt, offscreen), con el entorno de la sesión del home, cargan el
#   plugin de qt6ct/qt5ct y les queda Fusion con la paleta.
{ pkgs, inputs, outputs }:
let
  inherit (pkgs) lib;

  conTema = ajustes: (inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      outputs.homeManagerModules.tema
      inputs.nix-colors.homeManagerModule
      {
        home.username = "prueba";
        home.homeDirectory = "/home/prueba";
        home.stateVersion = "25.05";
        colorScheme = lib.mkDefault inputs.nix-colors.colorSchemes.gruvbox-dark-hard;
        tema = { enable = true; } // ajustes;
      }
      # Una paleta de otro módulo, como las que suma el input infra: gruvbox-verde con otro nombre, sus fuentes
      # (Inter, que el fontconfig del sandbox no trae: el de nixpkgs sólo trae DejaVu), la sans, las cifras y su fondo
      ({ config, ... }: {
        tema.paletas.prueba = config.tema.paletas.gruvbox-verde // {
          esquema = config.tema.paletas.gruvbox-verde.esquema // { slug = "prueba"; };
          fuentes = {
            paquete = pkgs.inter;
            interfaz = "Inter";
            sistema = "Inter";
            cifras = "Inter Display";
          };
          fondo = wallpaper;
        };
      })
    ];
  }).config;

  # La paleta gruvbox-verde, con el fondo de pirincho
  wallpaper = ../home/maltalef/features/desktop/hyprland/wallpaper.jpg;
  cg = conTema { fondo.imagen = wallpaper; };
  temaG = cg.tema;

  # La paleta de otro módulo
  cp = conTema { paleta = "prueba"; };
  temaP = cp.tema;

  # Los homes de pirincho: maltalef con el tema (gruvbox-verde), mw sin
  pirincho = outputs.nixosConfigurations.pirincho.config.home-manager.users;

  distintos = nombre: a: b:
    lib.concatMap (k: lib.optional ((a.${k} or null) != (b.${k} or null))
      "${nombre}.${k}: el tema dice ${toString (b.${k} or "nada")} y la copia ${toString (a.${k} or "nada")}")
      (lib.unique (lib.attrNames a ++ lib.attrNames b));

  # gruvbox-verde: el mapeo de modules/tema/gruvbox-verde.nix, copiado acá para notar cuando cambia
  esperadoG = {
    colores = {
      fondo = "1d2021"; fondoHondo = "141617"; superficie = "282828"; campo = "3c3836"; campoHover = "504945";
      texto = "ebdbb2"; textoTenue = "bdae93"; textoClaro = "fbf1c7"; acento = "689d6a"; sobreAcento = "1d2021";
      secundario = "8ec07c"; foco = "8ec07c"; seleccion = "504945"; enlace = "83a598"; enlaceHover = "8ec07c";
      alerta = "cc241d"; aviso = "fabd2f"; ok = "b8bb26"; error = "fb4934"; errorBorde = "cc241d";
      apagado = "928374"; bordeInactivo = "1d2021";
    };
    # la de foot antes del tema (master 844765d)
    terminal = {
      Background = "282828"; Foreground = "ebdbb2"; Cursor = "ebdbb2";
      Color0 = "282828"; Color1 = "cc241d"; Color2 = "98971a"; Color3 = "d79921";
      Color4 = "458588"; Color5 = "b16286"; Color6 = "689d6a"; Color7 = "ebdbb2";
      Color8 = "928374"; Color9 = "fb4934"; Color10 = "b8bb26"; Color11 = "fabd2f";
      Color12 = "83a598"; Color13 = "d3869b"; Color14 = "8ec07c"; Color15 = "fbf1c7";
    };
  };
  erroresGruvbox =
    lib.optional (temaG.esquema != inputs.nix-colors.colorSchemes.gruvbox-dark-hard) "el esquema no es gruvbox-dark-hard de nix-colors"
    ++ lib.optional (cg.colorScheme.slug != "gruvbox-dark-hard") "colorScheme es ${cg.colorScheme.slug}, no gruvbox-dark-hard"
    ++ distintos "colores" esperadoG.colores temaG.colores
    ++ distintos "terminal" esperadoG.terminal temaG.terminal
    ++ lib.optional (temaG.paleta != "gruvbox-verde") "la paleta por omisión es ${temaG.paleta}, no gruvbox-verde"
    ++ lib.optional (temaG.fuentes.interfaz != "FiraCode Nerd Font") "la fuente de interfaz es ${temaG.fuentes.interfaz}, no FiraCode Nerd Font"
    ++ lib.optional (temaG.fuentes.cifras != "FiraCode Nerd Font") "la fuente de cifras es ${temaG.fuentes.cifras}, no la de interfaz"
    ++ lib.optional (temaG.fuentes.sistema != null) "la fuente de sistema no es null: tocaría la sans"
    ++ lib.optional (cg.fonts.fontconfig.defaultFonts.sansSerif != [ ]) "fontconfig: la sans es ${toString cg.fonts.fontconfig.defaultFonts.sansSerif}"
    ++ lib.optional (cg.gtk.font != null) "gtk.font está puesta"
    ++ lib.optional (cg.dconf.settings."org/gnome/desktop/interface" ? font-name) "dconf: font-name está puesta"
    ++ lib.optional (cg.qt.qt6ctSettings ? Fonts) "qt6ct: Fonts está puesta"
    ++ lib.optional (temaG.fuentes.paquete != null) "instala fuentes"
    ++ lib.optional (temaG.fondo.imagen != wallpaper) "el fondo no es wallpaper.jpg";

  # Una paleta de otro módulo (prueba): elegida por nombre, con sus fuentes, la sans, las cifras y su fondo
  interfazP = cp.dconf.settings."org/gnome/desktop/interface";
  erroresOtra =
    lib.optional (cp.colorScheme.slug != "prueba") "otra paleta: colorScheme es ${cp.colorScheme.slug}, no el de la paleta"
    ++ lib.optional (temaP.colores != temaG.colores) "otra paleta: los colores con nombre no son los de la paleta"
    ++ lib.optional (!lib.elem pkgs.inter cp.home.packages) "otra paleta: no instala sus fuentes"
    ++ lib.optional (!cp.fonts.fontconfig.enable) "otra paleta: fontconfig no está prendido"
    ++ lib.optional (cp.fonts.fontconfig.defaultFonts.sansSerif != [ "Inter" ])
      "otra paleta: la sans es ${toString cp.fonts.fontconfig.defaultFonts.sansSerif}, no Inter"
    ++ lib.optional (temaP.fuentes.cifras != "Inter Display") "otra paleta: la fuente de cifras es ${temaP.fuentes.cifras}"
    ++ lib.optional ((cp.gtk.font.name or null) != "Inter" || (cp.gtk.font.package or null) != pkgs.inter)
      "otra paleta: gtk.font no es Inter con su paquete"
    ++ lib.optional ((interfazP.font-name or null) != "Inter 11") "otra paleta: dconf font-name no es Inter 11"
    ++ lib.optional (cp.qt.qt6ctSettings.Fonts.general or null != ''"Inter,11"'') "otra paleta: qt6ct no tiene la fuente"
    ++ lib.optional (temaP.fondo.imagen != wallpaper) "otra paleta: el fondo no es el de la paleta"
    ++ lib.optional (cp.qt.platformTheme.name != "qtct") "qt: platformTheme no es qtct"
    ++ lib.optional (cp.qt.qt5ctSettings != cp.qt.qt6ctSettings) "qt5ct y qt6ct no tienen la misma configuración";

  # gruvbox-verde: las de antes del tema (Gruvbox en su variante teal, Papirus-Dark, capitaine-cursors), acento verde
  interfazG = cg.dconf.settings."org/gnome/desktop/interface";
  qtctG = cg.qt.qt6ctSettings.Appearance;
  gruvboxGtk = "Gruvbox-Teal-Dark";
  acentoGtkGruvbox = "89b482";
  erroresAplicacionesGruvbox =
    lib.optional (cg.gtk.theme.name != gruvboxGtk) "gtk.theme es ${cg.gtk.theme.name}, no ${gruvboxGtk}"
    ++ lib.optional ((cg.gtk.gtk4.theme.name or null) != gruvboxGtk) "gtk4.theme no es ${gruvboxGtk}"
    ++ lib.optional (!lib.hasInfix "/share/themes/${gruvboxGtk}/gtk-4.0/gtk.css" cg.xdg.configFile."gtk-4.0/gtk.css".text)
      "gtk-4.0/gtk.css no importa el tema de ${gruvboxGtk}"
    ++ lib.optional (lib.hasInfix "--accent-bg-color" cg.xdg.configFile."gtk-4.0/gtk.css".text) "gtk-4.0/gtk.css trae una hoja de acento encima"
    ++ lib.optional (interfazG.color-scheme != "prefer-dark") "dconf: color-scheme no es prefer-dark"
    ++ lib.optional (cg.gtk.iconTheme.name != "Papirus-Dark" || qtctG.icon_theme != "Papirus-Dark") "los íconos no son Papirus-Dark"
    ++ lib.optional (cg.home.pointerCursor.name != "capitaine-cursors" || cg.home.pointerCursor.size != 24) "el cursor no es capitaine-cursors 24"
    ++ lib.optional (interfazG.gtk-theme != gruvboxGtk) "dconf: gtk-theme no es ${gruvboxGtk}"
    ++ lib.optional (interfazG.accent-color != "green") "dconf: accent-color no es green"
    ++ lib.optional (interfazG.cursor-theme != "capitaine-cursors") "dconf: cursor-theme no es capitaine-cursors"
    ++ lib.optional (qtctG.style != "Fusion" || !qtctG.custom_palette) "qt6ct: no es Fusion con la paleta propia";

  # El centro de swaync de maltalef en pirincho: las notificaciones primero (estiradas), los controles abajo y los
  # conmutadores, y al pie la fila de energía: suspender, cerrar la sesión, reiniciar y apagar (sus guiones se miran en
  # el build)
  centro = pirincho.maltalef.services.swaync.settings;
  widgetsCentro = [ "title" "notifications" "inhibitors" "mpris" "volume" "backlight" "buttons-grid" "buttons-grid#energia" ];
  energia = centro.widget-config."buttons-grid#energia" or { };
  erroresCentro =
    lib.optional (centro.widgets != widgetsCentro)
      "el centro de swaync tiene ${toString centro.widgets}, no ${toString widgetsCentro}"
    ++ lib.optional (!(centro.widget-config.notifications.vexpand or false)) "las notificaciones del centro no se estiran"
    ++ lib.optional (lib.length (energia.actions or [ ]) != 4 || energia.buttons-per-row or 0 != 4)
      "la fila de energía no es de cuatro botones en una fila"
    ++ lib.optional (lib.any (x: x == null) [ cuerpo alfaTarjeta opacidadBaja ])
      "la hoja de swaync ya no tiene el color del cuerpo, --noti-bg-alpha o la opacidad de las de baja urgencia"
    ++ lib.optional (cuerpo != null && nombreCuerpo == null)
      "el cuerpo de las notificaciones (#${cuerpo}) no es un color de la paleta gruvbox-verde";

  # El cuerpo de las notificaciones de swaync de maltalef en pirincho: su color, la opacidad de la tarjeta y la de las
  # de baja urgencia, leídos de la hoja (sin espacios). El contraste se mide en el build, con gruvbox-verde (la de
  # pirincho).
  estiloSwaync = lib.replaceStrings [ " " "\t" "\n" ] [ "" "" "" ] pirincho.maltalef.services.swaync.style;
  enEstilo = re: let m = builtins.match ".*${re}.*" estiloSwaync; in if m == null then null else lib.head m;
  cuerpo = enEstilo "\\.text-box\\.body\\{color:#([0-9a-f]{6});";
  alfaTarjeta = enEstilo "--noti-bg-alpha:([0-9.]+);";
  opacidadBaja = enEstilo "\\.notification\\.low\\{opacity:([0-9.]+);";
  nombreCuerpo = lib.findFirst (n: temaG.colores.${n} == cuerpo) null (lib.attrNames temaG.colores);

  # La waybar de maltalef en pirincho (las islas del tema): sin el módulo de red (lo hace el nm-applet de la bandeja),
  # el estado con el módulo VPN (barra-vpn), el volumen y la batería; íconos
  # emojis de Noto Color Emoji; las métricas con el número pegado al emoji y sin ancho fijo (ni relleno en el formato
  # ni min-length: las islas ocupaban mucho); los colores de aviso y alerta de la paleta en
  # @define-color; y los workspaces vacíos que no se ven, escondidos (sólo los ocupados y el activo)
  barra = pirincho.maltalef.programs.waybar;
  mainbar = barra.settings.mainbar;
  metricas = [ "disk" "memory" "cpu" "temperature" "battery" "wireplumber" ];
  # «<span font='Noto Color Emoji'>📂</span> {percentage_used}%»: el emoji, un espacio y el número tal cual
  pegado = f: builtins.match "<span font='Noto Color Emoji'>[^<]+</span> [{][a-zA-Z_]+[}](%|°C)" f != null;
  erroresBarra =
    lib.optional (mainbar ? network || lib.any (g: lib.elem "network" (mainbar.${g}.modules or [ ]))
      (lib.filter (lib.hasPrefix "group/") (lib.attrNames mainbar)))
      "waybar: todavía tiene el módulo network"
    ++ lib.optional (mainbar."group/estado".modules != [ "custom/vpn" "wireplumber" "battery" ])
      "waybar: la isla del estado tiene ${toString mainbar."group/estado".modules}, no custom/vpn wireplumber battery"
    ++ lib.optional (!lib.hasSuffix "/bin/barra-vpn estado" (mainbar."custom/vpn".exec or "")
      || !lib.hasSuffix "/bin/barra-vpn menu" (mainbar."custom/vpn".on-click or ""))
      "waybar: custom/vpn no corre barra-vpn estado y menu"
    ++ lib.optional (!lib.hasInfix "pavucontrol" (mainbar.wireplumber.on-click-right or "")) "waybar: el volumen no abre pavucontrol"
    ++ map (m: "waybar: ${m} no es el emoji y el número pegado: ${mainbar.${m}.format}")
      (lib.filter (m: !pegado mainbar.${m}.format) metricas)
    ++ lib.optional (!pegado mainbar.wireplumber.format-muted) "waybar: el volumen silenciado no es el emoji y el número pegado"
    ++ map (m: "waybar: ${m} tiene ancho fijo (min-length o align): las islas ocupan de más")
      (lib.filter (m: mainbar.${m} ? min-length || mainbar.${m} ? align) metricas)
    ++ lib.optional (!lib.hasPrefix "<span font='Noto Color Emoji'>" mainbar."custom/notifications".format)
      "waybar: la campana no es el emoji"
    ++ lib.optional (mainbar."hyprland/window".max-length != 30) "waybar: el título no se acorta a 30"
    ++ lib.optional (!lib.hasInfix "{calendar}" (mainbar.clock.tooltip-format or "")) "waybar: el reloj no tiene el calendario"
    ++ lib.optional (!lib.hasInfix "@define-color warning #${temaG.colores.aviso};" barra.style
      || !lib.hasInfix "@define-color alert #${temaG.colores.alerta};" barra.style)
      "waybar: aviso y alerta no son los de gruvbox-verde"
    ++ lib.optional (!lib.hasInfix "#workspaces button.empty:not(.active):not(.visible) label" barra.style)
      "waybar: no esconde los workspaces vacíos que no se ven";

  # Firefox de maltalef en pirincho: el tema del sistema (que sigue al GTK) en extensions.activeThemeID, que sólo
  # decide el tema de un perfil nuevo (en uno existente manda extensions.json: se cambia a mano en about:addons),
  # layout.css.devPixelsPerPx como cadena (un entero, firefox lo descarta; un decimal home-manager lo escribe como
  # cadena, pero mejor decirlo), el sidebar sin la columna de íconos, y
  # en userChrome los dos encabezados del sidebar ocultos (el de antes del rediseño y el de los paneles de extensión),
  # el botón del sidebar fuera de la barra y ya introducido, y sólo el foco de la paleta (en el build se mira que
  # Firefox todavía tenga esos elementos y ese botón). El de mw, sin layout.css.devPixelsPerPx (se sacó:
  # tenía un 0.95, que home-manager escribía como "0.95" y firefox aplicaba; su prefs.js lo conserva hasta que se
  # resetee el pref o se cree un perfil nuevo)
  firefox = pirincho.maltalef.programs.firefox;
  perfil = firefox.profiles.maltalef;
  erroresFirefox =
    lib.optional (perfil.settings."extensions.activeThemeID" != "default-theme@mozilla.org")
      "firefox: el tema no es default-theme@mozilla.org"
    ++ lib.optional (!builtins.isString (perfil.settings."layout.css.devPixelsPerPx" or ""))
      "firefox: layout.css.devPixelsPerPx no es una cadena (firefox la descarta)"
    ++ lib.optional (perfil.settings."sidebar.visibility" or null != "hide-launcher") "firefox: sidebar.visibility no es hide-launcher"
    ++ lib.optional (!lib.hasInfix "#webextpanels-window > #sidebar-panel-header" perfil.userChrome)
      "firefox: userChrome no oculta el encabezado de los paneles de extensión"
    ++ lib.optional (!lib.hasInfix "#sidebar-header" perfil.userChrome) "firefox: userChrome no oculta #sidebar-header"
    ++ lib.optional (!lib.hasInfix "padding-inline-start: 0 !important" perfil.userChrome)
      "firefox: userChrome no le saca a #sidebar-box el margen izquierdo (la franja, y Sidebery borroso a 1.25)"
    ++ lib.optional (!lib.hasInfix "padding-block-end: 8px !important" perfil.userChrome)
      "firefox: userChrome no le pone a #sidebar-box el margen de abajo en 8px (0.5rem = 7,33 px, Sidebery borroso a 1.25)"
    ++ lib.optional (!lib.hasInfix "max-width: round(down, 100%, 4px) !important" perfil.userChrome)
      "firefox: userChrome no redondea el ancho de #sidebar a múltiplos de 4 px (Sidebery borroso a 1.25)"
    ++ lib.optional (!lib.hasInfix "max-width: round(down, 100%, 4px) !important;\n\t\t\tborder-radius: 0 !important;\n\t\t\tbox-shadow: none !important;\n\t\t\toutline: none !important;" perfil.userChrome)
      "firefox: userChrome no le saca a #sidebar el borde redondeado, la sombra y el contorno (la máscara, Sidebery borroso a 1.25)"
    ++ lib.optional (!lib.hasInfix "padding-block-end: 8px !important;\n\t\t\tborder-radius: 0 !important;" perfil.userChrome)
      "firefox: userChrome no le pone a #sidebar-box la esquina en recto (el panel se saldría por la curva)"
    ++ lib.optional (perfil.settings."devtools.chrome.enabled" or null != true
      || perfil.settings."devtools.debugger.remote-enabled" or null != true)
      "firefox: la Browser Toolbox no está habilitada (devtools.chrome.enabled y devtools.debugger.remote-enabled)"
    ++ lib.optional (perfil.settings."devtools.debugger.prompt-connection" or true != true)
      "firefox: la Browser Toolbox acepta conexiones sin preguntar (pirincho tiene otro usuario en el mismo localhost)"
    ++ lib.optional (perfil.settings."browser.toolbarbuttons.introduced.sidebar-button" or null != true)
      "firefox: el botón del sidebar no está marcado como ya introducido (firefox lo pone en la barra)"
    ++ lib.optional (lib.elem "sidebar-button"
      (builtins.fromJSON perfil.settings."browser.uiCustomization.state").placements.nav-bar)
      "firefox: el botón del sidebar está en la barra de navegación"
    ++ lib.optional (!lib.hasInfix "--focus-outline-color: #${temaG.colores.foco}" perfil.userChrome)
      "firefox: userChrome no tiene el foco de gruvbox-verde"
    ++ lib.optional (lib.hasInfix "--toolbar-bgcolor" perfil.userChrome) "firefox: userChrome pisa los colores del GTK"
    ++ lib.optional (pirincho.mw.programs.firefox.profiles.mw.settings ? "layout.css.devPixelsPerPx")
      "firefox: el perfil de mw tiene layout.css.devPixelsPerPx (se sacó a propósito)";

  # Un GTK3 de verdad (en Xvfb) con el tema: carga sin errores, y da sus colores de fondo, texto y campo, y el
  # redondeo de los botones.
  pruebaGtk3 = pkgs.writeText "prueba-gtk3.py" ''
    import sys, gi
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk
    v = Gtk.Window(); v.get_style_context().add_class("background")
    campo = Gtk.Entry(); boton = Gtk.Button(label="x"); caja = Gtk.Box(); caja.add(campo); caja.add(boton); v.add(caja)
    v.show_all()
    N = Gtk.StateFlags.NORMAL
    def hexa(c): return "%02x%02x%02x" % (round(c.red * 255), round(c.green * 255), round(c.blue * 255))
    print("fondo", hexa(v.get_style_context().get_property("background-color", N)))
    print("texto", hexa(v.get_style_context().get_color(N)))
    print("campo", hexa(campo.get_style_context().get_property("background-color", N)))
    print("redondeo", boton.get_style_context().get_property("border-radius", N))
  '';
  # nvim con el colorscheme de la paleta (tema.nvim): carga sin errores, y ningún grupo queda con un color del
  # colorscheme por omisión de nvim (sus grises NvimDark*/NvimLight*), salvo los de depuración del redibujo. Escribe
  # <paleta>.txt.
  pruebaNvim = nombre: pkgs.writeText "prueba-nvim-${nombre}.lua" ''
    local function colores(h) return { h.fg, h.bg, h.sp } end
    -- los de depuración (y lo que se enlaza a ellos) quedan como en nvim
    local function depuracion(n) return n:match('^RedrawDebug') or n == 'NvimInternalError' end
    local omision = {}
    for n, h in pairs(vim.api.nvim_get_hl(0, {})) do
      if not h.link and not depuracion(n) then
        for _, c in pairs(colores(h)) do omision[c] = true end
      end
    end
    vim.cmd.colorscheme('${nombre}')
    local salida = { 'nombre ' .. vim.g.colors_name, 'terminal1 ' .. vim.g.terminal_color_1:sub(2) }
    for n in pairs(vim.api.nvim_get_hl(0, {})) do
      for _, c in pairs(colores(vim.api.nvim_get_hl(0, { name = n, link = false }))) do
        if omision[c] and not depuracion(n) then salida[#salida + 1] = string.format('fuga %s %06x', n, c) end
      end
    end
    local function hexa(c) return c and string.format('%06x', c) or '-' end
    for _, n in ipairs({ 'Normal', 'Visual', 'PmenuSel', 'StatusLine', 'CursorLine', 'Comment', 'DiagnosticError',
                         'DiagnosticWarn', 'DiagnosticInfo', '@keyword', '@string' }) do
      local h = vim.api.nvim_get_hl(0, { name = n, link = false })
      salida[#salida + 1] = n .. ' ' .. hexa(h.fg) .. ' ' .. hexa(h.bg)
    end
    salida[#salida + 1] = 'errmsg ' .. vim.v.errmsg
    vim.fn.writefile(salida, '${nombre}.txt')
  '';

  # El contraste WCAG del cuerpo de las notificaciones contra la tarjeta (la superficie con --noti-bg-alpha), sobre un
  # fondo de pantalla negro, gris y blanco; las de baja urgencia, con su opacidad sobre el mismo fondo. AA: 4,5:1.
  # argumentos: <alfa de la tarjeta> <opacidad de las bajas> y, por paleta, <nombre> <cuerpo> <superficie>
  contrasteSwaync = pkgs.writeText "contraste-swaync.py" ''
    import sys

    def rgb(h):
        return [int(h[i:i + 2], 16) for i in (0, 2, 4)]

    def mezcla(a, b, t):
        return [t * x + (1 - t) * y for x, y in zip(a, b)]

    def luminancia(c):
        c = [x / 255 for x in c]
        c = [x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c]
        return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]

    def contraste(a, b):
        claro, oscuro = sorted([luminancia(a), luminancia(b)], reverse=True)
        return (claro + 0.05) / (oscuro + 0.05)

    alfa, baja = float(sys.argv[1]), float(sys.argv[2])
    falla = False
    resto = sys.argv[3:]
    for nombre, cuerpo, superficie in zip(resto[0::3], resto[1::3], resto[2::3]):
        for fondo in ("000000", "808080", "ffffff"):
            tarjeta = mezcla(rgb(superficie), rgb(fondo), alfa)
            normal = contraste(rgb(cuerpo), tarjeta)
            bajo = contraste(mezcla(rgb(cuerpo), rgb(fondo), baja), mezcla(tarjeta, rgb(fondo), baja))
            print(f"contraste del cuerpo, {nombre}, fondo #{fondo}: {normal:.2f} (baja urgencia: {bajo:.2f})")
            if min(normal, bajo) < 4.5:
                print(f"FALLA: el cuerpo de las notificaciones (#{cuerpo}) con {nombre} no llega a 4,5:1")
                falla = True
    sys.exit(1 if falla else 0)
  '';

  # Una app Qt 5 o Qt 6 de verdad (PyQt, offscreen): el estilo y los colores de la paleta que le quedan.
  pruebaQt = pkgs.writeText "prueba-qt.py" ''
    import sys
    if sys.argv[1] == "6":
        from PyQt6.QtWidgets import QApplication
        from PyQt6.QtGui import QPalette
        R = QPalette.ColorRole
    else:
        from PyQt5.QtWidgets import QApplication
        from PyQt5.QtGui import QPalette
        R = QPalette
    app = QApplication(["prueba"])
    def nombre(estilo): return estilo.name() if sys.argv[1] == "6" else estilo.objectName()
    # el de qt5ct/qt6ct es un QProxyStyle sobre el elegido en la configuración
    print("estilo", nombre(app.style()))
    print("base", nombre(app.style().baseStyle()) if hasattr(app.style(), "baseStyle") else "-")
    p = app.palette()
    for rol in ("Window", "WindowText", "Base", "Highlight", "HighlightedText"):
        print(rol, p.color(getattr(R, rol)).name()[1:])
  '';
  pythonQt = pkgs.python3.withPackages (p: [ p.pyqt5 p.pyqt6 ]);
  # Lo que la sesión le da a Qt: QT_QPA_PLATFORMTHEME de las hm-session-vars, los plugins del home (como su
  # QT_PLUGIN_PATH, con el home.path en vez de /etc/profiles) más los de qtbase (offscreen), y qt5ct.conf/qt6ct.conf.
  # Escribe qt-<paleta>-<versión>.txt y .err.
  pruebaQtCon = nombre: conf: version:
    let
      qtbase = if version == "6" then pkgs.qt6.qtbase else pkgs.libsForQt5.qtbase;
      plugins = qtbase.qtPluginPrefix;
    in ''
      rm -rf conf-qt; mkdir -p conf-qt/qt5ct conf-qt/qt6ct
      cp ${conf.xdg.configFile."qt5ct/qt5ct.conf".source} conf-qt/qt5ct/qt5ct.conf
      cp ${conf.xdg.configFile."qt6ct/qt6ct.conf".source} conf-qt/qt6ct/qt6ct.conf
      XDG_CONFIG_HOME=$PWD/conf-qt QT_QPA_PLATFORM=offscreen QT_DEBUG_PLUGINS=1 QT_FORCE_STDERR_LOGGING=1 \
        QT_QPA_PLATFORMTHEME=${conf.home.sessionVariables.QT_QPA_PLATFORMTHEME} \
        QT_PLUGIN_PATH=${conf.home.path}/${plugins}:${lib.getBin qtbase}/${plugins} \
        ${pythonQt}/bin/python3 ${pruebaQt} ${version} > qt-${nombre}-${version}.txt 2> qt-${nombre}-${version}.err
    '';

  pythonGtk = pkgs.python3.withPackages (p: [ p.pygobject3 ]);
  tipos = lib.makeSearchPath "lib/girepository-1.0" (with pkgs; [
    gtk3 pango.out gdk-pixbuf harfbuzz at-spi2-core glib.out gobject-introspection
  ]);

  # La configuración de fontconfig del home con la otra paleta, en ~/.config/fontconfig/conf.d del sandbox.
  confs = lib.filterAttrs (n: _: lib.hasPrefix "fontconfig/conf.d/" n) cp.xdg.configFile;
  copiarConfs = lib.concatStrings (lib.mapAttrsToList (n: f: ''
    install -Dm444 ${f.source} "$HOME/.config/${n}"
  '') confs);
in
if erroresGruvbox != [ ] then throw ("tema: la paleta gruvbox-verde no es la esperada:\n- "
  + lib.concatStringsSep "\n- " erroresGruvbox
  + "\nSi el mapeo cambió a propósito: actualizá la copia de checks/tema.nix.")
else if erroresAplicacionesGruvbox != [ ] then throw ("tema: las aplicaciones con gruvbox-verde no quedaron como se espera:\n- "
  + lib.concatStringsSep "\n- " erroresAplicacionesGruvbox)
else if erroresOtra != [ ] then throw ("tema: una paleta de otro módulo no quedó como se espera:\n- "
  + lib.concatStringsSep "\n- " erroresOtra)
else if erroresCentro != [ ] then throw ("tema: el centro de swaync de pirincho no quedó como se espera:\n- "
  + lib.concatStringsSep "\n- " erroresCentro)
else if erroresFirefox != [ ] then throw ("tema: firefox de pirincho no quedó como se espera:\n- "
  + lib.concatStringsSep "\n- " erroresFirefox)
else if erroresBarra != [ ] then throw ("tema: la waybar de maltalef en pirincho no quedó como se espera:\n- "
  + lib.concatStringsSep "\n- " erroresBarra)
else pkgs.runCommand "tema" { nativeBuildInputs = [ pkgs.fontconfig pkgs.file pkgs.xvfb-run pkgs.unzip ]; } ''
  export HOME=$PWD/casa
  ${copiarConfs}
  # El fonts.conf de nixpkgs aplica sólo /etc/fonts/conf.d, que en el sandbox no está: la configuración del usuario
  # se incluye como lo hace el 50-user.conf de NixOS.
  cat > fonts.conf <<EOF
  <fontconfig>
    <include>${pkgs.fontconfig.out}/etc/fonts/fonts.conf</include>
    <include ignore_missing="yes" prefix="xdg">fontconfig/conf.d</include>
    <cachedir>$PWD/cache</cachedir>
  </fontconfig>
  EOF
  export FONTCONFIG_FILE=$PWD/fonts.conf

  falla=0
  # espera <patrón> <formato de fc-match> <resultado esperado (glob)>
  espera() {
    r=$(fc-match -f "$2" "$1" 2>/dev/null)
    echo "$1 → $r"
    case "$r" in $3) ;; *) echo "FALLA: se esperaba $3"; falla=1 ;; esac
  }
  # la otra paleta: la sans es la suya, con las fuentes que instala
  espera sans-serif '%{family[0]}' Inter

  jpg=$(file -b ${temaG.fondo.imagen})
  echo "fondo gruvbox-verde: $jpg"
  case "$jpg" in "JPEG image data"*) ;; *) echo "FALLA: el fondo de gruvbox-verde no es un JPEG"; falla=1 ;; esac

  # GTK3 con Gruvbox teal (gruvbox-verde): carga sin quejas, y su acento es el verde de la variante. La queja por
  # border-spacing (una propiedad de GTK4 en la hoja GTK3 del tema) es del tema tal cual, también en Gruvbox-Dark:
  # GTK3 saltea esa propiedad.
  GI_TYPELIB_PATH=${tipos} XDG_DATA_DIRS=${cg.home.path}/share GTK_THEME=${cg.gtk.theme.name} \
    xvfb-run -a ${pythonGtk}/bin/python3 ${pruebaGtk3} > gruvbox.txt 2> gtk3.err
  cat gruvbox.txt gtk3.err
  if grep -v "'border-spacing' is not a valid property name" gtk3.err | grep -q 'Gtk-\|parsing error'; then
    echo "FALLA: GTK3 se quejó de ${cg.gtk.theme.name}"; falla=1
  fi
  grep -q 'theme_selected_bg_color #${acentoGtkGruvbox}' ${cg.home.path}/share/themes/${cg.gtk.theme.name}/gtk-3.0/gtk.css \
    || { echo "FALLA: el acento GTK3 de ${cg.gtk.theme.name} no es #${acentoGtkGruvbox}"; falla=1; }

  # Las carpetas de Papirus-Dark (papirus-folders enlaza folder.svg a folder-<color>.svg, user-home.svg a
  # user-<color>-home.svg…): verdes con
  # gruvbox-verde (la prueba y maltalef en pirincho), azules (las de Papirus) para mw
  # carpetas <qué> <paquete de íconos> <color>
  carpetas() {
    for i in 48x48/places/folder.svg 48x48/places/user-home.svg 22x22/places/folder.svg; do
      r=$(readlink -f $2/share/icons/Papirus-Dark/$i)
      echo "$1: $i → ''${r##*/}"
      case "''${r##*/}" in *-$3.svg|*-$3-*.svg) ;; *) echo "FALLA: $1, $i no es $3"; falla=1 ;; esac
    done
  }
  carpetas gruvbox-verde ${cg.gtk.iconTheme.package} green
  carpetas "maltalef en pirincho" ${pirincho.maltalef.gtk.iconTheme.package} green
  carpetas "mw en pirincho" ${pirincho.mw.gtk.iconTheme.package} blue

  ${pkgs.python3}/bin/python3 ${contrasteSwaync} ${alfaTarjeta} ${opacidadBaja} \
    gruvbox-verde ${cuerpo} ${temaG.colores.superficie} || falla=1

  # La fila de energía del centro, en orden: suspender directo; cerrar la sesión, reiniciar y apagar después de
  # confirmar con la notificación
  # energia <n> <guion> <acción> <confirma: si|no>
  energia() {
    grep -qF "$3" $2 || { echo "FALLA: el botón $1 de energía no hace «$3»"; falla=1; }
    if grep -q '/bin/notify-send' $2 && grep -q -- '--action=si=' $2; then c=si; else c=no; fi
    [ $c = $4 ] || { echo "FALLA: el botón $1 de energía confirma: $c, no $4"; falla=1; }
  }
  ${lib.concatImapStrings (i: { a, confirma }: ''
    energia ${toString i} ${(lib.elemAt energia.actions (i - 1)).command} ${lib.escapeShellArg a} ${confirma}
  '') [
    { a = "systemctl suspend"; confirma = "no"; }
    { a = "hyprctl dispatch exit"; confirma = "si"; }
    { a = "systemctl reboot"; confirma = "si"; }
    { a = "systemctl poweroff"; confirma = "si"; }
  ]}

  # nvim con el colorscheme de la paleta: sus colores en la interfaz, la sintaxis y los diagnósticos
  nvim() {
    ${pkgs.neovim-unwrapped}/bin/nvim --clean --headless --cmd "set rtp^=$1" -c "luafile $2" -c 'qa!'
    cat $3.txt
    if grep '^fuga ' $3.txt; then echo "FALLA: nvim con $3 deja grupos con colores del esquema por omisión"; falla=1; fi
  }
  # gruvbox-verde: el fondo de foot (bg0 #282828) y la interfaz un escalón arriba, la sintaxis de gruvbox-dark-hard
  nvim ${temaG.nvim} ${pruebaNvim "gruvbox-verde"} gruvbox-verde
  ${with esperadoG.colores; let p = temaG.esquema.palette; in lib.concatMapStrings (l: ''
    grep -qx '${l}' gruvbox-verde.txt || { echo "FALLA: nvim con gruvbox-verde no da «${l}»"; falla=1; }
  '') [
    "nombre gruvbox-verde" "terminal1 ${esperadoG.terminal.Color1}" "errmsg "
    "Normal ${texto} ${esperadoG.terminal.Background}" "Visual - ${seleccion}" "PmenuSel ${sobreAcento} ${acento}"
    "StatusLine ${texto} ${campo}" "CursorLine - ${campo}" "Comment ${apagado} -"
    "DiagnosticError ${p.base08} -" "DiagnosticWarn ${p.base0A} -"
    "DiagnosticInfo ${foco} -" "@keyword ${p.base0E} -" "@string ${p.base0B} -"
  ]}

  # la paleta de qt5ct/qt6ct: los 22 roles en cada grupo, con el acento como Highlight (el 13)
  qt() {
    for g in active inactive disabled; do
      n=$(grep "^''${g}_colors=" $1 | tr , '\n' | grep -c '#ff[0-9a-f]\{6\}')
      [ "$n" = 22 ] || { echo "FALLA: ''${g}_colors de la paleta Qt $1 tiene $n colores, no 22"; falla=1; }
    done
    h=$(grep '^active_colors=' $1 | cut -d= -f2 | tr -d ' ' | cut -d, -f13)
    [ "$h" = "#ff$2" ] || { echo "FALLA: Highlight de la paleta Qt $1 es $h, no #ff$2"; falla=1; }
  }
  qt ${qtctG.color_scheme_path} ${esperadoG.colores.acento}

  # una app Qt 6 y una Qt 5 con el entorno de la sesión: cargan el plugin de qt6ct/qt5ct (con el mismo
  # QT_QPA_PLATFORMTHEME=qt5ct: el de qt6ct responde también a qt5ct) y les queda Fusion con la paleta
  # app <paleta> <versión de Qt> <plugin> <colores esperados: ventana, texto, vistas, selección, texto seleccionado>
  app() {
    sed "s/^/$1 Qt $2: /" qt-$1-$2.txt
    grep -q "/lib$3\.so\"* loaded library\|loaded library \"*[^ ]*/lib$3\.so" qt-$1-$2.err \
      || { echo "FALLA: $1, Qt $2 no carga lib$3.so"; falla=1; }
    for l in "estilo $3-style" "base fusion" "Window $4" "WindowText $5" "Base $6" "Highlight $7" "HighlightedText $8"; do
      grep -qix "$l" qt-$1-$2.txt || { echo "FALLA: $1, Qt $2 no da «$l»"; falla=1; }
    done
  }
  ${lib.concatMapStrings ({ nombre, conf, col }: lib.concatMapStrings ({ v, plugin }: ''
    ${pruebaQtCon nombre conf v}
    app ${nombre} ${v} ${plugin} ${with col; "${fondo} ${texto} ${fondoHondo} ${acento} ${sobreAcento}"}
  '') [ { v = "6"; plugin = "qt6ct"; } { v = "5"; plugin = "qt5ct"; } ]) [
    { nombre = "gruvbox-verde"; conf = cg; col = esperadoG.colores; }
  ]}

  # Firefox (el del lock) todavía tiene los dos encabezados del sidebar que oculta userChrome: si una versión nueva los
  # cambia, el encabezado vuelve a aparecer
  omni=${firefox.finalPackage}/lib/firefox/browser/omni.ja
  unzip -p $omni chrome/browser/content/browser/browser.xhtml > browser.xhtml 2>/dev/null || true
  unzip -p $omni chrome/browser/content/browser/webext-panels.xhtml > webext-panels.xhtml 2>/dev/null || true
  grep -q 'id="sidebar-header"' browser.xhtml || { echo "FALLA: firefox ya no tiene #sidebar-header"; falla=1; }
  grep -q 'id="webextpanels-window"' webext-panels.xhtml && grep -q 'sidebar-panel-header id="sidebar-panel-header"' webext-panels.xhtml \
    || { echo "FALLA: webext-panels.xhtml de firefox ya no tiene #webextpanels-window > #sidebar-panel-header"; falla=1; }
  # El botón del sidebar sigue siendo el widget sidebar-button que se introduce en la barra con sidebar.revamp,
  # mientras browser.toolbarbuttons.introduced.<id> no esté: si cambia el id o el mecanismo, el botón vuelve
  omniApp=${firefox.finalPackage}/lib/firefox/omni.ja
  unzip -p $omniApp moz-src/browser/components/customizableui/CustomizableWidgets.sys.mjs > widgets.mjs 2>/dev/null || true
  unzip -p $omniApp moz-src/browser/components/customizableui/CustomizableUI.sys.mjs > cui.mjs 2>/dev/null || true
  grep -A3 'id: "sidebar-button",' widgets.mjs | grep -q '_introducedByPref: "sidebar.revamp"' \
    || { echo "FALLA: firefox ya no tiene el widget sidebar-button introducido por sidebar.revamp"; falla=1; }
  grep -q '"browser.toolbarbuttons.introduced." + widget.id' cui.mjs \
    || { echo "FALLA: firefox ya no usa browser.toolbarbuttons.introduced.<id>"; falla=1; }
  # El margen izquierdo de #sidebar-box con hide-launcher lo sigue poniendo SidebarState por JS, en línea (si pasa a
  # una regla de CSS, ver que el !important de userChrome todavía le gane)
  unzip -p $omniApp moz-src/browser/components/sidebar/SidebarState.sys.mjs > estado.mjs 2>/dev/null || true
  grep -q 'sidebarBoxEl.style.paddingInlineStart' estado.mjs \
    || { echo "FALLA: firefox ya no pone por JS el padding-inline-start de #sidebar-box"; falla=1; }
  # El ancho del panel lo siguen poniendo en línea SidebarState y el divisor en #sidebar-box (el redondeo a múltiplos
  # de 4 se le aplica a su hijo #sidebar), y el margen de abajo de #sidebar-box sigue siendo var(--space-small) (si
  # cambia, ver que el panel todavía termine en un píxel entero a 1.25)
  grep -qF 'this.#panelEl.style.width = `''${value}px`' estado.mjs \
    || { echo "FALLA: firefox ya no pone en línea el ancho del panel del sidebar"; falla=1; }
  unzip -p $omni chrome/browser/skin/classic/browser/sidebar.css > sidebar.css 2>/dev/null || true
  sed -n '/^#sidebar-box {/,/^}/p' sidebar.css | grep -q 'padding-block-end: var(--space-small);' \
    || { echo "FALLA: el #sidebar-box de firefox ya no tiene padding-block-end: var(--space-small)"; falla=1; }
  sed -n '/^#sidebar {/,/^}/p' sidebar.css | grep -q 'flex: 1;' \
    || { echo "FALLA: el #sidebar de firefox ya no es flex: 1 dentro de #sidebar-box"; falla=1; }
  # Las esquinas redondeadas del panel siguen en #sidebar-box y en #sidebar (que userChrome pone en recto); si pasan a
  # otro elemento (un envoltorio del <browser>), la máscara vuelve
  grep -q '^  #sidebar-box #sidebar {' sidebar.css && grep -q 'border-start-end-radius: var(--sidebar-box-start-end-radius);' sidebar.css \
    || { echo "FALLA: el radio de las esquinas del panel ya no está en #sidebar-box #sidebar"; falla=1; }
  # La Browser Toolbox sigue pidiendo las dos preferencias que pone firefox.nix
  unzip -p $omni chrome/devtools/modules/devtools/client/framework/browser-toolbox/Launcher.sys.mjs > lanzador.mjs 2>/dev/null || true
  grep -q 'getBoolPref("devtools.chrome.enabled")' lanzador.mjs && grep -q 'getBoolPref("devtools.debugger.remote-enabled")' lanzador.mjs \
    || { echo "FALLA: la Browser Toolbox de firefox ya no depende de devtools.chrome.enabled y devtools.debugger.remote-enabled"; falla=1; }

  [ $falla = 0 ]
  echo "${temaG.esquema.slug}: ${toString (lib.attrValues temaG.esquema.palette)}" > $out
''

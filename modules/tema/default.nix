# El tema del escritorio, en una de las paletas de `tema.paletas` (`tema.paleta`):
# - «gruvbox-verde» (la de omisión, la única de acá): gruvbox-dark-hard de nix-colors con el acento verde
#   (gruvbox-verde.nix, con el mapeo);
# - otras que sume otro módulo en `tema.paletas.<nombre>`, con la misma forma.
#
# - `tema.esquema`: el esquema de nix-colors de la paleta (base16). Con enable, pasa a ser el colorScheme del usuario,
#   si nix-colors está importado.
# - `tema.colores`: los colores con nombre (fondo, superficie, campo, texto, acento, foco…), los mismos en todas las
#   paletas, para lo que necesita más que base16; `terminal`, la paleta de la terminal. Todos en hex sin `#`, como
#   nix-colors.
# - Las fuentes: `fuentes.interfaz` la de las herramientas del escritorio (barra, lanzador, notificaciones, bloqueo) y
#   `fuentes.sistema` la sans del usuario (fontconfig, GTK, Qt); `fuentes.cifras`, la de la hora del bloqueo. Con
#   gruvbox-verde, las de antes del tema: FiraCode Nerd Font en las herramientas y la sans sin tocar. Una paleta puede
#   traer sus fuentes (`fuentes.paquete`), que se instalan. La monoespaciada no se toca.
# - El fondo: `fondo.imagen`, el que ponen hyprpaper y hyprlock. Con gruvbox-verde, el que ponga el usuario.
# - `tema.aplicaciones`: GTK 3/4, Qt, cursor e íconos (se prende con el tema). Con gruvbox-verde, los de antes del
#   tema (Gruvbox, Papirus-Dark, capitaine-cursors), con las carpetas de Papirus en verde. Qt, con la paleta.
# - `tema.nvim`: un colorscheme de nvim con el nombre de la paleta (nvim.nix), para que la configuración de nvim lo
#   elija.
# Las herramientas del escritorio (barra, lanzador, terminal…) no se tocan acá: cada una lee estos valores.
{ config, lib, pkgs, options, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption optionalAttrs types literalExpression;
  cfg = config.tema;

  # La paleta elegida: esquema, colores, terminal, fuentes, fondo y aplicaciones, con la misma forma en todas.
  paleta = cfg.paletas.${cfg.paleta} or (throw
    "tema: no hay una paleta «${cfg.paleta}» en tema.paletas (hay: ${lib.concatStringsSep ", " (lib.attrNames cfg.paletas)})");
  ap = paleta.aplicaciones;

  # Qt (qt5ct y qt6ct, estilo Fusion) con la paleta: los 22 roles de QPalette en su orden (WindowText,
  # Button, Light, Midlight, Dark, Mid, Text, BrightText, ButtonText, Base, Window, Shadow, Highlight,
  # HighlightedText, Link, LinkVisited, AlternateBase, NoRole, ToolTipBase, ToolTipText, PlaceholderText, Accent).
  # Los papeles de una hoja GTK3: ventana en fondo, vistas en fondoHondo, campos y botones en campo, selección en el
  # acento con sobreAcento (el fondo en gruvbox-verde). qt5ct (Qt 5, 21 roles) lee los primeros y deja el último.
  paletaQt =
    let
      c = cfg.colores;
      inherit (c) apagado;
      activos = with c; [
        texto campo campoHover campo fondoHondo superficie texto sobreAcento texto fondoHondo fondo fondoHondo
        acento sobreAcento enlace enlaceHover fondo fondo superficie texto textoTenue acento
      ];
      inactivos = activos;
      deshabilitados = with c; [
        apagado campo campoHover campo fondoHondo superficie apagado sobreAcento apagado fondoHondo fondo fondoHondo
        superficie textoTenue apagado apagado fondo fondo superficie apagado apagado superficie
      ];
      linea = colores: lib.concatMapStringsSep ", " (x: "#ff${x}") colores;
    in
    pkgs.writeText "${cfg.paleta}.conf" ''
      [ColorScheme]
      active_colors=${linea activos}
      disabled_colors=${linea deshabilitados}
      inactive_colors=${linea inactivos}
    '';

  ajustesQtct = {
    Appearance = {
      style = "Fusion";
      custom_palette = true;
      color_scheme_path = "${paletaQt}";
      icon_theme = cfg.aplicaciones.iconos;
      standard_dialogs = "default";
    };
  } // optionalAttrs (cfg.fuentes.sistema != null) {
    Fonts.general = ''"${cfg.fuentes.sistema},${toString cfg.fuentes.tamano}"'';
  };

  soloLectura = description: default: defaultText: mkOption {
    inherit description default;
    defaultText = literalExpression defaultText;
    readOnly = true;
  };
in
{
  options.tema = {
    enable = mkEnableOption ''
      el tema del escritorio: el colorScheme de la paleta (nix-colors), sus fuentes, su fondo y las aplicaciones
    '';

    paleta = mkOption {
      type = types.str;
      default = "gruvbox-verde";
      description = ''
        La paleta del tema, una de `tema.paletas`: «gruvbox-verde», gruvbox-dark-hard con el acento verde #689d6a
        (gruvbox-verde.nix, con el mapeo de los colores con nombre), u otra que sume otro módulo. También elige las
        fuentes, el fondo y las aplicaciones por omisión.
      '';
    };

    paletas = mkOption {
      type = types.lazyAttrsOf types.raw;
      description = ''
        Las paletas que se pueden elegir, por nombre. Cada una es un attrset con:
        - `esquema`: el base16 con la forma de nix-colors (slug, name, variant, palette base00..base0F);
        - `colores`: los colores con nombre, en hex sin `#` (fondo, fondoHondo, superficie, campo, campoHover, texto,
          textoTenue, textoClaro, acento, sobreAcento, secundario, seleccion, enlace, enlaceHover, foco, alerta,
          aviso, ok, error, errorBorde, apagado, bordeInactivo);
        - `terminal`: Background, Foreground, Cursor, Color0..Color15;
        - `fuentes`: `interfaz`, y si hace falta `sistema` (null: no toca la sans), `cifras` (la de interfaz) y
          `paquete` (las fuentes que se instalan, o null);
        - `fondo`: la imagen por omisión (null: la pone el usuario);
        - `aplicaciones`: `gtk` y `gtk4` (`{ package; name; }`; gtk4 null: libadwaita con `css4` encima), `css4`,
          `iconos` y `cursor` (`{ package; name; }`) y `acento` (el de libadwaita en dconf).
        gruvbox-verde la pone este módulo.
      '';
    };

    esquemaGruvbox = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      defaultText = literalExpression "inputs.nix-colors.colorSchemes.gruvbox-dark-hard (lo pone el flake)";
      description = ''
        El esquema gruvbox-dark-hard de nix-colors, el base16 de la paleta gruvbox-verde. homeManagerModules.tema lo
        pone desde el input nix-colors del flake.
      '';
    };

    esquema = soloLectura ''
      El esquema de nix-colors de la paleta (slug, name, variant, palette base00..base0F): con gruvbox-verde,
      gruvbox-dark-hard tal cual.
    '' paleta.esquema "tema.paletas.<paleta>.esquema";

    colores = soloLectura ''
      Los colores con nombre de la paleta, en hex sin `#`: fondo, fondoHondo, superficie, campo, campoHover, texto,
      textoTenue, textoClaro, acento, sobreAcento, secundario, seleccion, enlace, enlaceHover, foco, alerta, aviso,
      ok, error, errorBorde, apagado, bordeInactivo.
    '' paleta.colores "tema.paletas.<paleta>.colores";

    terminal = soloLectura ''
      La paleta de la terminal (Background, Foreground, Cursor, Color0..Color15): con gruvbox-verde, la gruvbox dark
      de foot antes del tema.
    '' paleta.terminal "tema.paletas.<paleta>.terminal";

    nvim = soloLectura ''
      El colorscheme de nvim de la paleta (nvim.nix), con su nombre: un paquete con colors/<paleta>.lua
      (colors/gruvbox-verde.lua), para programs.neovim.plugins o para enlazar en ~/.config/nvim/colors. No se aplica
      solo: la configuración de nvim elige el colorscheme (`tema.paleta`).
    '' (import ./nvim.nix { inherit lib pkgs; tema = cfg; }) "<paleta>-nvim";

    fuentes = {
      paquete = soloLectura "Las fuentes que trae la paleta, que se instalan con el tema (null: ninguna)."
        (paleta.fuentes.paquete or null) "tema.paletas.<paleta>.fuentes.paquete or null";

      interfaz = mkOption {
        type = types.str;
        default = paleta.fuentes.interfaz;
        defaultText = literalExpression "tema.paletas.<paleta>.fuentes.interfaz";
        description = ''
          La familia de las herramientas del escritorio (barra, lanzador, notificaciones, bloqueo). Con gruvbox-verde,
          la que tenían antes del tema (master 844765d): FiraCode Nerd Font, que el módulo no instala.
        '';
      };

      sistema = mkOption {
        type = types.nullOr types.str;
        default = paleta.fuentes.sistema or null;
        defaultText = literalExpression "tema.paletas.<paleta>.fuentes.sistema or null";
        description = ''
          La sans del usuario: la de fontconfig y la de interfaz de GTK, Qt y dconf. null no la toca (como antes del
          tema: la de omisión del sistema y de GTK), que es lo de gruvbox-verde.
        '';
      };

      cifras = mkOption {
        type = types.str;
        default = paleta.fuentes.cifras or cfg.fuentes.interfaz;
        defaultText = literalExpression "tema.paletas.<paleta>.fuentes.cifras or fuentes.interfaz";
        description = "La familia de los campos con cifras (la hora del bloqueo). Con gruvbox-verde, la de interfaz.";
      };

      tamano = mkOption {
        type = types.ints.positive;
        default = 11;
        description = "El tamaño de la fuente de sistema en GTK, Qt y dconf.";
      };
    };

    aplicaciones = {
      enable = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = literalExpression "config.tema.enable";
        description = ''
          Las aplicaciones con la paleta: estilo oscuro en dconf, Qt 5/6 por qt5ct/qt6ct (Fusion) con la paleta, la
          fuente de sistema (si hay), y lo de la paleta (`tema.paletas.<paleta>.aplicaciones`): con gruvbox-verde, como
          antes del tema, Gruvbox-GTK-Theme oscuro en GTK3 y GTK4 (en su variante teal, la del acento verde), acento
          verde en dconf, Papirus-Dark con las carpetas verdes y capitaine-cursors.
        '';
      };

      iconos = mkOption {
        type = types.str;
        default = ap.iconos.name;
        defaultText = literalExpression "tema.paletas.<paleta>.aplicaciones.iconos.name";
        description = "El tema de íconos, del paquete de la paleta (con gruvbox-verde, Papirus-Dark).";
      };

      cursor = {
        nombre = mkOption {
          type = types.str;
          default = ap.cursor.name;
          defaultText = literalExpression "tema.paletas.<paleta>.aplicaciones.cursor.name";
          description = "El cursor, del paquete de la paleta (con gruvbox-verde, capitaine-cursors).";
        };

        tamano = mkOption {
          type = types.ints.positive;
          default = 24;
          description = "El tamaño del cursor.";
        };
      };
    };

    fondo.imagen = mkOption {
      type = types.path;
      default =
        if (paleta.fondo or null) != null then paleta.fondo
        else throw "tema: la paleta ${cfg.paleta} no trae fondo: poné tema.fondo.imagen";
      defaultText = literalExpression "tema.paletas.<paleta>.fondo (con gruvbox-verde, hay que ponerlo)";
      description = ''
        El fondo del escritorio y del bloqueo (hyprpaper, hyprlock), en un formato que lean (PNG o JPEG, no SVG). Con
        gruvbox-verde no tiene valor por omisión.
      '';
    };
  };

  config = mkMerge [
    {
      # gruvbox-verde: el esquema y el mapeo de gruvbox-verde.nix, las fuentes y las aplicaciones de antes del tema
      # (master 844765d): Gruvbox-GTK-Theme oscuro (también en GTK4), Papirus-Dark y capitaine-cursors. El verde, con
      # la variante «teal» del mismo tema y no con una hoja encima: su acento (#89b482, el aqua de gruvbox-material,
      # casi el secundario #8ec07c) sale del sass del tema, en GTK3, GTK4 y en los dibujos de casillas e
      # interruptores, que una hoja no alcanza. El #689d6a exacto pediría parchear el tema. Las carpetas de Papirus,
      # en su color «green» (#87b158, con el pliegue en #60924b): de los de papirus-folders, el más cercano al acento;
      # los otros verdes (teal, darkcyan) se van al azul.
      tema.paletas.gruvbox-verde = import ./gruvbox-verde.nix cfg.esquemaGruvbox // {
        fuentes.interfaz = "FiraCode Nerd Font";
        fondo = null;
        aplicaciones =
          let gruvbox = { package = pkgs.gruvbox-gtk-theme.override { colorVariants = [ "dark" ]; themeVariants = [ "teal" ]; }; name = "Gruvbox-Teal-Dark"; };
          in {
            gtk = gruvbox;
            gtk4 = gruvbox;
            css4 = "";
            iconos = { package = pkgs.papirus-icon-theme.override { color = "green"; }; name = "Papirus-Dark"; };
            cursor = { package = pkgs.capitaine-cursors; name = "capitaine-cursors"; };
            acento = "green";
          };
      };
    }

    (mkIf cfg.enable (mkMerge [
      # Las fuentes de la paleta, si trae
      (mkIf (cfg.fuentes.paquete != null) {
        home.packages = [ cfg.fuentes.paquete ];
        fonts.fontconfig.enable = true;
      })
      (mkIf (cfg.fuentes.sistema != null) {
        fonts.fontconfig = {
          enable = true;
          defaultFonts.sansSerif = [ cfg.fuentes.sistema ];
        };
      })
      # Gana sobre un `colorScheme = lib.mkDefault …` general (home/<usuario>/global.nix).
      (optionalAttrs (options ? colorScheme) {
        colorScheme = cfg.esquema;
      })

      (mkIf cfg.aplicaciones.enable {
        gtk = {
          enable = true;
          theme = ap.gtk;
          iconTheme = { inherit (ap.iconos) package; name = cfg.aplicaciones.iconos; };
          font = mkIf (cfg.fuentes.sistema != null) {
            package = cfg.fuentes.paquete;
            name = cfg.fuentes.sistema;
            size = cfg.fuentes.tamano;
          };
          colorScheme = "dark";
          # GTK4 ignora el tema por nombre: home-manager lo importa en su gtk.css (gruvbox-verde) o libadwaita toma la
          # hoja de la paleta (sus variables de color)
          gtk4 = {
            theme = ap.gtk4;
            extraCss = ap.css4;
          };
        };

        # Lo que leen el portal Settings (las aplicaciones con libadwaita, Electron) y GTK en Wayland
        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = ap.acento;
          gtk-theme = ap.gtk.name;
          icon-theme = cfg.aplicaciones.iconos;
          cursor-theme = cfg.aplicaciones.cursor.nombre;
          cursor-size = cfg.aplicaciones.cursor.tamano;
        } // optionalAttrs (cfg.fuentes.sistema != null) {
          font-name = "${cfg.fuentes.sistema} ${toString cfg.fuentes.tamano}";
        };

        home.pointerCursor = {
          enable = true;
          inherit (ap.cursor) package;
          name = cfg.aplicaciones.cursor.nombre;
          size = cfg.aplicaciones.cursor.tamano;
          gtk.enable = true;
        };

        # qtct exporta QT_QPA_PLATFORMTHEME=qt5ct (en las hm-session-vars, que llegan a la sesión por el login shell):
        # sirve también a Qt 6, porque el plugin de qt6ct responde a qt6ct y a qt5ct
        qt = {
          enable = true;
          platformTheme.name = "qtct";
          qt5ctSettings = ajustesQtct;
          qt6ctSettings = ajustesQtct;
        };
      })
    ]))
  ];
}

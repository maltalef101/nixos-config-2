{ pkgs, lib, inputs, config, ... }:
let
  tema = config.tema;

  # Con el tema (pirincho): la interfaz en los colores de la paleta (barra
  # y diálogos en la superficie, selección en el acento) y la fuente de
  # sistema (si la paleta la trae; con gruvbox-verde no hay, y queda la
  # de zathura, como antes); `i` (recolor) pinta las páginas con el fondo y el
  # texto de la paleta. Si no, los colores por omisión de zathura, como
  # siempre.
  colores = with tema.colores; let p = tema.esquema.palette; in lib.optionalAttrs (tema.fuentes.sistema != null) {
    font = "${tema.fuentes.sistema} ${toString (tema.fuentes.tamano - 1)}";
  } // {
    default-bg = "#${fondo}";
    default-fg = "#${texto}";
    statusbar-bg = "#${superficie}";
    statusbar-fg = "#${texto}";
    inputbar-bg = "#${campo}";
    inputbar-fg = "#${texto}";
    notification-bg = "#${superficie}";
    notification-fg = "#${texto}";
    notification-error-bg = "#${superficie}";
    notification-error-fg = "#${error}";
    notification-warning-bg = "#${superficie}";
    notification-warning-fg = "#${p.base0A}";
    completion-bg = "#${superficie}";
    completion-fg = "#${texto}";
    completion-group-bg = "#${fondoHondo}";
    completion-group-fg = "#${textoTenue}";
    completion-highlight-bg = "#${acento}";
    completion-highlight-fg = "#${sobreAcento}";
    index-bg = "#${fondo}";
    index-fg = "#${texto}";
    index-active-bg = "#${seleccion}";
    index-active-fg = "#${texto}";
    # resaltado de búsqueda: el acento (con la transparencia por omisión) y el
    # resultado activo en el amarillo
    highlight-color = "#${acento}";
    highlight-fg = "#${sobreAcento}";
    highlight-active-color = "#${p.base0A}";
    recolor-lightcolor = "#${fondo}";
    recolor-darkcolor = "#${texto}";
  };
in {
  programs.zathura = {
    enable = true;
    options = {
      statusbar-h-padding = 0;
      statusbar-v-padding = 0;
      page-padding = 1;
      selection-clipboard = "clipboard";
    } // lib.optionalAttrs tema.enable colores;

    mappings = {
      u = "scroll half-up";
      d = "scroll half-down";
      D = "toggle_page_mode";
      r = "reload";
      R = "rotate";
      K = "zoom in";
      J = "zoom out";
      i = "recolor";
      p = "print";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    "application/epub+zip" = [ "org.pwmt.zathura.desktop" ];
    "image/vnd.djvu" = [ "org.pwmt.zathura.desktop" ];
    "application/vnd.comicbook+zip" = [ "org.pwmt.zathura.desktop" ];
  };
}

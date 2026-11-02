# La paleta «gruvbox-verde» del tema (default.nix): gruvbox oscuro con el acento verde (aqua) de la estética de
# maltalef antes del tema (los bordes de Hyprland y la waybar de master 844765d). esquema → attrset con la forma de
# tema.paletas (esquema, colores, terminal), para que las herramientas no sepan qué paleta es.
#
# `esquema` es colorSchemes.gruvbox-dark-hard de nix-colors (el que usa home/<usuario>/global.nix): el base16 sale de
# ahí tal cual. Los colores con nombre y la terminal salen de la paleta de gruvbox (morhetz/gruvbox, con sus nombres:
# bg0_h, fg1, aqua…), que base16 no tiene entera (le faltan bg0 #282828, los colores neutros y los aqua):
#
#   fondo        bg0_h          1d2021  el fondo de la barra y de las ventanas
#   fondoHondo   bg_dim         141617  más hondo que el fondo (islas, sombras); gruvbox no lo tiene: es el bg_dim
#                                       de gruvbox-material dark hard
#   superficie   bg0            282828  barras, paneles, menús (el background-color-alt de la waybar de antes)
#   campo        bg1            3c3836  campos, botones
#   campoHover   bg2            504945
#   texto        fg1            ebdbb2  (foreground-color de la waybar de antes)
#   textoTenue   fg3            bdae93  el base04 del esquema
#   textoClaro   fg0            fbf1c7  (foreground-color-alt)
#   acento       aqua           689d6a  (primary; col.active_border de Hyprland)
#   sobreAcento  bg0_h          1d2021  texto sobre el acento: el del workspace activo de antes (~5:1; blanco da ~3:1)
#   secundario   bright aqua    8ec07c  (secondary)
#   foco         bright aqua    8ec07c
#   seleccion    bg2            504945  el base02 del esquema
#   enlace       bright blue    83a598  el base0D
#   enlaceHover  bright aqua    8ec07c
#   alerta       red            cc241d  (alert)
#   aviso        bright yellow  fabd2f  (warning; el base0A)
#   ok           bright green   b8bb26  el base0B
#   error        bright red     fb4934  texto de error, el base08
#   errorBorde   red            cc241d
#   apagado      gray           928374  texto apagado (lo vacío, lo atenuado); el base03 (665c54) no se lee
#   bordeInactivo bg0_h         1d2021  el borde de las ventanas sin foco (col.inactive_border de Hyprland)
#
# La terminal es la gruvbox dark (medium) que foot tenía antes, portada de alacritty: fondo bg0 (#282828, no el bg0_h
# del esquema), colores normales en los tonos oscuros de gruvbox y brillantes en los claros.
esquema:
let
  # morhetz/gruvbox (la parte oscura)
  g = {
    bg0_h = "1d2021"; bg0 = "282828"; bg1 = "3c3836"; bg2 = "504945";
    fg0 = "fbf1c7"; fg1 = "ebdbb2"; fg3 = "bdae93"; gray = "928374";
    red = "cc241d"; green = "98971a"; yellow = "d79921"; blue = "458588"; purple = "b16286"; aqua = "689d6a";
    bright_red = "fb4934"; bright_green = "b8bb26"; bright_yellow = "fabd2f"; bright_blue = "83a598";
    bright_purple = "d3869b"; bright_aqua = "8ec07c";
    # gruvbox-material, dark hard
    bg_dim = "141617";
  };
in
{
  # Sólo el esquema necesita nix-colors: los colores con nombre y la terminal se leen sin él (la pantalla de arranque
  # de pirincho pasa null).
  esquema =
    if esquema == null
    then throw "tema: la paleta gruvbox-verde necesita tema.esquemaGruvbox (colorSchemes.gruvbox-dark-hard de nix-colors; el flake lo pone)"
    else esquema;

  colores = with g; {
    fondo = bg0_h;
    fondoHondo = bg_dim;
    superficie = bg0;
    campo = bg1;
    campoHover = bg2;
    texto = fg1;
    textoTenue = fg3;
    textoClaro = fg0;
    acento = aqua;
    sobreAcento = bg0_h;
    secundario = bright_aqua;
    foco = bright_aqua;
    seleccion = bg2;
    enlace = bright_blue;
    enlaceHover = bright_aqua;
    alerta = red;
    aviso = bright_yellow;
    ok = bright_green;
    error = bright_red;
    errorBorde = red;
    apagado = gray;
    bordeInactivo = bg0_h;
  };

  terminal = with g; {
    Background = bg0; Foreground = fg1; Cursor = fg1;
    Color0 = bg0; Color1 = red; Color2 = green; Color3 = yellow;
    Color4 = blue; Color5 = purple; Color6 = aqua; Color7 = fg1;
    Color8 = gray; Color9 = bright_red; Color10 = bright_green; Color11 = bright_yellow;
    Color12 = bright_blue; Color13 = bright_purple; Color14 = bright_aqua; Color15 = fg0;
  };
}

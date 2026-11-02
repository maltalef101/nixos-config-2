# El colorscheme de nvim de la paleta del tema (default.nix), con su nombre («gruvbox-verde», u otra de tema.paletas):
# un paquete con colors/<paleta>.lua, que sirve de plugin (programs.neovim.plugins) o se enlaza en
# ~/.config/nvim/colors.
#
# Es base16 con los papeles de los colores con nombre, sin plugins: la sintaxis sale del esquema (si sus acentos son
# los de la terminal, nvim y foot muestran los mismos colores), y la interfaz de los colores con nombre, como una hoja
# GTK3: barras y menús en la superficie, selección visual en `seleccion`, lo elegido del menú en el acento con
# sobreAcento. Cubre todos los grupos que el colorscheme por omisión de nvim pinta (si no, tras
# `hi clear` quedarían sus grises), los de treesitter y LSP que lo merecen, y la paleta de :terminal (la de foot).
#
# El fondo de nvim es el de la terminal, para que no quede un recuadro dentro del margen de foot: los escalones de
# fondo de la paleta (fondoHondo, fondo, superficie, campo, campoHover) se corren hasta que fondo sea el de la
# terminal. Si la paleta ya lo tiene así, no se corren; en gruvbox-verde la terminal es bg0 (#282828, la gruvbox
# medium de foot), la superficie: todo sube uno (fondoHondo bg0_h, fondo bg0, superficie bg1, campo bg2) y campoHover es bg3 (#665c54),
# que la paleta no tiene, mezclado.
{ lib, pkgs, tema }:
let
  inherit (lib) toLower toHexString fromHexString fixedWidthString substring;
  p = tema.esquema.palette;
  h = x: "#${x}";

  escalones = [ "fondoHondo" "fondo" "superficie" "campo" "campoHover" ];
  colorEscalon = map (n: tema.colores.${n}) escalones;
  corrimiento = lib.lists.findFirstIndex (x: x == tema.terminal.Background)
    (throw "tema: el fondo de la terminal (${tema.terminal.Background}) no es un escalón de fondo de la paleta")
    colorEscalon - 1;
  escalon = i:
    if i + corrimiento < lib.length escalones then lib.elemAt colorEscalon (i + corrimiento)
    else mezcla tema.colores.texto tema.colores.campoHover 14;
  c = tema.colores // lib.listToAttrs (lib.imap0 (i: n: { name = n; value = escalon i; }) escalones);
  nombre = tema.paleta;

  # `a` sobre `b` al t por ciento, para los fondos que la paleta no tiene (los de diff)
  mezcla = a: b: t:
    let
      canal = x: i: fromHexString (substring i 2 x);
      uno = i: fixedWidthString 2 "0" (toLower (toHexString ((canal a i * t + canal b i * (100 - t) + 50) / 100)));
    in
    "${uno 0}${uno 2}${uno 4}";

  grupos = {
    # La interfaz
    Normal = { fg = h c.texto; bg = h c.fondo; };
    NormalNC = { };
    NormalFloat = { fg = h c.texto; bg = h c.superficie; };
    FloatBorder = { fg = h c.campoHover; bg = h c.superficie; };
    FloatTitle = { fg = h c.enlace; bg = h c.superficie; bold = true; };
    FloatShadow = { bg = h c.fondoHondo; blend = 80; };
    FloatShadowThrough = { bg = h c.fondoHondo; blend = 100; };
    Cursor = { fg = h c.fondo; bg = h tema.terminal.Cursor; };
    lCursor = { link = "Cursor"; };
    TermCursor = { reverse = true; };
    CursorLine = { bg = h c.superficie; };
    CursorColumn = { bg = h c.superficie; };
    ColorColumn = { bg = h c.superficie; };
    LineNr = { fg = h c.apagado; };
    CursorLineNr = { fg = h c.enlace; bg = h c.superficie; bold = true; };
    SignColumn = { };
    Folded = { fg = h c.textoTenue; bg = h c.superficie; };
    FoldColumn = { fg = h c.apagado; };
    NonText = { fg = h c.campoHover; };
    Conceal = { fg = h c.apagado; };
    WinSeparator = { fg = h c.campo; };
    Directory = { fg = h p.base0D; };
    Title = { fg = h p.base0D; bold = true; };
    Visual = { bg = h c.seleccion; };
    QuickFixLine = { bg = h c.seleccion; bold = true; };
    Search = { fg = h c.fondo; bg = h p.base0A; };
    CurSearch = { fg = h c.fondo; bg = h p.base09; bold = true; };
    MatchParen = { fg = h p.base0A; bg = h c.campo; bold = true; };

    # Barra de estado, pestañas (showtabline = 2) y winbar
    StatusLine = { fg = h c.texto; bg = h c.superficie; };
    StatusLineNC = { fg = h c.textoTenue; bg = h c.fondoHondo; };
    TabLine = { fg = h c.textoTenue; bg = h c.superficie; };
    TabLineFill = { bg = h c.fondoHondo; };
    TabLineSel = { fg = h c.sobreAcento; bg = h c.acento; bold = true; };
    WinBar = { fg = h c.texto; bold = true; };
    WinBarNC = { fg = h c.textoTenue; };

    # El menú de completado
    Pmenu = { fg = h c.texto; bg = h c.superficie; };
    PmenuSel = { fg = h c.sobreAcento; bg = h c.acento; bold = true; };
    PmenuSbar = { bg = h c.campo; };
    PmenuThumb = { bg = h c.campoHover; };
    PmenuMatch = { fg = h c.enlace; bold = true; };
    PmenuMatchSel = { fg = h c.sobreAcento; bg = h c.acento; bold = true; };
    PmenuKind = { fg = h p.base0C; bg = h c.superficie; };
    PmenuExtra = { fg = h c.textoTenue; bg = h c.superficie; };
    ComplMatchIns = { };

    # Mensajes
    MsgArea = { };
    StdoutMsg = { };
    ModeMsg = { fg = h p.base0B; bold = true; };
    MoreMsg = { fg = h p.base0B; };
    Question = { fg = h p.base0B; };
    OkMsg = { fg = h p.base0B; };
    WarningMsg = { fg = h p.base0A; };
    ErrorMsg = { fg = h c.error; bold = true; };

    # Sintaxis (base16, con los identificadores en el texto: leen mejor que en el rojo de base16)
    Comment = { fg = h c.apagado; italic = true; };
    Constant = { fg = h p.base09; };
    String = { fg = h p.base0B; };
    Character = { fg = h p.base0B; };
    Identifier = { fg = h c.texto; };
    Function = { fg = h p.base0D; };
    Statement = { fg = h p.base0E; };
    Operator = { fg = h c.textoTenue; };
    PreProc = { fg = h p.base0C; };
    Type = { fg = h p.base0A; };
    Special = { fg = h p.base0C; };
    Delimiter = { fg = h c.textoTenue; };
    Underlined = { fg = h c.enlace; underline = true; };
    Todo = { fg = h c.fondo; bg = h p.base0A; bold = true; };
    Error = { fg = h c.sobreAcento; bg = h c.errorBorde; };
    "@variable" = { fg = h c.texto; };
    "@variable.member" = { link = "Identifier"; };
    "@constructor" = { link = "Type"; };
    "@tag" = { fg = h p.base0D; };
    "@tag.attribute" = { fg = h p.base0A; };
    "@tag.delimiter" = { link = "Delimiter"; };
    "@markup.heading.1.delimiter.vimdoc" = { fg = h c.fondo; bg = h c.fondo; sp = h c.texto; underdouble = true; nocombine = true; };
    "@markup.heading.2.delimiter.vimdoc" = { fg = h c.fondo; bg = h c.fondo; sp = h c.texto; underline = true; nocombine = true; };
    "@markup.raw" = { fg = h p.base0C; };
    "@markup.list" = { fg = h p.base0E; };
    "@markup.quote" = { fg = h c.textoTenue; italic = true; };

    # Diagnósticos: error en el rojo de la terminal, aviso en el amarillo, info en el color del foco, pista en el
    # cian; subrayados ondulados del mismo color
    DiagnosticError = { fg = h p.base08; };
    DiagnosticWarn = { fg = h p.base0A; };
    DiagnosticInfo = { fg = h c.foco; };
    DiagnosticHint = { fg = h p.base0C; };
    DiagnosticOk = { fg = h p.base0B; };
    DiagnosticUnderlineError = { sp = h p.base08; undercurl = true; };
    DiagnosticUnderlineWarn = { sp = h p.base0A; undercurl = true; };
    DiagnosticUnderlineInfo = { sp = h c.foco; undercurl = true; };
    DiagnosticUnderlineHint = { sp = h p.base0C; undercurl = true; };
    DiagnosticUnderlineOk = { sp = h p.base0B; undercurl = true; };
    DiagnosticDeprecated = { sp = h c.apagado; strikethrough = true; };
    DiagnosticUnnecessary = { fg = h c.apagado; };
    LspInlayHint = { fg = h c.apagado; italic = true; };
    LspReferenceText = { bg = h c.campo; };

    # Ortografía
    SpellBad = { sp = h p.base08; undercurl = true; };
    SpellCap = { sp = h p.base0D; undercurl = true; };
    SpellLocal = { sp = h p.base0C; undercurl = true; };
    SpellRare = { sp = h p.base0E; undercurl = true; };

    # Diff: fondos del color mezclado con el fondo; Added/Changed/Removed, los signos
    DiffAdd = { bg = h (mezcla p.base0B c.fondo 20); };
    DiffChange = { bg = h (mezcla p.base0D c.fondo 15); };
    DiffText = { bg = h (mezcla p.base0D c.fondo 35); };
    DiffDelete = { fg = h p.base08; bg = h (mezcla p.base08 c.fondo 20); };
    Added = { fg = h p.base0B; };
    Changed = { fg = h p.base0A; };
    Removed = { fg = h p.base08; };
  };

  terminal = map (i: h tema.terminal."Color${toString i}") (lib.range 0 15);
in
pkgs.writeTextFile {
  name = "${nombre}-nvim";
  destination = "/colors/${nombre}.lua";
  text = ''
  -- ${nombre}: generado por tema (modules/tema/nvim.nix) desde la paleta ${nombre}. No editar.
  vim.cmd.highlight('clear')
  if vim.g.syntax_on then vim.cmd.syntax('reset') end
  vim.o.background = 'dark'
  vim.g.colors_name = '${nombre}'

  for nombre, grupo in pairs(${lib.generators.toLua { } grupos}) do
    vim.api.nvim_set_hl(0, nombre, grupo)
  end

  -- :terminal con la paleta de la terminal, como foot
  for i, color in ipairs(${lib.generators.toLua { } terminal}) do
    vim.g['terminal_color_' .. (i - 1)] = color
  end
'';
}

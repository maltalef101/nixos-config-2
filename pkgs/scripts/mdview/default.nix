# mdview: vista previa de un .md en una ventana propia (WebKitGTK) con el CSS
# de GitHub en modo oscuro (css/GithubDark.css, github-markdown-css),
# re-renderizada sola al guardar. pandoc hace markdown (gfm) -> HTML y mermaid
# dibuja los bloques ```mermaid en el propio WebKit.
{ lib, stdenv, fetchurl, python3, gobject-introspection, wrapGAppsHook3, gtk3, webkitgtk_4_1, pandoc }:
let
  py = python3.withPackages (ps: [ ps.pygobject3 ]);
  # bundle IIFE de mermaid para los bloques ```mermaid; corre dentro del WebKit
  mermaid = fetchurl {
    url = "https://cdn.jsdelivr.net/npm/mermaid@12.1.0/dist/mermaid.min.js";
    hash = "sha256-ZISvwyhyo6oWysmna6GBah7UzIcKZZPMLhd1d1D1GLI=";
  };
in
stdenv.mkDerivation {
  pname = "mdview";
  version = "0.1";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [ ./mdview.py ./mdview.desktop ./css ];
  };
  nativeBuildInputs = [ py wrapGAppsHook3 gobject-introspection ];
  buildInputs = [ gtk3 webkitgtk_4_1 ];
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin $out/share/mdview $out/share/applications
    install -m755 mdview.py $out/bin/mdview
    # shebang explícito al python con pygobject (patchShebangs agarraría otro python3 del PATH)
    sed -i "1s|.*|#!${py}/bin/python3|" $out/bin/mdview
    cp -r css $out/share/mdview/css
    install -m644 ${mermaid} $out/share/mdview/mermaid.min.js
    # entrada oculta del menú, solo para "abrir con" desde el gestor de archivos
    install -m644 mdview.desktop $out/share/applications/mdview.desktop
  '';
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ pandoc ]}
      --set MDVIEW_CSS_DIR $out/share/mdview/css
      --set MDVIEW_MERMAID $out/share/mdview/mermaid.min.js
      # Sin composición acelerada: con ella el scroll del touchpad deja la capa
      # del documento en posiciones fraccionarias y el texto se ve borroso en
      # algunos tramos (pasa igual en otras apps WebKitGTK). Sin composición la
      # posición de scroll es entera y el documento se pinta directo. set-default
      # deja probar el otro modo con WEBKIT_DISABLE_COMPOSITING_MODE=0 mdview.
      --set-default WEBKIT_DISABLE_COMPOSITING_MODE 1
    )
  '';
  meta = with lib; {
    description = "Vista previa de markdown estilo GitHub oscuro, con recarga al guardar";
    mainProgram = "mdview";
    platforms = platforms.linux;
  };
}

# El CSS del tema para Firefox: lo usan el perfil de firefox.nix y el
# Firefox de prueba (pkgs/firefox-prueba). `tema` es config.tema de
# home-manager.
tema: {
  # Con el tema (pirincho), el cromo toma los colores del GTK del tema, que
  # ya es el de la paleta (fondo, texto, menús, campos, el
  # acento en la selección y los enlaces): el tema del sistema
  # (default-theme). La barra sale un poco más clara que el fondo del
  # GTK: es la mezcla de firefox (-moz-dialog con 15 % de blanco). Lo único que
  # el GTK no resuelve es el foco: el borde de la barra de direcciones
  # enfocada sale casi del color del fondo (#252a28 sobre #1d2021 con
  # gruvbox-verde), así que va el foco de la paleta. Antes iban acá más
  # variables sobre el compacto oscuro; en Firefox 158 la mayoría cambió de
  # nombre (--toolbar-bgcolor, --arrowpanel-*, --urlbarView-*…) y ya no hacían
  # nada. La fuente de la interfaz también es la de GTK, y la sans de las
  # páginas, la de fontconfig.
  cromo = ''

		/* tema: ${tema.paleta} */
		:root {
			--focus-outline-color: #${tema.colores.foco} !important;
		}
	  '';

  # La página nueva y el inicio en el fondo de la paleta, en vez del gris de
  # firefox.
  contenido = with tema.colores; ''
		/* tema: ${tema.paleta} */
		@-moz-document url("about:newtab"), url("about:home"), url("about:privatebrowsing") {
			:root {
				--newtab-background-color: #${fondo} !important;
				--newtab-background-color-secondary: #${superficie} !important;
				--newtab-text-primary-color: #${texto} !important;
				--in-content-page-background: #${fondo} !important;
			}
			body {
				background-color: #${fondo} !important;
			}
		}
	  '';
}

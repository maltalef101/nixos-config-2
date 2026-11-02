{ pkgs, lib, inputs, config, ... }:
let
  addons = inputs.firefox-addons.packages.${pkgs.system};
  tema = config.tema;

  # El cromo y la página nueva con los colores del tema (ver
  # firefox-tema.nix; también los usa el Firefox de prueba, pkgs/firefox-prueba)
  cssTema = import ./firefox-tema.nix tema;
  cromoTema = cssTema.cromo;
  contenidoTema = cssTema.contenido;
in {
  programs.firefox = {
    enable = true;

    configPath = ".mozilla/firefox";

    profiles.maltalef = {
      bookmarks = { };
      extensions.packages = with addons; [ ublock-origin vimium darkreader browserpass ];
	  search.default = "ddg";
	  search.force = true;
	  
      settings = {
		"browser.aboutConfig.showWarning" = false;
		"browser.compactmode.show" = true;
		"browser.uidensity" = 1;
		"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.disableResetPrompt" = true;
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
		"browser.toolbars.bookmarks.visibility" = "never";
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.uiCustomization.state" = ''
          {"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["ublock0_raymondhill_net-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","addon_darkreader_org-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","customizableui-special-spring1","urlbar-container","customizableui-special-spring2","save-to-pocket-button","downloads-button","fxa-toolbar-menu-button","_3c078156-979c-498b-8990-85f7987dd929_-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","addon_darkreader_org-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","unified-extensions-area"],"currentVersion":19,"newElementCount":2}'';
		# Con el tema, el tema del sistema, que en Linux toma los colores del
		# GTK (el del tema); sin el tema, el compacto oscuro. Vale para un
		# perfil nuevo: en uno existente, firefox decide el tema activo por
		# extensions.json y no mira esta preferencia, así que se activa una vez
		# a mano (about:addons → Temas → «System theme — auto»).
		"extensions.activeThemeID" =
		  if tema.enable then "default-theme@mozilla.org" else "firefox-compact-dark@mozilla.org";
		# El sidebar rediseñado sin la columna de íconos (sidebar-main) ni las
		# pestañas verticales: sólo el panel abierto (Sidebery), que se abre y
		# se cierra con su atajo
		"sidebar.visibility" = "hide-launcher";
		"sidebar.verticalTabs" = false;
		# Sin el botón del sidebar al principio de la barra: firefox lo agrega
		# una vez (con sidebar.revamp), mientras esta preferencia no esté, y
		# uiCustomization.state ya no lo tiene. Queda en la paleta de
		# personalizar.
		"browser.toolbarbuttons.introduced.sidebar-button" = true;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignon" = false;
		"browser.tabs.unloadOnLowMemory" = true;
		"browser.low_commit_space_threshold_percent" = 100;
		"browser.tabs.min_inactive_duration_before_unload" = 3600000;
		# -1.0: seguir la escala del compositor (un valor fijo la ignora). Es
		# una preferencia de cadena: como número, firefox la descarta
		"layout.css.devPixelsPerPx" = "-1.0";
		# La Browser Toolbox (Ctrl+Alt+Shift+I), para inspeccionar el cromo
		# (el sidebar). Al abrirla, firefox escucha en un puerto TCP de
		# localhost, y prompt-connection (true por omisión) pregunta antes de
		# aceptar la conexión: queda así, porque en pirincho hay otro usuario
		# que llega al mismo localhost, y sin la pregunta un proceso suyo
		# podría conectarse mientras la toolbox está abierta, con los permisos
		# del cromo
		"devtools.chrome.enabled" = true;
		"devtools.debugger.remote-enabled" = true;
      };

	  # El encabezado del sidebar (título, desplegable y cruz): #sidebar-header
	  # es el de antes del rediseño (sidebar.revamp, encendido por omisión en
	  # Firefox 158); con el rediseño, cada panel trae el suyo, y el de las extensiones
	  # (Sidebery) es el sidebar-panel-header de webext-panels.xhtml, otro
	  # documento de chrome, al que también llega userChrome.
	  #
	  # #sidebar-box sin el margen izquierdo: con el panel abierto y sin la
	  # columna de íconos (hide-launcher), firefox le pone por JS
	  # padding-inline-start: var(--space-small) (SidebarState.sys.mjs), una
	  # franja de 7,33 px CSS entre el borde de la ventana y Sidebery. A escala
	  # 1.25 son 9,17 px de pantalla: el panel queda corrido una fracción de
	  # píxel, que WebRender puede reescalar para encajarlo en la grilla (la
	  # hipótesis más fuerte del Sidebery borroso; en una VM no se reprodujo).
	  # El !important de userChrome le gana al estilo en línea.
	  #
	  # Con eso solo, Sidebery seguía borroso en el eDP a 1.25, y las páginas
	  # nítidas: falta que el panel también termine en un
	  # píxel entero. WebRender encaja cada rectángulo en la grilla de
	  # pantalla borde por borde, así que uno de extensión fraccionaria sale un
	  # píxel más ancho o más alto según dónde caiga; si la superficie se
	  # rasterizó con el otro redondeo, la estira un píxel y la remuestrea
	  # entera (el mecanismo del bug 2070683 de Mozilla, cuyo arreglo en
	  # Firefox 158 cubre sólo imágenes). Un ancho en px CSS enteros cae en la
	  # grilla a 1.25 sólo si es múltiplo de 4 (uno de 323 da 403,75), y
	  # abajo #sidebar-box tiene padding-block-end: var(--space-small), 0.5rem
	  # = 7,33 px con la letra de la interfaz (9,17 de pantalla). Así que
	  # #sidebar, el <browser> del panel, va con el ancho redondeado para abajo
	  # a múltiplos de 4 px (el resto, menos de 4 px, queda como el fondo de
	  # la barra, junto al divisor, que sigue arrastrando el ancho de a 1 px),
	  # y el margen de abajo, en 8 px (10 de pantalla). Arriba el panel ya cae
	  # entero: la barra mide 36,8 px CSS, 46 de pantalla.
	  #
	  # Con eso también siguió borroso, así que #sidebar va
	  # sin el borde redondeado, la sombra ni el contorno, con los que
	  # WebRender recorta el panel remoto con una máscara (el clip con
	  # esquinas redondeadas lo rasteriza aparte y lo compone con
	  # remuestreo). Con browser.nova.enabled (encendido en Firefox 158),
	  # sidebar.css le pone a #sidebar border-radius: 0 y sin sombra ni
	  # contorno, pero la regla «#sidebar-box #sidebar», de dos ids, le
	  # devuelve la esquina de arriba del lado del contenido (12 px). Sin
	  # nova, son el radio, la sombra y el contorno de 0,5 px del
	  # rediseño. #sidebar-box, que dibuja el borde de 1 px de pantalla
	  # hacia el contenido, también va con la esquina en recto: el panel
	  # cuadrado se le saldría por la curva.
	  userChrome = ''
		#TabsToolbar {
			visibility: collapse !important;
			margin-bottom: 21px !important;
		}

		#sidebar-header,
		#webextpanels-window > #sidebar-panel-header {
			display: none !important;
		}

		#sidebar-box {
			padding-inline-start: 0 !important;
			padding-block-end: 8px !important;
			border-radius: 0 !important;
		}

		#sidebar {
			max-width: round(down, 100%, 4px) !important;
			border-radius: 0 !important;
			box-shadow: none !important;
			outline: none !important;
		}
	  '' + lib.optionalString tema.enable cromoTema;

	  userContent = lib.optionalString tema.enable contenidoTema;
    };
  };

  # host de native messaging para browserpass-ce; el path del store no sale
  # de PASSWORD_STORE_DIR sino de la config de la extensión (una vez, en su UI)
  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}

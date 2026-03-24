{
  inputs,
  outputs,
  lib,
  ...
}:
let
  f_addons = inputs.firefox-addons.packages.${pkgs.system};
in
{
  imports = [
    ./global.nix
    #./features/desktop/leftwm
    ../features/desktop/hyprland
    ../features/desktop/common/optional/piper.nix
    ../features/desktop/common/optional/network.nix
    ../features/emacs
    ../features/games
    ../features/tex
  ];

  wayland.windowManager.hyprland = {
    settings = {
      device = [
        {
          name = "2.4g-mouse";
          sensitivity = "-0.1";
          accel_profile = "flat";
        }
        {
          name = "genius-wireless-device-1";
          accel_profile = "flat";
          sensitivity = -0.36;
        }
        {
          name = "tpps/2-elan-trackpoint";
          accel_profile = "flat";
        }
      ];

      monitor = [
        "eDP-1, 1920x1080, 0x0, 1"
        "HDMI-A-1, 1920x1080@100, 0x-1080, 1"
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "mw";
    userEmail = "mw@example.com";
  };

  programs.firefox = {
    enable = true;
    profiles.mw = {
      bookmarks = { };
      extensions.packages = with addons; [
        ublock-origin
        vimium
        darkreader
      ];
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
        "browser.uiCustomization.state" =
          ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["ublock0_raymondhill_net-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","addon_darkreader_org-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","customizableui-special-spring1","urlbar-container","customizableui-special-spring2","save-to-pocket-button","downloads-button","fxa-toolbar-menu-button","_3c078156-979c-498b-8990-85f7987dd929_-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","addon_darkreader_org-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","unified-extensions-area"],"currentVersion":19,"newElementCount":2}'';
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignon" = false;
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.low_commit_space_threshold_percent" = 100;
        "browser.tabs.min_inactive_duration_before_unload" = 3600000;
        "layout.css.devPixelsPerPx" = 0.95;
      };

      userChrome = ''
        		#TabsToolbar {
        			visibility: collapse !important;
        			margin-bottom: 21px !important;
        		}

        		#sidebar-header {
        			display: none !important;
        		}
        	  '';
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };

  programs.alacritty.enable = true;
  xdg.configFile."alacritty/alacritty.toml" = { source = ./alacritty.toml; };
}

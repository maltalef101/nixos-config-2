{ pkgs, lib, inputs, ... }: {
  programs.zathura = {
    enable = true;
    options = {
      statusbar-h-padding = 0;
      statusbar-v-padding = 0;
      page-padding = 1;
      selection-clipboard = "clipboard";
    };

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
    "text/html" = [ "zathura.desktop" ];
    "text/xml" = [ "zathura.desktop" ];
    "x-scheme-handler/http" = [ "zathura.desktop" ];
    "x-scheme-handler/https" = [ "zathura.desktop" ];
  };
}

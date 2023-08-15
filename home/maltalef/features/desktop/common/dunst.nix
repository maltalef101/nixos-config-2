{ pkgs, ... }: {
  home.packages = with pkgs; [ dunst ];

  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 350;
        height = 300;
        origin = "top-right";
        offset = "10x30";
        scale = 0;
        notification_limit = 15;
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        indicate_hidden = "yes";
        transparency = 0;
        separator_height = 2;
        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 12;
        frame_width = 0;
        frame_color = "#aaaaaa";
        separator_color = "auto";
        sort = "yes";
        idle_threshold = "1200";
        font = "Deja Vu Sans Mono 9.4";
        line_height = 1;
        markup = "full";
        format = ''
          <b>%s</b>
          %b'';
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = "75";
        ellipsize = "end";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";
        icon_position = "off";
        sticky_history = "yes";
        history_length = 20;
        dmenu = "/usr/bin/rofi -dmenu -p dunst:";
        browser = "/usr/bin/xdg-open";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 2;
        ignore_dbusclose = false;
        mouse_left_click = "close_current";
        mouse_middle_click = "close_all";
        mouse_right_click = "do_action";
      };

      urgency_low = {
        background = "#282828";
        foreground = "#fbf1c7";
        frame_color = "#928374";
        timeout = 4;
      };

      urgency_normal = {
        background = "#689d6a";
        foreground = "#fbf1c7";
        frame_color = "#83a598";
        timeout = 4;
      };

      urgency_critical = {
        background = "#cc241d";
        foreground = "#fbf1c7";
        frame_color = "#fb4934";
        timeout = 4;
      };
    };
  };
}

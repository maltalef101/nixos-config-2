{ pkgs, lib, config, ... }: {
  programs.superfile = {
    enable = true;
	settings = {
		theme = "gruvbox-dark-hard";
		editor = "nvim";
		dir_editor = "nautilus";
		auto_check_update = false;
		cd_on_quit = false;
		default_open_file_preview = true;
		show_image_preview = true;
		show_panel_footer_info = true;
		default_directory = ".";
		file_size_use_si = false;
		default_sort_type = 0;
		sort_order_reversed = false;
		case_sensitive_sort = false;
		shell_close_on_success = false;
		page_scroll_size = 0;
		debug = false;
		ignore_missing_fields = false;
		file_panel_extra_columns = 0;
		file_panel_name_percent = 50;
		code_previewer = "";
		nerdfont = true;
		show_select_icons = true;
		transparent_background = false;
		file_preview_width = 0;
		enable_file_preview_border = true;
		sidebar_width = 20;
		sidebar_sections = [ "home" "pinned" "disks" ];
		border_top = "─";
		border_bottom = "─";
		border_left = "│";
		border_right = "│";
		border_top_left = "╭";
		border_top_right = "╮";
		border_bottom_left = "╰";
		border_bottom_right = "╯";
		border_middle_left = "├";
		border_middle_right = "┤";
		metadata = false;
		enable_md5_checksum = false;
		zoxide_support = false;
	};
  };

  xdg.configFile."superfile/theme/gruvbox-dark-hard.toml".source = ./gruvbox-dark-hard.toml;

  # integración xdg solo en hosts desktop (los únicos que habilitan mimeApps);
  # en un host headless esto no genera nada
  #
  # foot standalone con app-id propio, no footclient: las ventanas del server
  # comparten PID y el swallow de hyprland no sabría cuál tragar; el app-id
  # además scopea el swallow_regex a esta terminal y no a cualquier foot
  xdg.desktopEntries = lib.mkIf config.xdg.mimeApps.enable {
	superfile = {
	  name = "superfile";
	  exec = "foot --app-id=superfile superfile %f";
	  terminal = false;
	  mimeType = [ "inode/directory" ];
	  categories = [ "System" "FileManager" ];
	};
  };

  xdg.mimeApps.defaultApplications = lib.mkIf config.xdg.mimeApps.enable {
	"inode/directory" = [ "superfile.desktop" ];
  };
}

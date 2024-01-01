{ pkgs, config, ... }: {
	config.programs.zsh = {
		enable = true;

		dotDir = "${config.xdg.configHome}/zsh";

		enableAutosuggestions = true;
		defaultKeymap = "viins";

		dirHashes = {
			dv = "$HOME/dev";
			d = "${config.xdg.userDirs.documents}";
			D = "${config.xdg.userDirs.download}";
			pp = "${config.xdg.userDirs.pictures}";
			vv = "${config.xdg.userDirs.videos}";
			mm = "${config.xdg.userDirs.music}";
		};

		history = {
			path = "${config.xdg.dataHome}/zsh/history";
			save = 10000;
		};

		shellAliases = rec {
			ls = "eza --group-directories-first";
			ll = "eza --group-directories-first -al";
      		la = "eza --group-directories-first -a";
      		vim = "nvim";
      		v = "nvim";
		};

		syntaxHighlighting.enable = true;
	};
}

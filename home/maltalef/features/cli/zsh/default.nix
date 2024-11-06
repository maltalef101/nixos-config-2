{ pkgs, config, ... }: {

	config = { 
		home.file.".config/zsh/completion.zsh".source = ./completion.zsh;

		programs.zsh = {
			enable = true;

			dotDir = ".config/zsh";

			enableCompletion = true;
			defaultKeymap = "viins";
			autocd = true;

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
				share = false;
				save = 10000;
			};

			shellAliases = rec {
				ls = "eza --group-directories-first";
				ll = "eza --group-directories-first -al";
    	  		la = "eza --group-directories-first -a";
    	  		vim = "nvim";
    	  		v = "nvim";
			};

			autosuggestion.enable = true;
			zprof.enable = false;

			plugins = [
				{
					name = "fast-syntax-highlighting";
					src = pkgs.fetchFromGitHub {
						owner = "zdharma-continuum";
						repo = "fast-syntax-highlighting";
						rev = "v1.55";
						sha256 = "DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
					};
				}
			];

			initExtraFirst = ''
				stty stop undef
			'';

			initExtraBeforeCompInit = ''
				zstyle ':completion:*' menu select
				zmodload zsh/complist
			'';

			initExtra = ''
				_comp_options+=(globdots)
				source $ZDOTDIR/completion.zsh

				bindkey -M menuselect 'h' vi-backward-char
				bindkey -M menuselect 'k' vi-up-line-or-history
				bindkey -M menuselect 'l' vi-forward-char
				bindkey -M menuselect 'j' vi-down-line-or-history
				bindkey -v '^?' backward-delete-char
				bindkey '^ ' accept-line # accept suggestions

				autoload edit-command-line; zle -N edit-command-line
				bindkey '^e' edit-command-line

				setopt correct
			'';

			envExtra = ''
				export KEYTIMEOUT=1
			'';
		};
	};
}

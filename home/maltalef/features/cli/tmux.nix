{ pkgs, ... }: {
  programs.tmux = {
    enable = true;

    prefix = "C-Space";
    baseIndex = 1;
    clock24 = true;
    mouse = true;
    escapeTime = 0;
    keyMode = "vi";
    newSession = true;
    historyLimit = 50000;
    aggressiveResize = true;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig =
          "	set -g @continuum-restore 'on'\n	set -g @continuum-save-interval '30' # minutes\n";
      }
    ];

    extraConfig = ''
      bind -n M-J previous-window
      bind -n M-K next-window
      set -g display-time 3000
      set -g status-interval 5
      set -g default-terminal "screen-256color"
      set -g focus-events on '';
  };
}

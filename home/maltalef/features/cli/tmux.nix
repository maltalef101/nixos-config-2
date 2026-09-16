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
    # en RAM y por pane, se llena de a poco (mismo criterio que scrollback.lines de foot)
    historyLimit = 1000000;
    aggressiveResize = true;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig =
          "	set -g @continuum-restore 'on'\n	set -g @continuum-save-interval '10' # minutes\n";
      }
    ];

    extraConfig = ''
      bind -n M-J previous-window
      bind -n M-K next-window

      # scroll con las mismas teclas que en foot: en la pantalla alternativa
      # foot no consume sus binds de scrollback (input.c los reenvía), así
      # que llegan acá; la historia dentro de tmux es de tmux, no de foot
      bind -n M-k copy-mode \; send -X scroll-up
      bind -n M-u copy-mode -u
      bind -T copy-mode-vi M-k send -X scroll-up
      bind -T copy-mode-vi M-j send -X scroll-down
      bind -T copy-mode-vi M-u send -X page-up
      bind -T copy-mode-vi M-d send -X page-down
      set -g display-time 3000
      set -g status-interval 5
      set -g default-terminal "screen-256color"
      set -g focus-events on '';
  };
}

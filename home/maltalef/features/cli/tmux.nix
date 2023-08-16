{
  programs.tmux = {
    enable = true;

    prefix = "C-Space";
    baseIndex = 1;
    clock24 = true;
    mouse = true;
    newSession = true;
    sensibleOnTop = true;

    extraConfig =
      "	set-option -sa terminal-overrides \",xterm*:Tc\"\n	set -sg escape-time 0\n	bind -n M-J previous-window\n	bind -n M-K next-window\n";
  };
}

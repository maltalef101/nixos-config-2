{ pkgs, ... }: {
  # cswap: cambiar de cuenta de Claude Code sin /logout, con dashboard de
  # uso y auto-switch por rate limit. Paquete propio, ver pkgs/claude-swap.
  home.packages = [ pkgs.claude-swap ];
}

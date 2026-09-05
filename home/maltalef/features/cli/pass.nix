{ pkgs, config, ... }: {
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
    settings = {
      # fuera de $HOME, consistente con el homedir de gnupg
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
      # clave maestra; gpg resuelve la subclave [E] vigente
      PASSWORD_STORE_KEY = "AE9F51F4708EE3446AC808F3DDF69FEA8C66B3FB";
    };
  };

  # sin programs.fzf: su integración zsh pisaría el ^R vi-style de zsh/
  home.packages = [ pkgs.fzf ];

  programs.zsh.initContent = ''
    # selector fzf sobre el store; copia el TOTP al portapapeles.
    # lista todo el árbol: qué entrada tiene otpauth:// es ciphertext,
    # no se puede filtrar sin desencriptar
    potp() {
      local d="''${PASSWORD_STORE_DIR:-$HOME/.password-store}" e
      e=$(fd -e gpg . "$d" | sed -e "s|^$d/||" -e 's|\.gpg$||' | fzf) || return
      pass otp -c "$e"
    }
  '';
}

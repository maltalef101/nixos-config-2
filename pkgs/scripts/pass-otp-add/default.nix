{ lib, writeShellApplication, hyprshot, zbar }:
# pass queda afuera de runtimeInputs a propósito: el del profile trae
# pass-otp, y envolver acá el pkgs.pass pelado lo taparía
(writeShellApplication {
  name = "pass-otp-add";
  runtimeInputs = [ hyprshot zbar ];
  text = builtins.readFile ./pass-otp-add;
}) // {
  meta = with lib; {
    description = "Screen-capture an OTP QR code and append it to a pass entry";
    platforms = platforms.all;
  };
}

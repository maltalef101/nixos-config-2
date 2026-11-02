# Prueba de VM del Hyprland de pirincho: nix build .#checks.x86_64-linux.hyprland
#
# Levanta el mismo Hyprland y el mismo plugin que pirincho (los toma de nixosConfigurations.pirincho, no los
# reconstruye) sobre virtio-gpu, con el mesa del sistema en /run/opengl-driver: el caso que crasheaba cuando
# Hyprland salía de un input con otra glibc. Comprueba que arranca sin errores del cargador de mesa, que el
# plugin split-monitor-workspaces carga y que sus dispatchers son válidos. Y la configuración de maltalef en pirincho:
# el hyprland.conf pasa --verify-config (curvas, animaciones con su estilo, reglas de capas), y hyprlock bloquea con
# su hyprlock.conf sin errores de configuración.
{ pkgs, outputs, ... }:
let
  pirincho = outputs.nixosConfigurations.pirincho;
  plugin = pirincho.pkgs.split-monitor-workspaces;
  hm = pirincho.config.home-manager.users.maltalef;
  confMaltalef = hm.xdg.configFile."hypr/hyprland.conf".source;
  confHyprlock = hm.xdg.configFile."hypr/hyprlock.conf".source;
  hyprlock = hm.programs.hyprlock.package;
  confConErrores = pkgs.writeText "con-errores.conf" ''
    animation = windowsIn, 1, 2, default, popon
    layerrule = no_animx on, match:namespace ^(x)$
    animation = fadeIn, 1, 2, no-existe
  '';

  conf = pkgs.writeText "hyprland.conf" ''
    exec-once = ${pirincho.pkgs.hypr-merge-rogues}/bin/hypr-merge-rogues
    plugin = ${plugin}/lib/libsplit-monitor-workspaces.so
    plugin {
      split-monitor-workspaces {
        count = 10
      }
    }
    misc {
      disable_hyprland_logo = true
    }
  '';

  # hyprctl como alice, contra la única instancia (-i 0: sin HYPRLAND_INSTANCE_SIGNATURE no la busca).
  # Sin binds del plugin en la config: se parsea antes de cargar el .so y darían «Invalid dispatcher».
  hyprctl = "sudo -u alice env XDG_RUNTIME_DIR=/run/user/1000 hyprctl -i 0";
in
pkgs.testers.runNixOSTest {
  name = "hyprland";

  nodes.machine = {
    programs.hyprland = {
      enable = true;
      package = pirincho.config.programs.hyprland.package;
      portalPackage = pirincho.config.programs.hyprland.portalPackage;
    };

    users.users.alice = {
      isNormalUser = true;
      uid = 1000;
    };
    services.getty.autologinUser = "alice";
    # Hyprland en la tty1 al entrar alice, como lo arranca la sesión de verdad (sin el login shell de zsh)
    programs.bash.loginShellInit = ''
      if [ "$(tty)" = /dev/tty1 ]; then
        exec Hyprland --config ${conf} > /tmp/hyprland.log 2>&1
      fi
    '';

    # Sin virgl: mesa cae a render por software, pero el camino de carga del driver es el mismo
    virtualisation.qemu.options = [ "-vga none -device virtio-gpu-pci" ];
    virtualisation.memorySize = 2048;

    security.pam.services.hyprlock = { };
    environment.systemPackages = [ pkgs.foot pkgs.jq ];
  };

  testScript = ''
    import json
    import time

    machine.wait_for_unit("multi-user.target")

    with subtest("Hyprland arranca con el mesa del sistema"):
        try:
            machine.wait_until_succeeds("${hyprctl} version", timeout=180)
        finally:
            # si no levanta, que el log diga por qué
            print(machine.execute(
                "ls -la /dev/dri /run/user/1000/hypr/*; tail -n 60 /tmp/hyprland.log; "
                + "${hyprctl} version 2>&1; echo rc=$?; "
                + "grep -iE 'plugin|error|socket' /run/user/1000/hypr/*/hyprland.log | tail -n 40"
            )[1])
        print(machine.succeed("${hyprctl} version"))
        # no `log`: es el logger del driver
        registro = machine.succeed("cat /tmp/hyprland.log")
        assert "MESA-LOADER" not in registro, registro
        assert "GLIBC_" not in registro, registro

    with subtest("el plugin carga"):
        plugins = machine.succeed("${hyprctl} plugin list")
        print(plugins)
        assert "split-monitor-workspaces" in plugins, plugins
        errores = machine.succeed("${hyprctl} configerrors").strip()
        assert errores == "", errores

    with subtest("split-workspace es un dispatcher válido"):
        salida = machine.succeed("${hyprctl} dispatch split-workspace 2").strip()
        assert salida == "ok", salida
        machine.wait_until_succeeds("${hyprctl} activeworkspace | grep -q 'workspace ID 2 '")
        # control: un dispatcher que no existe sí falla
        _, salida = machine.execute("${hyprctl} dispatch no-existe 1")
        assert "Invalid dispatcher" in salida, salida

    # Un monitor headless hace de externo: al sacarlo, sus workspaces vacíos se van y las ventanas de los otros pasan a
    # la misma posición del que queda (12 -> 2), así la barra ve sólo del 1 al 10; al volver, tiene sus 10 y sus ventanas.
    def workspaces():
        return json.loads(machine.succeed("${hyprctl} workspaces -j | jq -c '[.[] | select(.id > 0) | [.id, .monitor]] | sort'"))

    def clientes():
        return json.loads(machine.succeed("${hyprctl} clients -j | jq -c '[.[] | [.class, .workspace.id]] | sort'"))

    def esperar(f, esperado, segundos):
        for _ in range(segundos * 5):
            if f() == esperado:
                return
            time.sleep(0.2)
        assert f() == esperado, f()

    solo = [[i, "Virtual-1"] for i in range(1, 11)]
    con_ext = solo + [[i, "EXT"] for i in range(11, 21)]

    with subtest("al sacar un monitor, sus workspaces se van y sus ventanas se mudan"):
        machine.wait_until_succeeds("pgrep -f bin/hypr-merge-rogues", timeout=30)
        machine.succeed("${hyprctl} output create headless EXT")
        esperar(workspaces, con_ext, 30)
        machine.succeed("${hyprctl} dispatch focusmonitor EXT")
        for ws, clase in [(2, "dos"), (5, "cinco")]:
            machine.succeed(f"${hyprctl} dispatch split-workspace {ws}")
            machine.succeed(f"${hyprctl} dispatch exec 'foot --app-id={clase}'")
            machine.wait_until_succeeds(f"${hyprctl} clients | grep -q 'class: {clase}'", timeout=60)
        machine.succeed("${hyprctl} dispatch split-workspace 3")
        assert clientes() == [["cinco", 15], ["dos", 12]], clientes()
        # el script re-snapshotea medio segundo después de monitoradded
        machine.sleep(2)

        machine.succeed("${hyprctl} output remove EXT")
        esperar(workspaces, solo, 10)
        assert clientes() == [["cinco", 5], ["dos", 2]], clientes()

        machine.succeed("${hyprctl} output create headless EXT")
        esperar(clientes, [["cinco", 15], ["dos", 12]], 30)
        assert workspaces() == con_ext, workspaces()

        # sin ventanas en el externo
        machine.succeed("${hyprctl} dispatch closewindow class:dos; ${hyprctl} dispatch closewindow class:cinco")
        esperar(clientes, [], 10)
        machine.succeed("${hyprctl} output remove EXT")
        esperar(workspaces, solo, 10)

    # --verify-config mira las curvas, el estilo de cada animación y el efecto de cada layerrule (hyprctl keyword no:
    # a un estilo que no existe le dice ok). Con un XDG_RUNTIME_DIR propio, no el de la instancia que corre; sale con
    # 1 si hay errores.
    def verificar(conf):
        _, salida = machine.execute(
            "install -d -o alice -m 700 /tmp/verificar && cd /tmp/verificar && "
            + f"sudo -u alice env XDG_RUNTIME_DIR=/tmp/verificar Hyprland --verify-config --config {conf} 2>&1"
        )
        assert "Config parsing result" in salida, salida
        return [l for l in salida.splitlines() if l.startswith("Config error")]

    with subtest("el hyprland.conf de maltalef en pirincho parsea"):
        # sin cargar el plugin: sus dispatchers dan «Invalid dispatcher», lo demás no puede dar error
        errores = [l for l in verificar("${confMaltalef}") if 'requested "split-' not in l]
        assert errores == [], errores
        # control: un estilo, un efecto y una curva que no existen sí dan error
        errores = verificar("${confConErrores}")
        assert len(errores) == 3, errores

    with subtest("hyprlock bloquea con su hyprlock.conf, sin errores de configuración"):
        machine.succeed("${hyprctl} dispatch exec '${hyprlock}/bin/hyprlock -c ${confHyprlock} > /tmp/hyprlock.log 2>&1'")
        machine.wait_until_succeeds("grep -q 'onLockLocked called' /tmp/hyprlock.log", timeout=60)
        registro = machine.succeed("cat /tmp/hyprlock.log")
        assert "Config has errors" not in registro, registro
        assert "does not exist" not in registro, registro
  '';
}

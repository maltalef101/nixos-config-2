{ lib, python3Packages, procps, src }:
# Switcher multi-cuenta para Claude Code (cswap). No hay derivación en
# nixpkgs: el src es el input `claude-swap` del flake, un git+file al checkout
# en ~/dev/claude-swap, así que la version sale del pyproject del checkout.
# Bumpear: git pull ahí y `nix flake update claude-swap`.
python3Packages.buildPythonApplication {
  pname = "claude-swap";
  version = (lib.importTOML "${src}/pyproject.toml").project.version;
  pyproject = true;
  inherit src;

  build-system = with python3Packages; [ hatchling ];

  # keyring es win32-only (marker en pyproject) y rumps (extra `menubar`) es
  # macOS-only; ninguno se importa en Linux. rich llega vía textual pero el
  # código lo importa directo, así que va explícito.
  dependencies = with python3Packages; [
    textual
    truststore
    rich
  ];

  # pyproject trae addopts "-n auto --dist loadgroup": sin xdist pytest falla
  # por opción desconocida.
  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-asyncio
    pytest-xdist
    procps # process_detection corre `ps` para la hora de inicio del proceso
  ];

  # `ps` también en runtime (ver arriba); `claude` lo busca en PATH y queda
  # afuera a propósito: claude-code va por nix profile, no por el flake.
  # un argumento por elemento: makeWrapper ya no re-separa por espacios.
  makeWrapperArgs = [ "--prefix" "PATH" ":" (lib.makeBinPath [ procps ]) ];

  # El conftest instala un audit hook que rechaza escrituras en los hijos
  # directos de ~ (lo resuelve con HOME limpio, o sea vía passwd), y en el
  # sandbox el home de nixbld en /etc/passwd es /build (= $TMPDIR). Dos
  # víctimas: $TMPDIR/pytest-of-nixbld (zafa un nivel más abajo) y
  # /build/source/.pytest_cache, cuyo mkdir -p sube hasta /build/source
  # (zafa sin el plugin de cache).
  preCheck = ''
    export TMPDIR="$NIX_BUILD_TOP/tmp"
    mkdir -p "$TMPDIR"
  '';
  pytestFlags = [ "-p" "no:cacheprovider" ];
  # estos dos corren un pytest hijo con el conftest cargado desde el arranque:
  # el capture de ese hijo abre un TemporaryFile en $TMPDIR, bajo /build, y el
  # guard lo rechaza antes de que exista ningún tmp_path aislado.
  disabledTests = [
    "test_a_non_worker_does_not_freeze_its_heap_at_exit"
    "test_the_freeze_leaves_the_final_unraisable_sweep_reporting"
    # depende del timing del lock: con la máquina cargada (rebuild del
    # sistema) se pasa del timeout y da LockError. Pasa en frío.
    "test_concurrent_stash_and_retire_lose_no_manifest_row"
  ];

  pythonImportsCheck = [ "claude_swap" ];

  meta = with lib; {
    description = "Multi-account switcher for Claude Code";
    homepage = "https://github.com/realiti4/claude-swap";
    license = licenses.mit;
    mainProgram = "cswap";
    platforms = platforms.linux;
  };
}

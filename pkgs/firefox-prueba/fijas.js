// Las pestañas fijas del Firefox de prueba (pkgs/firefox-prueba). Va en el mozilla.cfg (autoconfig, con privilegios
// de chrome): las preferencias no fijan pestañas. Se abren y se fijan una sola vez por perfil, en la primera ventana;
// después firefox las restaura como a cualquier pestaña fija, y la preferencia de la marca (en el prefs.js del
// perfil) evita que se dupliquen. Si se cierra o se desfija una, no vuelve: para empezar de nuevo, borrar la marca
// en about:config y reiniciar.
try {
  const fijas = @fijas@;
  const marca = "firefox-prueba.fijadas";
  const fijar = (win) => {
    Services.obs.removeObserver(fijar, "browser-delayed-startup-finished");
    if (Services.prefs.getBoolPref(marca, false)) return;
    Services.prefs.setBoolPref(marca, true);
    Services.prefs.savePrefFile(null);
    const gb = win.gBrowser;
    // pinTab la manda al final de las fijas: quedan en el orden de la lista, antes de la pestaña de inicio
    for (const url of fijas) gb.pinTab(gb.addTrustedTab(url, { skipAnimation: true }));
  };
  Services.obs.addObserver(fijar, "browser-delayed-startup-finished");
} catch (e) {
  Components.utils.reportError(e);
}

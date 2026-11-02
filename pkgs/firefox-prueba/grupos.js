// Los grupos de pestañas nativos con el teclado, en el Firefox de prueba (pkgs/firefox-prueba). Va en el mozilla.cfg
// (autoconfig, con privilegios de chrome), como fijas.js: firefox no trae atajos para los grupos, y Tridactyl no
// puede manejarlos (sin el permiso tabGroups, no los nombra ni los pliega). En cada ventana:
//   Ctrl+Alt+G  grupo nuevo con la pestaña (o las seleccionadas), y el panel para el nombre y el color
//   Ctrl+Alt+M  menú para mover la pestaña a un grupo (1-9), a uno nuevo (n) o sacarla del suyo (s)
//   Ctrl+Alt+C  plegar o desplegar el grupo de la pestaña; fuera de un grupo, todos
// Ctrl+Alt+X, U, Z y R son de firefox. Van con <command> y no con oncommand: el cromo no corre código en línea.
try {
  const enVentana = (win) => {
    const doc = win.document;
    const gb = win.gBrowser;
    if (!gb) return;
    const métrica = () => gb.TabMetrics.userTriggeredContext(gb.TabMetrics.METRIC_SOURCE.KEYBOARD);
    // las seleccionadas que se pueden agrupar (las fijas no), o la actual
    const pestañas = () => gb.selectedTabs.filter((t) => !t.pinned);

    // como «Agregar pestaña a grupo nuevo» del menú de la pestaña: el grupo queda donde estaba ella, y se abre el
    // panel del nombre y el color (TabGroupCreateByUser)
    const nuevo = () => {
      const tabs = pestañas();
      if (!tabs.length) return;
      const t = gb.selectedTab.pinned ? tabs[0] : gb.selectedTab;
      gb.addTabGroup(tabs, { insertBefore: t.group ?? t.splitview ?? t, metricsContext: métrica() });
    };

    const plegar = () => {
      const g = gb.selectedTab.group;
      if (g) {
        g.collapsed = !g.collapsed;
        return;
      }
      const grupos = gb.tabGroups;
      const abrir = grupos.length > 0 && grupos.every((x) => x.collapsed);
      for (const x of grupos) x.collapsed = !abrir;
    };

    const menu = doc.createXULElement("menupopup");
    menu.id = "prueba-grupos-menu";
    const item = (label, accesskey, hacer) => {
      const m = doc.createXULElement("menuitem");
      m.setAttribute("label", label);
      if (accesskey) m.setAttribute("accesskey", accesskey);
      m.addEventListener("command", hacer);
      return m;
    };
    menu.addEventListener("popupshowing", (e) => {
      if (e.target !== menu) return;
      menu.replaceChildren();
      const actual = gb.selectedTab.group;
      gb.tabGroups.forEach((g, i) => {
        const m = item(g.label || "Sin nombre", i < 9 ? String(i + 1) : null, () => {
          g.addTabs(pestañas(), métrica());
          win.focus();
        });
        // el color del grupo, como en el menú de la pestaña (tab-context-menu.js)
        m.classList.add("menuitem-iconic", "tab-group-icon");
        if (g.collapsed) m.classList.add("tab-group-icon-collapsed");
        for (const v of ["", "-invert", "-pale"]) {
          m.style.setProperty(`--tab-group-color${v}`, `var(--tab-group-${g.color}${v})`);
        }
        m.style.setProperty("--tab-group-background-color", `var(--tab-group-${g.color})`);
        if (g === actual) m.setAttribute("disabled", "true");
        menu.append(m);
      });
      if (gb.tabGroups.length) menu.append(doc.createXULElement("menuseparator"));
      menu.append(item("Grupo nuevo", "n", nuevo));
      const sacar = item("Sacar del grupo", "s", () => {
        for (const t of pestañas()) gb.ungroupTab(t);
      });
      if (!actual) sacar.setAttribute("disabled", "true");
      menu.append(sacar);
    });
    doc.getElementById("mainPopupSet").append(menu);
    const mover = () => {
      if (gb.selectedTab.pinned) return;
      menu.openPopup(gb.selectedTab, "end_before", 0, 0, false, false, null);
    };

    const comandos = doc.createXULElement("commandset");
    const teclas = doc.createXULElement("keyset");
    for (const [tecla, hacer] of [["G", nuevo], ["M", mover], ["C", plegar]]) {
      const id = `prueba-grupos-${tecla}`;
      const c = doc.createXULElement("command");
      c.id = id;
      c.addEventListener("command", hacer);
      comandos.append(c);
      const k = doc.createXULElement("key");
      k.id = `${id}-tecla`;
      k.setAttribute("key", tecla);
      k.setAttribute("modifiers", "accel,alt");
      k.setAttribute("command", id);
      teclas.append(k);
    }
    doc.documentElement.append(comandos, teclas);
  };
  const alAbrir = (win) => {
    try {
      enVentana(win);
    } catch (e) {
      Components.utils.reportError(e);
    }
  };
  Services.obs.addObserver(alAbrir, "browser-delayed-startup-finished");
} catch (e) {
  Components.utils.reportError(e);
}

#!/usr/bin/env python3
"""mdview: vista previa de un .md con WebKitGTK y el CSS de GitHub en modo
oscuro, en una ventana propia que se re-renderiza sola cuando el archivo
cambia en disco. Sin PDF ni temporales.

Uso: mdview archivo.md [--tamano ANCHOxALTO] [--snapshot salida.png [--eval JS]]

Teclas: q o Escape cierran, r fuerza un re-render, Ctrl con más, menos y 0
hacen zoom.
"""
import argparse
import html
import os
import subprocess
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("WebKit2", "4.1")
from gi.repository import Gdk, Gio, GLib, Gtk, WebKit2  # noqa: E402

# La derivación fija MDVIEW_CSS_DIR y MDVIEW_MERMAID; sin ellas, css/ junto al
# script y sin diagramas.
CSS_DIR = os.environ.get("MDVIEW_CSS_DIR") or os.path.join(os.path.dirname(os.path.abspath(__file__)), "css")
CSS_FILES = ("GithubDark.css", "extra.css")
MERMAID_JS = os.environ.get("MDVIEW_MERMAID")

# pandoc emite <pre class="mermaid"><code>…</code></pre>; mermaid quiere el texto
# pelado en un elemento .mermaid. Los diagramas cambian la altura del documento,
# así que el scroll se restaura recién cuando terminan. data-mdview-listo avisa
# a --snapshot que ya se puede capturar.
JS_FINAL = r"""
// mermaid toma ";" como fin de sentencia aun dentro del texto de un mensaje o
// una Note de sequenceDiagram, y su sanitizador se come <palabra> como si
// fuera una etiqueta HTML: en esa parte del texto van los códigos de entidad
// de mermaid (#59; #60; #62;), dejando pasar <br/>.
function sanearSecuencia(src) {
  if (!/^\s*sequenceDiagram/.test(src)) return src;
  const linea = /^(\s*(?:[Nn]ote\b[^:]*|\S+\s*(?:-->>|->>|-->|->|--x|-x|--\)|-\))\s*\S+)\s*:)(.*)$/;
  return src.split("\n").map((l) => {
    const m = l.match(linea);
    if (!m) return l;
    const texto = m[2]
      .replace(/<br\s*\/?>/g, "\u0001")
      .replace(/;/g, "#59;").replace(/</g, "#60;").replace(/>/g, "#62;")
      .replace(/\u0001/g, "<br/>");
    return m[1] + texto;
  }).join("\n");
}

(async () => {
  for (const el of document.querySelectorAll("pre.mermaid, pre > code.language-mermaid, pre > code.mermaid")) {
    const pre = el.tagName === "CODE" ? el.parentElement : el;
    const div = document.createElement("div");
    div.className = "mermaid";
    div.textContent = sanearSecuencia(pre.textContent);
    pre.replaceWith(div);
  }
  if (window.mermaid) {
    // htmlLabels: false en los dos niveles (mermaid 12 mira el de arriba):
    // las etiquetas HTML (foreignObject) se miden mal en WebKitGTK y quedan
    // recortadas; como texto SVG se miden bien
    mermaid.initialize({
      startOnLoad: false,
      theme: "dark",
      htmlLabels: false,
      flowchart: { htmlLabels: false },
      themeVariables: { fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif" },
    });
    try { await mermaid.run(); } catch (e) { console.error(e); }
  }
  window.scrollTo(0, window.__mdviewScroll || 0);
  const d = document.documentElement.dataset;
  d.mdviewDiagramas = document.querySelectorAll(".mermaid svg").length;
  d.mdviewErrores = document.querySelectorAll(".mermaid svg[aria-roledescription=error]").length;
  d.mdviewListo = "1";
})();
"""
FONDO = "#0d1117"
EVENTOS_CAMBIO = (
    Gio.FileMonitorEvent.CHANGED,
    Gio.FileMonitorEvent.CHANGES_DONE_HINT,
    Gio.FileMonitorEvent.CREATED,
    Gio.FileMonitorEvent.MOVED_IN,
    Gio.FileMonitorEvent.RENAMED,
)


def leer_css():
    partes = []
    for nombre in CSS_FILES:
        ruta = os.path.join(CSS_DIR, nombre)
        if os.path.exists(ruta):
            with open(ruta, encoding="utf-8") as f:
                partes.append(f.read())
    return "\n".join(partes)


class Visor:
    def __init__(self, md, snapshot=None, tamano=(1000, 900), evaluar=None):
        self.md = os.path.abspath(md)
        self.snapshot = snapshot
        self.evaluar = evaluar
        self.css = leer_css()
        # base file:// del directorio del .md, para que las imágenes relativas resuelvan
        self.base = Gio.File.new_for_path(os.path.dirname(self.md)).get_uri() + "/"
        self.scroll_y = 0.0
        self.pendiente = None

        self.win = Gtk.Window(title=os.path.basename(self.md))
        self.win.set_default_size(*tamano)
        self.win.connect("destroy", Gtk.main_quit)
        self.win.connect("key-press-event", self.on_tecla)

        self.view = WebKit2.WebView()
        rgba = Gdk.RGBA()
        rgba.parse(FONDO)
        self.view.set_background_color(rgba)
        self.view.connect("load-changed", self.on_carga)
        self.win.add(self.view)

        # GFileMonitor sigue al nombre, así que banca editores que guardan por rename
        self.monitor = Gio.File.new_for_path(self.md).monitor_file(Gio.FileMonitorFlags.WATCH_MOVES, None)
        self.monitor.connect("changed", self.on_cambio)

        self.cargar()
        self.win.show_all()

    def html(self):
        r = subprocess.run(["pandoc", self.md, "-f", "gfm", "-t", "html5"], capture_output=True, text=True)
        cuerpo = r.stdout
        if r.returncode != 0:
            cuerpo = f'<pre style="color:#ff7b72">{html.escape(r.stderr)}</pre>' + cuerpo
        mermaid = ""
        if MERMAID_JS and os.path.exists(MERMAID_JS):
            mermaid = f'<script src="{Gio.File.new_for_path(MERMAID_JS).get_uri()}"></script>'
        return (
            '<!doctype html><html><head><meta charset="utf-8">'
            f"<title>{html.escape(os.path.basename(self.md))}</title>"
            f"<style>{self.css}</style></head><body>{cuerpo}"
            f"<script>window.__mdviewScroll = {self.scroll_y};</script>{mermaid}"
            f"<script>{JS_FINAL}</script></body></html>"
        )

    def cargar(self):
        self.view.load_html(self.html(), self.base)

    def recargar(self):
        # guarda el scroll, recarga y lo restaura cuando termina la carga
        def listo(view, res, *_):
            try:
                self.scroll_y = view.evaluate_javascript_finish(res).to_double()
            except GLib.Error:
                self.scroll_y = 0.0
            self.cargar()

        self.view.evaluate_javascript("window.scrollY", -1, None, None, None, listo)

    def on_cambio(self, monitor, archivo, otro, evento):
        if evento not in EVENTOS_CAMBIO:
            return
        # los editores escriben en varias tandas: esperar a que se calme
        if self.pendiente:
            GLib.source_remove(self.pendiente)
        self.pendiente = GLib.timeout_add(80, self.disparar)

    def disparar(self):
        self.pendiente = None
        print("mdview: re-render", file=sys.stderr, flush=True)
        self.recargar()
        return False

    def on_carga(self, view, evento):
        if evento != WebKit2.LoadEvent.FINISHED:
            return
        if self.scroll_y:
            view.evaluate_javascript(f"window.scrollTo(0, {self.scroll_y})", -1, None, None, None, None)
        if self.snapshot:
            self.intentos = 0
            GLib.timeout_add(200, self.capturar)

    def capturar(self):
        # espera a que el JS final (diagramas incluidos) marque el documento listo
        def estado(view, res, *_):
            try:
                valor = view.evaluate_javascript_finish(res).to_string()
            except GLib.Error:
                valor = ""
            self.intentos += 1
            if valor.startswith("1") or self.intentos > 50:
                print(f"mdview: snapshot (listo={valor})", file=sys.stderr, flush=True)
                if self.evaluar:
                    self.view.evaluate_javascript(self.evaluar, -1, None, None, None, mostrar)
                else:
                    self.view.get_snapshot(WebKit2.SnapshotRegion.FULL_DOCUMENT, WebKit2.SnapshotOptions.NONE, None, guardar)
            else:
                GLib.timeout_add(200, self.capturar)

        def mostrar(view, res, *_):
            # --eval: imprime el resultado del JS sobre el documento ya renderizado
            try:
                print(view.evaluate_javascript_finish(res).to_string(), flush=True)
            except GLib.Error as e:
                print(f"mdview: --eval falló: {e.message}", file=sys.stderr, flush=True)
            self.view.get_snapshot(WebKit2.SnapshotRegion.FULL_DOCUMENT, WebKit2.SnapshotOptions.NONE, None, guardar)

        def guardar(view, res, *_):
            view.get_snapshot_finish(res).write_to_png(self.snapshot)
            Gtk.main_quit()

        # en una IIFE: evaluate_javascript corre en el scope global y un const
        # repetido entre sondeos sería un error de sintaxis
        js = ('(() => { const d = document.documentElement.dataset; '
              'return (d.mdviewListo || "0") + " diagramas=" + d.mdviewDiagramas + " errores=" + d.mdviewErrores; })()')
        self.view.evaluate_javascript(js, -1, None, None, None, estado)
        return False

    def on_tecla(self, win, ev):
        nombre = Gdk.keyval_name(ev.keyval)
        ctrl = bool(ev.state & Gdk.ModifierType.CONTROL_MASK)
        if nombre in ("q", "Escape"):
            Gtk.main_quit()
        elif nombre == "r":
            self.recargar()
        elif ctrl and nombre in ("plus", "equal", "KP_Add"):
            self.view.set_zoom_level(self.view.get_zoom_level() * 1.1)
        elif ctrl and nombre in ("minus", "KP_Subtract"):
            self.view.set_zoom_level(self.view.get_zoom_level() / 1.1)
        elif ctrl and nombre in ("0", "KP_0"):
            self.view.set_zoom_level(1.0)


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("archivo", help="archivo .md a mostrar")
    p.add_argument("--snapshot", metavar="PNG", help="renderiza, guarda una captura del documento entero y sale (para pruebas)")
    p.add_argument("--tamano", "--tamaño", metavar="ANCHOxALTO", default="1000x900", help="tamaño inicial de la ventana (por defecto 1000x900)")
    p.add_argument("--eval", metavar="JS", help="con --snapshot: evalúa JS sobre el documento renderizado e imprime el resultado")
    a = p.parse_args()
    try:
        tamano = tuple(int(n) for n in a.tamano.lower().split("x"))
        assert len(tamano) == 2
    except (ValueError, AssertionError):
        sys.exit(f"mdview: tamaño inválido {a.tamano!r}, se espera ANCHOxALTO")
    if not os.path.isfile(a.archivo):
        sys.exit(f"mdview: no existe {a.archivo}")
    Visor(a.archivo, a.snapshot, tamano, a.eval)
    Gtk.main()


if __name__ == "__main__":
    main()

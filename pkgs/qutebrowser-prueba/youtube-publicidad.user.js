// ==UserScript==
// @name         prueba: YouTube sin publicidad (qutebrowser-prueba)
// @description  Saca la publicidad de las respuestas del reproductor y, si igual aparece una, la saltea.
// @match        https://www.youtube.com/*
// @match        https://m.youtube.com/*
// @match        https://music.youtube.com/*
// @run-at       document-start
// ==/UserScript==

// qutebrowser 3.7 bloquea pedidos (adblock-rust) pero no tiene filtrado cosmético ni scriptlets de uBlock
// (issue #6480, PR #7629 sin aterrizar), y la publicidad de YouTube viene en la misma respuesta del
// reproductor que el video. Esto hace a mano lo que hacen los filtros +js() de uBlock para YouTube:
//
// 1. Antes de que corran los scripts de la página (document-start, en el mundo principal), envuelve
//    JSON.parse, Response.json/text de fetch y ytInitialPlayerResponse para borrar las claves de publicidad
//    (adPlacements, playerAds, adSlots, adBreakHeartbeatParams) del player y de /youtubei/v1/player|next.
// 2. Si igual se ve una publicidad (el reproductor con la clase ad-showing, por ejemplo si YouTube la cose
//    en el mismo flujo del video), la silencia, la adelanta hasta el final y aprieta «Saltar».
// 3. Esconde los recuadros de publicidad de la portada, la búsqueda y la columna (filtrado cosmético mínimo).
//
// Es código propio, sin bajar nada de afuera. Riesgo: YouTube cambia seguido las claves y las clases, y a
// veces detecta el bloqueo («Los bloqueadores de anuncios infringen…»); si rompe la reproducción, se borra
// data/greasemonkey/prueba-youtube-publicidad.user.js del basedir y :greasemonkey-reload.
(function () {
  "use strict";
  const CLAVES = ["adPlacements", "playerAds", "adSlots", "adBreakHeartbeatParams"];
  // a la consola (qutebrowser la muestra con --debug --logfilter js)
  const aviso = (texto) => console.info("prueba-yt " + location.host + ": " + texto);

  function podar(o) {
    if (!o || typeof o !== "object") return o;
    const objetivos = [o, o.playerResponse, o.response];
    if (Array.isArray(o)) for (const x of o) if (x && typeof x === "object") objetivos.push(x.playerResponse);
    for (const t of objetivos) {
      if (!t || typeof t !== "object") continue;
      for (const k of CLAVES) {
        if (k in t) {
          delete t[k];
          aviso("podado " + k);
        }
      }
    }
    return o;
  }

  const parse = JSON.parse;
  JSON.parse = function () {
    return podar(parse.apply(this, arguments));
  };

  const esPlayer = (u) => /\/youtubei\/v1\/(player|next|reel)/.test(String(u || ""));
  const json = Response.prototype.json;
  Response.prototype.json = function () {
    return esPlayer(this.url) ? json.apply(this, arguments).then(podar) : json.apply(this, arguments);
  };
  const text = Response.prototype.text;
  Response.prototype.text = function () {
    if (!esPlayer(this.url)) return text.apply(this, arguments);
    return text.apply(this, arguments).then((t) => {
      try {
        return JSON.stringify(podar(parse(t)));
      } catch (e) {
        return t;
      }
    });
  };

  for (const nombre of ["ytInitialPlayerResponse", "ytInitialData"]) {
    let valor;
    try {
      Object.defineProperty(window, nombre, {
        configurable: true,
        get: () => valor,
        set: (v) => { valor = podar(v); },
      });
    } catch (e) { /* ya definida: queda JSON.parse */ }
  }

  // 2. El que saltea: la publicidad que igual llegue al reproductor
  const BOTONES = ".ytp-skip-ad-button, .ytp-ad-skip-button, .ytp-ad-skip-button-modern, .videoAdUiSkipButton";
  let salteadas = 0;
  function saltear() {
    const reproductor = document.querySelector(".html5-video-player.ad-showing, .html5-video-player.ad-interrupting");
    if (!reproductor) return;
    const video = reproductor.querySelector("video");
    if (video) {
      video.muted = true;
      if (isFinite(video.duration) && video.duration > 0 && video.currentTime < video.duration - 0.1) {
        video.currentTime = video.duration;
        salteadas++;
        aviso("publicidad adelantada (" + salteadas + ")");
      }
    }
    const boton = document.querySelector(BOTONES);
    if (boton) {
      boton.click();
      aviso("«Saltar» apretado");
    }
  }

  // 3. Los recuadros (portada, búsqueda, columna, cabecera, YouTube Music)
  const CSS = `
    ytd-ad-slot-renderer, ytd-in-feed-ad-layout-renderer, ytd-promoted-sparkles-web-renderer,
    ytd-promoted-video-renderer, ytd-display-ad-renderer, ytd-banner-promo-renderer, ytd-statement-banner-renderer,
    ytd-companion-slot-renderer, ytd-action-companion-ad-renderer, ytd-player-legacy-desktop-watch-ads-renderer,
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-ads"], #masthead-ad, #player-ads,
    .ytd-merch-shelf-renderer, ytd-rich-item-renderer:has(> #content > ytd-ad-slot-renderer),
    ytmusic-mealbar-promo-renderer, ytmusic-statement-banner-renderer, .ytp-ad-overlay-container,
    .ytp-featured-product, .ytp-suggested-action { display: none !important; }`;
  function estilo() {
    const s = document.createElement("style");
    s.textContent = CSS;
    (document.head || document.documentElement).appendChild(s);
  }

  function arrancar() {
    estilo();
    new MutationObserver(saltear).observe(document.documentElement, {
      subtree: true, attributes: true, attributeFilter: ["class"], childList: true,
    });
    setInterval(saltear, 500);
  }
  if (document.documentElement) arrancar();
  else document.addEventListener("readystatechange", arrancar, { once: true });
})();

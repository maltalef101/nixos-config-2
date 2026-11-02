# Con el tema, el módulo «VPN» de la isla de estado (custom/vpn): un candado y los nombres de las VPN prendidas
# («infra · otra»); sin ninguna, no se ve. En el tooltip, cada una con su dirección o su interfaz.
# - Las de NetworkManager de tipo vpn y wireguard (nmcli). La VPN de infra del sistema (chaska.vpnInfra, si su
#   configuración la tiene) sale de `<comando> estado --waybar`: por swanctl no la ve NetworkManager; por
#   NetworkManager es su perfil, que se muestra una sola vez, como «infra».
# - Clic: un menú de fuzzel con todas, marcadas las prendidas; elegir una la prende o la apaga (nmcli, o
#   `<comando> arriba|abajo` la de infra). Otro clic con el menú abierto lo cierra.
# - Se refresca con la señal de la VPN de infra (senalWaybar, que también manda al cambiar), cada 10 s, y
#   con barra-vpn-vigia, que escucha `nmcli monitor` y manda la señal cuando NetworkManager cambia algo.
{ osConfig ? { }, config, lib, pkgs, ... }:
let
	tema = config.tema;
	infra = lib.attrByPath [ "chaska" "vpnInfra" ] { enable = false; } osConfig;
	senal = if infra.enable then infra.senalWaybar else 9;
	nm = lib.attrByPath [ "networking" "networkmanager" "package" ] pkgs.networkmanager osConfig;

	barraVpn = pkgs.writeShellApplication {
		name = "barra-vpn";
		runtimeInputs = [ nm config.programs.fuzzel.package ] ++ (with pkgs; [ jq iproute2 gawk procps libnotify coreutils ]);
		text = ''
			INFRA=${if infra.enable then lib.getExe infra.comando else ""}
			PERFIL_INFRA=${if infra.enable then lib.escapeShellArg infra.nombre else ""}
			VIA=${if infra.enable then infra.via else ""}
			TENUE='#${tema.colores.textoTenue}'

			refrescarWaybar() { pkill -RTMIN+${toString senal} -x waybar 2>/dev/null || true; }
			# para el markup de pango (el texto y el tooltip de waybar)
			escapar() { local s=''${1//&/&amp;}; s=''${s//</&lt;}; printf '%s' "''${s//>/&gt;}"; }
			# nmcli -t escapa «:» y «\» en el último campo
			desescapar() { local s=''${1//\\:/:}; printf '%s' "''${s//\\\\/\\}"; }

			# las VPN de NetworkManager, una por línea: uuid:tipo:dispositivo:estado:nombre (activated, activating, o
			# vacío si no está activa)
			conexiones() {
				local activas
				activas=$(nmcli -t -f UUID,DEVICE,STATE connection show --active 2>/dev/null || true)
				nmcli -t -f UUID,TYPE,NAME connection show 2>/dev/null | while IFS=: read -r uuid tipo nombre; do
					case "$tipo" in vpn|wireguard) ;; *) continue ;; esac
					local disp="" est=""
					# (sin línea, la conexión no está activa: read falla y no tiene que cortar el bucle)
					IFS=: read -r _ disp est < <(grep -m1 "^$uuid:" <<<"$activas") || true
					printf '%s:%s:%s:%s:%s\n' "$uuid" "$tipo" "$disp" "$est" "$(desescapar "$nombre")"
				done
			}

			# la dirección de una conexión activa: la de NetworkManager o la de su interfaz
			direccion() {
				local dir
				dir=$(nmcli -g IP4.ADDRESS connection show --active uuid "$1" 2>/dev/null | awk -F' [|] ' '{ print $1; exit }')
				[ -z "$dir" ] && [ -n "$2" ] && dir=$(ip -4 -o addr show dev "$2" 2>/dev/null | awk '{ print $4; exit }')
				printf '%s' "''${dir:-$2}"
			}

			# la de infra: clase (arriba, reconectando, aviso, abajo) y dirección o porqué
			infraEstado() {
				[ -n "$INFRA" ] || return 0
				"$INFRA" estado --waybar 2>/dev/null | jq -r '[.class, (if .class == "arriba" then .text else (.tooltip | sub("^[^:]*: "; "")) end)] | join("\t")' || true
			}

			estado() {
				local textos=() lineas=() clases=() clase porque
				IFS=$'\t' read -r clase porque < <(infraEstado) || true
				if [ "$VIA" = swanctl ]; then
					case "''${clase:-}" in
						arriba) textos+=(infra); lineas+=("infra: $(escapar "$porque") (swanctl)") ;;
						reconectando) textos+=("<span color='$TENUE'>infra…</span>"); lineas+=("infra: $(escapar "$porque")") ;;
						aviso) textos+=("infra ⚠"); lineas+=("infra: $(escapar "$porque")"); clases+=(aviso) ;;
					esac
				fi
				while IFS=: read -r uuid tipo disp est nombre; do
					local etiqueta=$nombre
					[ -n "$PERFIL_INFRA" ] && [ "$nombre" = "$PERFIL_INFRA" ] && etiqueta=infra
					case "$est" in
						activated)
							textos+=("$(escapar "$etiqueta")")
							if [ "$etiqueta" = infra ]; then
								lineas+=("infra: $(escapar "''${porque:-$disp}") (NetworkManager)")
							else
								lineas+=("$(escapar "$etiqueta"): $(escapar "$(direccion "$uuid" "$disp")") ($tipo)")
							fi
							;;
						activating)
							textos+=("<span color='$TENUE'>$(escapar "$etiqueta")…</span>")
							lineas+=("$(escapar "$etiqueta"): conectando")
							;;
					esac
				done < <(conexiones)

				if [ ''${#textos[@]} -eq 0 ]; then
					echo '{"text":""}'
					return
				fi
				local texto tooltip
				texto="<span font='Noto Color Emoji'>🔒</span> ''${textos[0]}"
				for t in "''${textos[@]:1}"; do texto+=" · $t"; done
				tooltip=$(printf '%s\n' "''${lineas[@]}")
				jq -cn --arg text "$texto" --arg tooltip "$tooltip" --args '{text: $text, tooltip: $tooltip, class: (["arriba"] + $ARGS.positional)}' "''${clases[@]}"
			}

			menu() {
				# un segundo clic con el menú abierto lo cierra
				if pkill -x fuzzel; then return; fi
				local entradas=() acciones=() clase porque
				if [ "$VIA" = swanctl ]; then
					IFS=$'\t' read -r clase porque < <(infraEstado) || true
					if [ "''${clase:-}" = arriba ]; then
						entradas+=("󰌾  infra"); acciones+=("infra abajo")
					else
						entradas+=("    infra"); acciones+=("infra arriba")
					fi
				fi
				while IFS=: read -r uuid _ _ est nombre; do
					local etiqueta=$nombre accion
					if [ -n "$PERFIL_INFRA" ] && [ "$nombre" = "$PERFIL_INFRA" ]; then
						etiqueta=infra
						if [ -n "$est" ]; then accion="infra abajo"; else accion="infra arriba"; fi
					elif [ -n "$est" ]; then accion="nm down $uuid"
					else accion="nm up $uuid"
					fi
					if [ -n "$est" ]; then entradas+=("󰌾  $etiqueta"); else entradas+=("    $etiqueta"); fi
					acciones+=("$accion")
				done < <(conexiones)
				[ ''${#entradas[@]} -gt 0 ] || { notify-send -a barra-vpn VPN "no hay VPN configuradas"; return; }

				local i
				i=$(printf '%s\n' "''${entradas[@]}" \
					| fuzzel --dmenu --index --prompt "VPN  " --placeholder "prender o apagar" --lines "''${#entradas[@]}" --width 30) || return 0
				[ -n "$i" ] || return 0
				read -r donde que uuid <<<"''${acciones[$i]}"
				if [ "$donde" = infra ]; then
					"$INFRA" "$que" </dev/null || true
				else
					local salida
					if ! salida=$(nmcli --wait 60 connection "$que" uuid "$uuid" 2>&1); then
						notify-send -a barra-vpn "VPN" "''${entradas[$i]#*  }: $salida"
					fi
				fi
				refrescarWaybar
			}

			# barra-vpn-vigia: cada cambio de NetworkManager refresca el módulo (los que llegan juntos, una vez)
			vigia() {
				nmcli monitor | while IFS= read -r _; do
					while IFS= read -r -t 0.3 _; do :; done
					refrescarWaybar
				done
			}

			case "''${1:-}" in
				estado) estado ;;
				menu) menu ;;
				vigia) vigia ;;
				*) echo "uso: barra-vpn estado|menu|vigia" >&2; exit 64 ;;
			esac
		'';
	};
in lib.mkIf tema.enable {
	home.packages = [ barraVpn ];

	programs.waybar.settings.mainbar."custom/vpn" = {
		return-type = "json";
		exec = "${lib.getExe barraVpn} estado";
		interval = 10;
		signal = senal;
		on-click = "${lib.getExe barraVpn} menu";
	};

	systemd.user.services.barra-vpn-vigia = {
		Unit = {
			Description = "Refresca el módulo VPN de waybar cuando NetworkManager cambia";
			PartOf = [ "graphical-session.target" ];
			After = [ "graphical-session.target" ];
		};
		Service = {
			ExecStart = "${lib.getExe barraVpn} vigia";
			Restart = "always";
			RestartSec = 5;
		};
		Install.WantedBy = [ "graphical-session.target" ];
	};
}

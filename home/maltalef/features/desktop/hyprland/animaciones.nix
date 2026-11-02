{ config, lib, ... }:
let
	tema = config.tema;
in {
	# Las animaciones de Hyprland. Con el tema (pirincho) son la forma del
	# tema, iguales con todas las paletas: curvas propias y un estilo por evento.
	# Sin el tema, las de siempre (todas default a 200 ms).
	#
	# La velocidad va en décimas de segundo (2.5 = 250 ms). Lo de todos los días
	# (abrir, cerrar, cambiar de workspace, menús) queda en 250 ms o menos; sólo
	# los bordes y el atenuado, que no frenan nada, llegan a 300.
	wayland.windowManager.hyprland.settings = if tema.enable then {
		bezier = [
			# arranca rápido y frena largo (easeOutQuint): casi todo
			"suave, 0.22, 1, 0.36, 1"
			# lo mismo, pasándose del final un 2 % y volviendo: un rebote que
			# apenas se ve, para lo que entra o se acomoda
			"rebote, 0.25, 1.25, 0.5, 1"
			# arranca lento y se va rápido: lo que sale
			"salida, 0.3, 0, 1, 1"
		];

		animation = [
			"global, 1, 3, suave"

			# las ventanas entran creciendo desde el 87 % con el rebote, salen
			# achicándose apenas mientras se desvanecen, y al acomodarse el
			# layout se deslizan a su lugar
			#
			# La salida es corta y arranca rápido (suave, no salida): Hyprland
			# anima una foto de la ventana tomada al cerrarse, y de los clientes
			# que sueltan el buffer antes (foot) la foto sale sólo con el borde.
			# Con una curva que arranca lento ese marco quedaba casi opaco la
			# mayor parte de la animación; así se va en un par de cuadros.
			"windowsIn, 1, 2.5, rebote, popin 87%"
			"windowsOut, 1, 0.8, suave, popin 95%"
			"windowsMove, 1, 2.5, rebote"

			# la opacidad: entrar más lento que salir
			"fadeIn, 1, 2, suave"
			"fadeOut, 1, 0.8, suave"
			"fadeSwitch, 1, 3, suave"
			"fadeDim, 1, 3, suave"
			"fadeLayersIn, 1, 2, suave"
			"fadeLayersOut, 1, 1.5, salida"
			"fadePopupsIn, 1, 1.5, suave"
			"fadePopupsOut, 1, 1, salida"

			# las capas, con fade; las que tienen un lugar propio entran desde
			# ahí (las layerrule de abajo)
			"layersIn, 1, 2.5, suave, fade"
			"layersOut, 1, 1.5, salida, fade"

			# el color del borde al cambiar el foco
			"border, 1, 3, suave"

			# los workspaces se corren un 15 % mientras se cruzan en fade (no
			# la pantalla entera); los special (volumen, chat, scratchpad) igual
			# pero en vertical, como bajando
			"workspaces, 1, 2.5, suave, slidefade 15%"
			"specialWorkspace, 1, 2.5, suave, slidefadevert 20%"
		];

		# sintaxis de 0.56, como las windowrule: efecto con valor y match:
		layerrule = [
			# la barra baja desde arriba; el centro de swaync entra desde la
			# derecha, donde está; fuzzel, en el medio, crece como una ventana
			"animation slide top, match:namespace ^(waybar)$"
			"animation slide right, match:namespace ^(swaync-control-center)$"
			"animation popin 90%, match:namespace ^(launcher)$"
			# sin animación la selección de slurp y el congelado de hyprpicker
			# (hyprshot -m region): si no, la captura sale con la capa a medio
			# desvanecer
			"no_anim on, match:namespace ^(selection|hyprpicker)$"
		];
	} else {
		animation = [
			"workspaces,1,2,default"
			"specialWorkspace,1,2,default,slidevert"
			"windows,1,2,default,slide"
			"border,1,2,default"
			"fade,1,2,default"
			"layers,1,2,default"
		];
	};
}

{ inputs, outputs }: {
	additions = final: _prev: import ../pkgs { pkgs = final; inherit inputs; };

	modifications = final: prev: {
		# El Hyprland de nixpkgs, el único del sistema: programs.hyprland,
		# wayland.windowManager.hyprland de home-manager, el portal y los
		# plugins resuelven todos a esta derivación (se compila una vez, por
		# el parche). withUWSM = false es lo que pasa programs.hyprland sin
		# uwsm; con el default (true) el de home-manager sería otra derivación.
		# Parche: devolver el foco a la ventana des-tragada al cerrar el
		# swallower. El candidato de foco lo elige el layout relativo a la
		# ventana que cierra, y la restaurada es un target nuevo sin relación
		# con esa posición -> ganaba la otra ventana del workspace. Upstream
		# lo descartó (hyprwm/Hyprland#4296). Revisar el rebase al bumpear
		# nixpkgs.
		hyprland = (prev.hyprland.override { withUWSM = false; }).overrideAttrs (old: {
			patches = (old.patches or [ ]) ++ [ ./hyprland-unswallow-focus.patch ];
		});

		# Construido contra el Hyprland de arriba (mkHyprlandPlugin toma
		# final.hyprland), el mismo que corre.
		# split-grabroguewindows saca las ventanas de los special workspaces
		# (scratchpads) al juntar rogues: el filtro tiene el De Morgan al
		# revés (&& en vez de ||). El port C++ quedó deprecado upstream a
		# favor de la reescritura en lua (que ya lo trae bien), así que no
		# hay fix para v0.56 y va parche local. Ver el .patch. El segundo
		# saltea además las ventanas tragadas (swallow), que si no quedan
		# como tile invisible en el workspace destino.
		split-monitor-workspaces = final.hyprlandPlugins.mkHyprlandPlugin {
			pluginName = "split-monitor-workspaces";
			version = "0.56.0";
			src = inputs.split-monitor-workspaces;
			patches = [
				./split-grabroguewindows-skip-specials.patch
				./split-grabroguewindows-skip-swallowed.patch
			];
			nativeBuildInputs = [ final.meson final.ninja ];
			meta = {
				homepage = "https://github.com/Duckonaut/split-monitor-workspaces";
				description = "Workspaces por monitor, estilo awesome/dwm";
				license = final.lib.licenses.bsd3;
				platforms = final.lib.platforms.linux;
			};
		};

		# Las islas de la barra con el tema son group/*, y el :hover de un
		# grupo es un PRELIGHT que waybar pone y saca a mano con el enter y el
		# leave del puntero. Con el menú de la bandeja abierto (nm-applet), el
		# grab de GTK le manda el leave al menú: la isla quedaba con el borde
		# de hover hasta volver a pasar el puntero. Upstream lo arregló para
		# los módulos y los ítems de la bandeja (Alexays/Waybar#3980, #4372),
		# no para los grupos. Sacar cuando upstream lo arregle.
		waybar = prev.waybar.overrideAttrs (old: {
			patches = (old.patches or [ ]) ++ [ ./waybar-group-grab-hover.patch ];
		});

		# test_sign_cleartext rompe con el sqv de nixpkgs 2026-10 ("Input is
		# not an inline signature"): el test, no la herramienta. Sacar cuando
		# upstream lo arregle.
		sh4d0wup = prev.sh4d0wup.overrideAttrs (old: {
			checkFlags = (old.checkFlags or [ ]) ++ [
				"--skip=sign::pgp::tests::test_sign_cleartext"
			];
		});
	};

#	modifications = final: prev: {
#		hyprland-patched = let
#			libinput = prev.libinput.overrideAttrs (self: {
#				name = "libinput";
#				version = "1.26.0";
#				src = final.fetchFromGitLab {
#					domain = "gitlab.freedesktop.org";
#					owner = "libinput";
#					repo = "libinput";
#					rev = self.version;
#					hash = "sha256-mlxw4OUjaAdgRLFfPKMZDMOWosW9yKAkzDccwuLGCwQ=";
#				};
#			});
#		in
#			inputs.hyprland.packages.${prev.system}.hyprland.override {
#				libinput = libinput;
#				aquamarine = inputs.hyprland.inputs.aquamarine.packages.${prev.system}.aquamarine.override {
#					libinput = libinput;
#				};
#			};
#	};
#
#	unstable-packages = final: _prev: {
#		unstable = import inputs.nixpkgs-unstable {
#			system = final.system;
#			config.allowUnfree = true;
#		};
#	};
}

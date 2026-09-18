{ inputs, outputs }: {
	additions = final: _prev: import ../pkgs { pkgs = final; };

	modifications = _final: prev: {
		# split-grabroguewindows saca las ventanas de los special workspaces
		# (scratchpads) al juntar rogues: el filtro tiene el De Morgan al
		# revés (&& en vez de ||). El port C++ quedó deprecado upstream a
		# favor de la reescritura en lua (que ya lo trae bien), así que no
		# hay fix para v0.56 y va parche local. Ver el .patch.
		split-monitor-workspaces =
			inputs.split-monitor-workspaces.packages.${prev.stdenv.hostPlatform.system}.split-monitor-workspaces.overrideAttrs (old: {
				patches = (old.patches or [ ]) ++ [ ./split-grabroguewindows-skip-specials.patch ];
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

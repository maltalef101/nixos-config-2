{ inputs, outputs }: {
	additions = final: _prev: import ../pkgs { pkgs = final; };

	modifications = final: prev: {
		hyprland-patched = let
			libinput = prev.libinput.overrideAttrs (self: {
				name = "libinput";
				version = "1.26.0";
				src = final.fetchFromGitLab {
					domain = "gitlab.freedesktop.org";
					owner = "libinput";
					repo = "libinput";
					rev = self.version;
					hash = "sha256-mlxw4OUjaAdgRLFfPKMZDMOWosW9yKAkzDccwuLGCwQ=";
				};
			});
		in
			inputs.hyprland.packages.${prev.system}.hyprland.override {
				libinput = libinput;
				aquamarine = inputs.hyprland.inputs.aquamarine.packages.${prev.system}.aquamarine.override {
					libinput = libinput;
				};
			};
	};

	unstable-packages = final: _prev: {
		unstable = import inputs.nixpkgs-unstable {
			system = final.system;
			config.allowUnfree = true;
		};
	};
}

{ config, ... }: {
	services.fprintd.enable = true;

	# Si se suspende con hyprlock verificando la huella, el lector se cae del
	# USB al resumir y fprintd queda con el claim colgado ("Device was already
	# claimed") hasta reiniciarlo. Lo bajamos antes de dormir: al resumir lo
	# levanta de nuevo la activación D-Bus (hyprlock re-claimea en
	# PrepareForSleep false) con el dispositivo ya re-enumerado.
	# No usar Conflicts=sleep.target: si algo activa fprintd mientras el job
	# de suspensión está pendiente, lo cancela.
	systemd.services.fprintd-sleep = {
		description = "Detener fprintd antes de suspender";
		before = [ "sleep.target" ];
		wantedBy = [ "sleep.target" ];
		serviceConfig = {
			Type = "oneshot";
			ExecStart = "${config.systemd.package}/bin/systemctl stop fprintd.service";
		};
	};
}

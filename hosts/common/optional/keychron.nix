{
	# Reglas udev de QMK: acceso a los bootloaders DFU para flashear firmware.
	hardware.keyboard.qmk.enable = true;

	# Acceso hidraw a los teclados Keychron (vendor 3434) para el usuario de la
	# sesión, así Keychron Launcher / VIA (WebHID en Chromium) pueden configurar
	# iluminación, mapeo y polling rate.
	services.udev.extraRules = ''
		KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", TAG+="uaccess"
	'';
}

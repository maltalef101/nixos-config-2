{ lib, ... }:
let
	# genera perfiles intermedios para una transición gradual de temperatura;
	# hyprsunset no tiene fade nativo: cada perfil es un salto duro, así que
	# escalonamos pasos chicos (150K c/u) que a ojo se ven como un fade
	mkTransition = { startHour, startMin ? 0, from, to, minutes ? 20, steps ? 10 }:
		map (i:
			let total = startHour * 60 + startMin + (i * minutes / steps);
			in {
				time = "${lib.fixedWidthNumber 2 (total / 60)}:${lib.fixedWidthNumber 2 (lib.mod total 60)}";
				temperature = from + (to - from) * i / steps;
			}) (lib.range 0 steps);
in {
	services.hyprsunset = {
		enable = true;
		settings.profile =
			mkTransition { startHour = 11; from = 4500; to = 6000; } # amanece: 11:00 → 11:20
			++ mkTransition { startHour = 20; from = 6000; to = 4500; }; # atardece: 20:00 → 20:20
	};
}

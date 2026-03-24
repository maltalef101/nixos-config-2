let is_tty1 = (^tty) == "/dev/tty1"
let xorg_running = (^pidof Xorg)

if $is_tty1 and xorg_running != 0 {
	 exec startx -- vt01
}

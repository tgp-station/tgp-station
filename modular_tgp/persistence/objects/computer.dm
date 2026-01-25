/obj/machinery/computer/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, authenticated)

/obj/machinery/computer/rdconsole/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, locked)

/obj/machinery/computer/cargo/express/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, locked)

/obj/machinery/computer/cargo/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, contraband)

/obj/machinery
	var/list/persistent_components

/obj/machinery/get_custom_save_vars(save_flags=ALL) //FIXME: Fails to save cells (and maybe other items)
	. = ..()
	var/obj/item/circuitboard/machine/machine_circuit = circuit
	if(!istype(machine_circuit) || !length(machine_circuit.req_components))
		return

	var/list/comps_to_save
	for(var/datum/component as anything in component_parts)
		if(!istype(component, /obj/item/stock_parts) && !istype(component, /datum/stock_part)) continue
		if(component == machine_circuit) continue
		if(!isnull(machine_circuit.req_components[component.type])) continue
		if(get_tier(component) == 1) continue //ignore T1
		LAZYADD(comps_to_save, component.type)

	if(LAZYLEN(comps_to_save))
		.[NAMEOF(src, persistent_components)] = comps_to_save


/obj/machinery/Initialize(mapload)
	if(!LAZYLEN(persistent_components) || isnull(circuit))
		return ..()
	if(ispath(circuit, /obj/item/circuitboard))
		circuit = new circuit(src)
	else
		circuit = locate() in contents
	var/obj/item/circuitboard/machine/machine_circuit = circuit
	var/list/operating_parts = list()
	for(var/key in machine_circuit.req_components)
		operating_parts += key
	for(var/datum/component as anything in persistent_components)
		for(var/mach_comp in operating_parts)
			if(get_base_stock_path(component) != get_base_stock_path(mach_comp)) continue
			operating_parts -= mach_comp
		if(ispath(component, /datum/stock_part))
			persistent_components -= component
			persistent_components += GLOB.stock_part_datums[component]




	machine_circuit.replacement_parts = operating_parts + persistent_components //shit implementation todo
	return ..()

/obj/machinery/proc/get_tier(datum/part)
	if(!ispath(part))
		part = part.type
	var/datum/stock_part/as_datum = part
	var/obj/item/stock_parts/as_item = part
	if(!ispath(part, /datum/stock_part) && !ispath(part, /obj/item/stock_parts)) return null
	return istype(as_datum) ? initial(as_datum.tier) : initial(as_item.rating)

/obj/machinery/proc/get_base_stock_path(datum/stock_part/part)
	if(isnull(part))
		CRASH("get base somehow null")
	if(!ispath(part))
		part = part.type
	if(ispath(part, /obj/item/stock_parts))
		part = GLOB.stock_part_datums_per_object[part]
	var/todo = GLOB.stock_part_datums_per_object[initial(part.physical_object_base_type)]
	return todo


/obj/machinery/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, panel_open)

//if(movable_atom in component_parts)
//	continue

/obj/machinery/PersistentInitialize()
	. = ..()
	update_appearance()

/obj/item/circuitboard/is_saveable(turf/current_loc, list/obj_blacklist)
	// so circuits always spawn inside machines during init so we need to skip saving them
	// to avoid duplicating since they are apart of contents however certain circuits (ie. cargo)
	// have hacked vars that will need special handling (save but delete the original circuit in PersistentInitialize)
	if(istype(loc, /obj/machinery))
		var/obj/machinery/parent_machine = loc
		if(src == parent_machine.circuit)
			return FALSE

	return ..()

/obj/machinery/camera/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, network)
	. += NAMEOF(src, camera_construction_state)
	. += NAMEOF(src, camera_upgrade_bitflags)
	. += NAMEOF(src, camera_enabled)

/obj/machinery/camera/PersistentInitialize()
	. = ..()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_XRAY)
		upgradeXRay()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_EMP_PROOF)
		upgradeEmpProof()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_MOTION)
		upgradeMotion()

// in game built cameras spawn deconstructed
/obj/machinery/camera/autoname/deconstructed/substitute_with_typepath(map_string)
	if(camera_construction_state != CAMERA_STATE_FINISHED)
		return FALSE

	var/cache_key = "[type]-[dir]"
	var/replacement_type = /obj/machinery/camera/autoname/directional
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/directional = ""
		switch(dir)
			if(NORTH)
				directional = "/north"
			if(SOUTH)
				directional = "/south"
			if(EAST)
				directional = "/east"
			if(WEST)
				directional = "/west"

		var/full_path = "[replacement_type][directional]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert [src] to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/camera/autoname/directional/typepath = cached_typepath
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, network, network)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, camera_upgrade_bitflags, camera_upgrade_bitflags)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, camera_enabled, camera_enabled)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, panel_open, panel_open)

		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	return cached_typepath

/obj/item/assembly/control/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, sync_doors)

/obj/machinery/button/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	// save the [/obj/item/assembly/control] inside the button that controls the id
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/machinery/button/PersistentInitialize()
	. = ..()
	var/obj/item/assembly/control/control_device = locate(/obj/item/assembly/control) in contents
	device = control_device
	setup_device()
	update_appearance()

/obj/machinery/conveyor_switch/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, conveyor_speed)
	. += NAMEOF(src, position)
	. += NAMEOF(src, oneway)

/obj/machinery/conveyor_switch/PersistentInitialize()
	. = ..()
	update_appearance()
	update_linked_conveyors()
	update_linked_switches()

/obj/machinery/conveyor/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, speed)

/obj/machinery/photocopier/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, paper_stack)

/// CHECK IF ID_TAGS ARE NEEDED FOR FIREDOOR/FIREALARMS
/obj/machinery/door/firedoor/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, id_tag)

/obj/machinery/firealarm/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, id_tag)

/obj/machinery/suit_storage_unit/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, density)
	. += NAMEOF(src, state_open)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, safeties)
	// ignore card reader stuff for now

/obj/machinery/suit_storage_unit/get_custom_save_vars(save_flags=ALL)
	. = ..()
	// since these aren't inside contents only save the typepaths
	if(suit)
		.[NAMEOF(src, suit_type)] = suit.type
	if(helmet)
		.[NAMEOF(src, helmet_type)] = helmet.type
	if(mask)
		.[NAMEOF(src, mask_type)] = mask.type
	if(mod)
		.[NAMEOF(src, mod_type)] = mod.type
	if(storage)
		.[NAMEOF(src, storage_type)] = storage.type

/obj/machinery/power/portagrav/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, on)
	. += NAMEOF(src, wire_mode)
	. += NAMEOF(src, grav_strength)
	. += NAMEOF(src, range)

/obj/machinery/power/portagrav/PersistentInitialize()
	. = ..()
	if(on)
		turn_on()

/obj/machinery/biogenerator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, biomass)
	. += NAMEOF(src, welded_down)

/obj/machinery/biogenerator/PersistentInitialize()
	. = ..()
	update_appearance()

/obj/machinery/mecha_part_fabricator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, drop_direction)

/obj/machinery/autolathe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, hacked)
	. += NAMEOF(src, disabled)
	. += NAMEOF(src, drop_direction)

/obj/machinery/plumbing/synthesizer/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, reagent_id)
	. += NAMEOF(src, amount)

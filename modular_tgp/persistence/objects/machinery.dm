/obj/machinery
	var/list/persistent_components

/obj/machinery/get_custom_save_vars(save_flags=ALL)
	. = ..()
	var/obj/item/circuitboard/machine/machine_circuit = circuit
	if(!istype(machine_circuit) || !length(machine_circuit.req_components))
		return
	LAZYCLEARLIST(persistent_components)

	var/list/comps_to_save
	for(var/datum/component as anything in component_parts)
		if(component == machine_circuit) continue

		var/as_path = component
		if(!ispath(component))
			as_path = component.type
		if(ispath(as_path, /obj/item/stack)) continue
		if(!persistence_valid_stockpart(as_path)) continue
		if(!isnull(machine_circuit.req_components[as_path])) continue // ignore already in req_components
		if(!ispath(as_path, /obj/item/stock_parts/power_store) && persistence_get_tier(component) == 1) continue //ignore T1

		if(ispath(as_path, /datum/stock_part))
			var/datum/stock_part/castpath = as_path
			as_path = initial(castpath.physical_object_type)
		LAZYADD(comps_to_save, as_path)

	if(LAZYLEN(comps_to_save))
		.[NAMEOF(src, persistent_components)] = comps_to_save


/obj/machinery/Initialize(mapload) // literally just copied RPED code
	. = ..()
	if(!LAZYLEN(persistent_components) || isnull(circuit))
		return
	var/obj/item/circuitboard/machine/machine_board = locate(/obj/item/circuitboard/machine) in component_parts
	if(isnull(machine_board))
		return

	var/list/part_list = list()
	for(var/path in persistent_components)
		part_list += new path()
	for(var/primary_part_base in component_parts)
		//we exchanged all we could time to bail
		if(!part_list.len)
			break

		var/required_type

		//we dont exchange circuitboards cause thats dumb
		if(istype(primary_part_base, /obj/item/circuitboard))
			continue
		else if(istype(primary_part_base, /datum/stock_part))
			var/datum/stock_part/primary_stock_part = primary_part_base
			required_type = primary_stock_part.physical_object_base_type
		else
			var/obj/item/primary_stock_part_item = primary_part_base
			for(var/design_type in machine_board.req_components)
				if(!ispath(primary_stock_part_item.type, design_type)) continue
				required_type = design_type
				break

		for(var/obj/item/secondary_part in part_list)
			if(!istype(secondary_part, required_type))
				continue
			if (istype(primary_part_base, /datum/stock_part))
				var/stock_part_datum = GLOB.stock_part_datums_per_object[secondary_part.type]
				if (isnull(stock_part_datum))
					CRASH("[secondary_part] ([secondary_part.type]) did not have a stock part datum (was trying to find [primary_part_base])")
				component_parts += stock_part_datum
				part_list -= secondary_part //have to manually remove cause we are no longer refering replacer_tool.contents
				qdel(secondary_part)
			else
				component_parts += secondary_part
				secondary_part.forceMove(src)
				part_list -= secondary_part //have to manually remove cause we are no longer refering replacer_tool.contents

			component_parts -= primary_part_base
			if (!istype(primary_part_base, /datum/stock_part))
				qdel(primary_part_base)
			break

	RefreshParts()
	LAZYNULL(persistent_components) // free memory

/obj/machinery/proc/persistence_valid_stockpart(datum/part)
	if(!ispath(part))
		part = part.type
	return ispath(part, /datum/stock_part) || ispath(part, /obj/item/stock_parts)


/obj/machinery/proc/persistence_get_tier(datum/part)
	if(!ispath(part))
		part = part.type
	if(!persistence_valid_stockpart(part)) return null
	var/datum/stock_part/as_datum = part
	var/obj/item/stock_parts/as_item = part
	return istype(as_datum) ? initial(as_datum.tier) : initial(as_item.rating)

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

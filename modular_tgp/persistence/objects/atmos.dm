// Don't forget to look into other atmos subtypes for variables to save and initialize
// knock it out now before it gets forgotten in the future
/obj/machinery/meter/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_layer)
	return .

/obj/machinery/atmospherics/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	. += NAMEOF(src, on)
	. += NAMEOF(src, vent_movement)

	. -= NAMEOF(src, id_tag)
	return .

/obj/machinery/atmospherics/pipe
	var/persistence_pipe_id

/obj/machinery/atmospherics/pipe/smart/substitute_with_typepath(map_string)
	var/base_type = /obj/machinery/atmospherics/pipe/smart/manifold4w
	var/is_hidden = HAS_TRAIT(src, TRAIT_UNDERFLOOR)
	var/cache_key = "[base_type]-[pipe_color]-[is_hidden]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/color_path = ""
		switch(pipe_color)
			if(COLOR_YELLOW)
				color_path = "/yellow"
			if(ATMOS_COLOR_OMNI)
				color_path = "/general"
			if(COLOR_CYAN)
				color_path = "/cyan"
			if(COLOR_VIBRANT_LIME)
				color_path = "/green"
			if(COLOR_ENGINEERING_ORANGE)
				color_path = "/orange"
			if(COLOR_PURPLE)
				color_path = "/purple"
			if(COLOR_DARK)
				color_path = "/dark"
			if(COLOR_BROWN)
				color_path = "/brown"
			if(COLOR_STRONG_VIOLET)
				color_path = "/violet"
			if(COLOR_LIGHT_PINK)
				color_path = "/pink"
			if(COLOR_RED)
				color_path = "/scrubbers"
			if(COLOR_BLUE)
				color_path = "/supply"
			else
				color_path = "/general"

		var/visible_path = is_hidden ? "/hidden" : "/visible"

		var/layer_path = ""
		if(piping_layer != 3)
			layer_path = "/layer[piping_layer]"

		var/full_path = "[base_type][color_path][visible_path][layer_path]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert pipe to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	. = cached_typepath // set return
	if(!cached_typepath) //does this even matter if it fails?
		return

	var/obj/machinery/atmospherics/pipe/smart/manifold4w/typepath = cached_typepath
	var/list/variables = list()

	if(parent?.members[1] == src && !isnull(parent.air))
		var/new_id = assign_random_name(12, "persistencegas_")
		TGM_ADD_TYPEPATH_VAR(variables, typepath, persistence_pipe_id, new_id) //assign id to pipe

		var/list/helper_variables = list() //variables for gas mix helper

		TGM_ADD_STATIC_TYPEPATH_VAR(helper_variables, /obj/effect/mapping_helpers/pipe_gas, gas_mix, parent.air.to_string())
		TGM_ADD_STATIC_TYPEPATH_VAR(helper_variables, /obj/effect/mapping_helpers/pipe_gas, id_filter, new_id)
		TGM_MAP_BLOCK(map_string, /obj/effect/mapping_helpers/pipe_gas, generate_tgm_typepath_metadata(helper_variables))

	TGM_MAP_BLOCK(map_string, typepath, length(variables) ? generate_tgm_typepath_metadata(variables) : null)


// these spawn underneath cryo machines and will duplicate after every save
/obj/machinery/atmospherics/components/unary/is_saveable(turf/current_loc, list/obj_blacklist)
	if(locate(/obj/machinery/cryo_cell) in loc)
		return FALSE

	return ..()

/obj/machinery/atmospherics/components/unary/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, welded)
	return .

/obj/machinery/atmospherics/components/unary/vent_pump/substitute_with_typepath(map_string)
	var/base_type
	if(istype(src, /obj/machinery/atmospherics/components/unary/vent_pump/high_volume))
		base_type = /obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	else
		base_type = /obj/machinery/atmospherics/components/unary/vent_pump

	var/cache_key = "[base_type]-[on]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/on_path = on ? "/on" : ""

		var/layer_path = ""
		if(piping_layer != 3)
			layer_path = "/layer[piping_layer]"

		var/full_path = "[base_type][on_path][layer_path]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert vent scrubber to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/atmospherics/components/unary/vent_pump/typepath = cached_typepath
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, dir)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, welded, welded)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, pump_direction, pump_direction)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, pressure_checks, pressure_checks)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, internal_pressure_bound, internal_pressure_bound)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, external_pressure_bound, external_pressure_bound)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, fan_overclocked, fan_overclocked)

		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	return cached_typepath

/obj/machinery/atmospherics/components/unary/vent_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, pump_direction)
	. += NAMEOF(src, pressure_checks)
	. += NAMEOF(src, internal_pressure_bound)
	. += NAMEOF(src, external_pressure_bound)
	. += NAMEOF(src, fan_overclocked)
	return .

/obj/machinery/atmospherics/components/unary/vent_scrubber/substitute_with_typepath(map_string)
	var/base_type = /obj/machinery/atmospherics/components/unary/vent_scrubber
	var/cache_key = "[base_type]-[on]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/on_path = on ? "/on" : ""

		var/layer_path = ""
		if(piping_layer != 3)
			layer_path = "/layer[piping_layer]"

		var/full_path = "[base_type][on_path][layer_path]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert vent scrubber to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/atmospherics/components/unary/vent_scrubber/typepath = cached_typepath
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, dir)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, welded, welded)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, scrubbing, scrubbing)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, filter_types, filter_types)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, widenet, widenet)

		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	return cached_typepath

/obj/machinery/atmospherics/components/unary/vent_scrubber/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, scrubbing)
	. += NAMEOF(src, filter_types)
	. += NAMEOF(src, widenet)
	return .

/obj/machinery/atmospherics/components/unary/vent_scrubber/PersistentInitialize()
	. = ..()
	if(widenet)
		set_widenet(widenet)

/obj/machinery/atmospherics/components/unary/thermomachine/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_temperature)
	return .

/obj/machinery/atmospherics/components/trinary/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, flipped)
	return .

/obj/machinery/atmospherics/components/trinary/filter/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, transfer_rate)
	. += NAMEOF(src, filter_type)
	return .

/obj/machinery/atmospherics/components/trinary/mixer/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)
	. += NAMEOF(src, node1_concentration)
	. += NAMEOF(src, node2_concentration)
	return .

/obj/machinery/atmospherics/components/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, welded)

	if(override_naming)
		. += NAMEOF(src, name)
	return .

/obj/item/pipe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	return .

/obj/machinery/portable_atmospherics/canister/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, valve_open)
	. += NAMEOF(src, release_pressure)
	. += NAMEOF(src, name)
	. += NAMEOF(src, desc)
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, base_icon_state)
	. += NAMEOF(src, greyscale_colors)
	. += NAMEOF(src, greyscale_config)
	return .

/obj/machinery/portable_atmospherics/get_custom_save_vars(save_flags=ALL)
	. = ..()
	var/datum/gas_mixture/gasmix = air_contents
	.[NAMEOF(src, initial_gas_mix)] = gasmix.to_string()
	return .

/obj/machinery/portable_atmospherics/PersistentInitialize()
	. = ..()
	if((greyscale_colors != initial(greyscale_colors)) || (greyscale_config != initial(greyscale_config)))
		set_greyscale(greyscale_colors, greyscale_config)

	if(!anchored)
		return

	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(!possible_port)
		return

	connect(possible_port)
	update_appearance()

/obj/machinery/atmospherics/components/binary/volume_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, transfer_rate)
	. += NAMEOF(src, overclocked)

/obj/machinery/atmospherics/components/binary/pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/binary/temperature_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, heat_transfer_rate)

/obj/machinery/atmospherics/components/binary/temperature_gate/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_temperature)
	. += NAMEOF(src, inverted)

/obj/machinery/atmospherics/components/binary/pressure_valve/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/binary/passive_gate/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/binary/dp_vent_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, pump_direction)
	. += NAMEOF(src, external_pressure_bound)
	. += NAMEOF(src, input_pressure_min)
	. += NAMEOF(src, output_pressure_max)
	. += NAMEOF(src, pressure_checks)

/obj/machinery/atmospherics/components/binary/circulator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, active)
	. += NAMEOF(src, flipped)
	. += NAMEOF(src, mode)

/obj/machinery/atmospherics/components/unary/outlet_injector/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, volume_rate)

/obj/effect/mapping_helpers/pipe_gas
	name = "Pipe Gasmix Setter"
	icon_state = ""
	late = TRUE
	var/gas_mix = OPENTURF_DEFAULT_ATMOS
	/// Target pipe layer (ignored with id_filter)
	var/pipe_layer = PIPING_LAYER_DEFAULT
	/// Optionally just use ID instead (must be on top still)
	var/id_filter

/obj/effect/mapping_helpers/pipe_gas/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL

	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/pipe_gas/LateInitialize()
	var/obj/machinery/atmospherics/pipe/pipe
	for(var/obj/machinery/atmospherics/pipe/potential_pipe in loc)
		if(!isnull(id_filter) && potential_pipe.id_tag != id_filter && potential_pipe.persistence_pipe_id != id_filter) continue
		if(isnull(id_filter) && potential_pipe.piping_layer != pipe_layer) continue
		pipe = potential_pipe
		break

	if(isnull(pipe))
		log_mapping("[type] at [AREACOORD(src)] did not find any pipe to set gas mix of")
		qdel(src)
		return

	var/datum/gas_mixture/gasmix = SSair.parse_gas_string(gas_mix, /datum/gas_mixture)
	if(!isnull(pipe.parent))
		pipe.parent.air.copy_from(gasmix)
	else
		pipe.air_temporary = gasmix

	pipe.persistence_pipe_id = null

	qdel(src)

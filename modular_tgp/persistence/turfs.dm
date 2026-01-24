/turf/open/floor
	var/persistent_decals

/datum/element/decal/Attach(atom/target, _icon, _icon_state, _dir, _plane=FLOAT_PLANE, _layer=FLOAT_LAYER, _alpha=255, _color, _smoothing, _cleanable=FALSE, _description, mutable_appearance/_pic)
	. = ..()
	var/turf/open/floor/as_floor = target
	//Ignore not normal floors, or decals that arent the same icons as /obj/effect/turf_decal oones
	if(. == ELEMENT_INCOMPATIBLE || !istype(as_floor) || _icon != /obj/effect/turf_decal::icon)
		return
	LAZYADD(as_floor.persistent_decals, list(list(icon_state = _icon_state, dir = _dir, color = _color, alpha = _alpha)))

/turf/open/floor/on_object_saved(map_string, turf/current_loc)
	if(!LAZYLEN(persistent_decals))
		return FALSE
	for(var/list/decal as anything in persistent_decals)
		var/list/variables = list()
		var/obj/effect/turf_decal/typepath = /obj/effect/turf_decal // byond oh my god bruh
		TGM_ADD_TYPEPATH_VAR(variables, typepath, icon_state, decal["icon_state"])
		TGM_ADD_TYPEPATH_VAR(variables, typepath, alpha, decal["alpha"])
		TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, decal["dir"])
		TGM_ADD_TYPEPATH_VAR(variables, typepath, color, decal["color"])
		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

/turf/open/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, broken)
	. += NAMEOF(src, burnt)
	return .

/turf/open/PersistentInitialize()
	. = ..()
	if(broken || burnt)
		update_appearance()

// Save atmos data
/turf/open/get_custom_save_vars(save_flags=ALL)
	. = ..()

	if(!(save_flags & SAVE_TURFS_ATMOS))
		return .

	// is_safe_turf checks if the temperature, gas mix, pressure is in the goldilock safe zones
	// if it is safe, we skip saving atmos and use the default to help compress our map save size
	if(!is_safe_turf(src, dense_atoms=TRUE)) // compare optimization times in tracy with this check enabled vs without
		var/datum/gas_mixture/turf_gasmix = return_air()
		.[NAMEOF(src, initial_gas_mix)] = turf_gasmix.to_string()
	return .

/turf/open/floor/light/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, on)
	. += NAMEOF(src, state)
	. += NAMEOF(src, currentcolor)
	return .

/turf/open/floor/light/PersistentInitialize()
	. = ..()
	update_appearance()

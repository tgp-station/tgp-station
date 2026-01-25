/obj/item/disk/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, read_only)
	. += NAMEOF(src, sticker_icon_state)

/obj/item/disk/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, custom_description)] = copytext(custom_description, 1, min(30, length(custom_description))) //max 30 bytes len

/obj/item/disk/tech_disk
	var/list/persistence_unlocked_nodes

/obj/item/disk/tech_disk/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(!length(stored_research.researched_nodes))
		return
	var/list/research = list()
	for(var/node in stored_research.researched_nodes)
		research += node
	.[NAMEOF(src, persistence_unlocked_nodes)] = research

/obj/item/disk/tech_disk/PersistentInitialize()
	. = ..()
	if(!LAZYLEN(persistence_unlocked_nodes))
		return
	for(var/node in persistence_unlocked_nodes)
		stored_research.research_node_id(node, TRUE, FALSE, FALSE)
	persistence_unlocked_nodes = null

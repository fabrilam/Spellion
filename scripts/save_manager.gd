extends Node

const SAVE_PATH := "user://save_spellion.json"

func save_game() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return

	var data := {}

	# Player position
	data["player_pos"] = {
		"x": player.global_position.x,
		"y": player.global_position.y,
		"z": player.global_position.z,
	}

	# Stats
	var stats: Stats = player.stats if "stats" in player else null
	if stats:
		data["stats"] = {
			"strength": stats.strength,
			"agility": stats.agility,
			"intelligence": stats.intelligence,
			"vitality": stats.vitality,
			"hp": stats.hp,
			"mana": stats.mana,
			"level": stats.level,
			"xp": stats.xp,
			"xp_to_next": stats.xp_to_next,
			"unspent_points": stats.unspent_points,
		}

	# Inventory items (with grid position)
	if player.has_method("get_inventory"):
		var inv: Inventory = player.get_inventory()
		var items_data := []
		var seen := []
		for y in Inventory.GRID_ROWS:
			for x in Inventory.GRID_COLS:
				var item: Item = inv.get_at(x, y)
				if item and not seen.has(item):
					seen.append(item)
					items_data.append({
						"x": x,
						"y": y,
						"id": item.id,
						"name": item.name,
						"category": item.category,
						"desc": item.description,
						"texture_path": item.texture_path,
						"scene_path": item.scene_path,
						"grid_width": item.grid_width,
						"grid_height": item.grid_height,
						"str_scale_min": item.str_scale_min,
						"str_scale_max": item.str_scale_max,
						"dex_scale_min": item.dex_scale_min,
						"dex_scale_max": item.dex_scale_max,
						"stats": item.stats.duplicate(),
					})
		data["inventory_grid"] = items_data

		# Equipped items
		var equip_data := {}
		for eslot in Inventory.EquipSlot.values():
			if eslot < 0:
				continue
			var item: Item = inv.get_equipped(eslot)
			if item:
				equip_data[str(eslot)] = {
					"id": item.id,
					"name": item.name,
					"category": item.category,
					"desc": item.description,
					"texture_path": item.texture_path,
					"scene_path": item.scene_path,
					"grid_width": item.grid_width,
					"grid_height": item.grid_height,
					"str_scale_min": item.str_scale_min,
					"str_scale_max": item.str_scale_max,
					"dex_scale_min": item.dex_scale_min,
					"dex_scale_max": item.dex_scale_max,
					"stats": item.stats.duplicate(),
				}
		data["equipped"] = equip_data

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.new().stringify(data, "\t"))
		print("Game saved to ", SAVE_PATH)

func load_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("No save file found")
		return false

	var text := file.get_as_text()
	var json := JSON.new()
	if json.parse(text) != OK:
		print("Failed to parse save file")
		return false

	var data: Dictionary = json.data

	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return false

	# Player position
	if data.has("player_pos"):
		var p: Dictionary = data["player_pos"]
		player.global_position = Vector3(p.x, p.y, p.z)

	# Stats
	var stats: Stats = player.stats if "stats" in player else null
	if stats and data.has("stats"):
		var sd: Dictionary = data["stats"]
		stats.strength = sd.get("strength", 3)
		stats.agility = sd.get("agility", 3)
		stats.intelligence = sd.get("intelligence", 3)
		stats.vitality = sd.get("vitality", 3)
		stats.hp = sd.get("hp", 110.0)
		stats.mana = sd.get("mana", 30.0)
		stats.level = sd.get("level", 1)
		stats.xp = sd.get("xp", 0.0)
		stats.xp_to_next = sd.get("xp_to_next", 50.0)
		stats.unspent_points = sd.get("unspent_points", 0)

	# Inventory
	if player.has_method("get_inventory"):
		var inv: Inventory = player.get_inventory()
		_clear_inventory(inv)

		# Restore grid items
		if data.has("inventory_grid"):
			for idata in data["inventory_grid"]:
				var item := _item_from_data(idata)
				if not inv._place(item, idata.x, idata.y):
					inv.add_item(item)

		# Restore equipped items
		if data.has("equipped"):
			for eslot_str in data["equipped"]:
				var eslot := int(eslot_str)
				var idata: Dictionary = data["equipped"][eslot_str]
				var item := _item_from_data(idata)
				inv.equip(item, eslot)

		player.call("_apply_equip_stats") if player.has_method("_apply_equip_stats") else null
		player.call("_update_weapon_visibility") if player.has_method("_update_weapon_visibility") else null

	print("Game loaded from ", SAVE_PATH)
	return true

func _clear_inventory(inv: Inventory) -> void:
	for y in Inventory.GRID_ROWS:
		for x in Inventory.GRID_COLS:
			inv.remove_at(x, y)
	for eslot in Inventory.EquipSlot.values():
		if eslot >= 0:
			inv.unequip(eslot)

func _item_from_data(d: Dictionary) -> Item:
	var item := Item.new()
	item.id = d.get("id", "")
	item.name = d.get("name", "Unknown")
	item.category = d.get("category", "Misc")
	item.description = d.get("desc", "")
	item.texture_path = d.get("texture_path", "")
	item.scene_path = d.get("scene_path", "")
	item.grid_width = d.get("grid_width", 1)
	item.grid_height = d.get("grid_height", 1)
	item.str_scale_min = d.get("str_scale_min", 0.15)
	item.str_scale_max = d.get("str_scale_max", 0.3)
	item.dex_scale_min = d.get("dex_scale_min", 0.0)
	item.dex_scale_max = d.get("dex_scale_max", 0.0)
	item.stats = d.get("stats", {}).duplicate()
	return item

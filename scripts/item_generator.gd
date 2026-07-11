extends Node
class_name ItemGenerator

static var _effects: Array[Dictionary] = []

static func _load_effects() -> void:
	if not _effects.is_empty():
		return
	var f := FileAccess.open("res://assets/textures/items/_magic_effects.json", FileAccess.READ)
	if f:
		var parsed = JSON.parse_string(f.get_as_text())
		if parsed is Array:
			_effects.clear()
			for entry in parsed:
				_effects.append(entry as Dictionary)

static func get_effects_for(tags: Array[String]) -> Array[Dictionary]:
	_load_effects()
	var result: Array[Dictionary] = []
	for e in _effects:
		var etags: Array = e.get("tags", [])
		for tag in tags:
			if tag in etags:
				result.append(e)
				break
	return result

static func pick(effects_pool: Array[Dictionary], exclude: Array[String] = []) -> Dictionary:
	var pool: Array[Dictionary] = []
	for e in effects_pool:
		if not e.get("id", "") in exclude:
			pool.append(e)
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()]

static func roll_val(e: Dictionary, level: int) -> float:
	var min_val: float = e.get("min_val", 0)
	var max_val: float = e.get("max_val", 1)
	var step: float = e.get("step", 1)
	var scaled_min := min_val + level * 0.1 * max_val
	var scaled_max := max_val + level * 0.15 * max_val
	var raw := randf_range(scaled_min, scaled_max)
	return snapped(raw, step)

static func generate(base: Item, rarity: String, level: int) -> Item:
	var copy: Item = base.duplicate()
	copy.rarity = rarity

	var tags := _category_tags(copy.category)
	var pool := get_effects_for(tags)
	if pool.is_empty():
		return copy

	var used_ids: Array[String] = []
	var prefix_id := ""
	var suffix_id := ""

	if rarity == "magic":
		var has_prefix := randf() < 0.6
		var has_suffix := randf() < 0.6
		if not has_prefix and not has_suffix:
			if randf() < 0.5:
				has_prefix = true
			else:
				has_suffix = true
		if has_prefix:
			var pe := pick(pool)
			if pe:
				prefix_id = pe.get("id", "")
				used_ids.append(prefix_id)
				_apply_effect(copy, pe, roll_val(pe, level), false)
		if has_suffix:
			var se := pick(pool, used_ids)
			if se:
				suffix_id = se.get("id", "")
				used_ids.append(suffix_id)
				_apply_effect(copy, se, roll_val(se, level), false)
		copy.name = _build_name(base.name, prefix_id, suffix_id)
		return copy

	if rarity == "rare":
		var pe := pick(pool)
		if pe:
			prefix_id = pe.get("id", "")
			used_ids.append(prefix_id)
			_apply_effect(copy, pe, roll_val(pe, level), false)
		var se := pick(pool, used_ids)
		if se:
			suffix_id = se.get("id", "")
			used_ids.append(suffix_id)
			_apply_effect(copy, se, roll_val(se, level), false)
		var extra_count := randi_range(1, 3)
		for _i in extra_count:
			var ee := pick(pool, used_ids)
			if ee.is_empty():
				break
			used_ids.append(ee.get("id", ""))
			_apply_effect(copy, ee, roll_val(ee, level) * 0.7, true)
		copy.name = _build_name(base.name, prefix_id, suffix_id)
		return copy

	return copy

static func _apply_effect(item: Item, e: Dictionary, val: float, is_extra: bool) -> void:
	var effect_dict := {
		"type": e.get("id", ""),
		"name": e.get("name", ""),
		"val": val,
		"extra": is_extra,
	}
	item.effects.append(effect_dict)
	item.stats[e.get("id", "")] = val

static func _build_name(base_name: String, prefix_id: String, suffix_id: String) -> String:
	var prefix_name := ""
	var suffix_name := ""
	if not prefix_id.is_empty():
		for e in _effects:
			if e.get("id") == prefix_id:
				prefix_name = e.get("prefix", "")
				break
	if not suffix_id.is_empty():
		for e in _effects:
			if e.get("id") == suffix_id:
				suffix_name = e.get("suffix", "")
				break
	var name := base_name
	if not prefix_name.is_empty():
		name = prefix_name + " " + name
	if not suffix_name.is_empty():
		name = name + " " + suffix_name
	return name

static func _category_tags(cat: String) -> Array[String]:
	match cat:
		"Sword", "Axe", "Mace", "Dagger":
			return ["weapon"]
		"Bow":
			return ["weapon", "bow"]
		"Armor":
			return ["armor"]
		"Headgear":
			return ["headgear"]
		"Shield":
			return ["shield"]
		"Ring":
			return ["ring"]
		"Amulet":
			return ["amulet"]
		_:
			return []

extends CanvasLayer

@onready var str_value := $Panel/Margin/VBox/StrRow/StrValue
@onready var agi_value := $Panel/Margin/VBox/AgiRow/AgiValue
@onready var int_value := $Panel/Margin/VBox/IntRow/IntValue
@onready var vit_value := $Panel/Margin/VBox/VitRow/VitValue
@onready var points_label := $Panel/Margin/VBox/PointsLabel
@onready var level_label := $Panel/Margin/VBox/LevelLabel
@onready var hp_value := $Panel/Margin/VBox/HPRow/HPValue
@onready var mp_value := $Panel/Margin/VBox/MPRow/MPValue
@onready var melee_dmg_value := $Panel/Margin/VBox/MeleeDmgRow/MeleeDmgValue
@onready var spell_dmg_value := $Panel/Margin/VBox/SpellDmgRow/SpellDmgValue
@onready var speed_value := $Panel/Margin/VBox/SpeedRow/SpeedValue
@onready var crit_value := $Panel/Margin/VBox/CritRow/CritValue
@onready var def_value := $Panel/Margin/VBox/DefRow/DefValue
@onready var spawn_btn := $Panel/Margin/VBox/SpawnBtn
@onready var atk_spd_value := $Panel/Margin/VBox/AtkSpdRow/AtkSpdValue
@onready var hp_regen_value := $Panel/Margin/VBox/HpRegenRow/HpRegenValue
@onready var mp_regen_value := $Panel/Margin/VBox/MpRegenRow/MpRegenValue

@onready var str_plus := $Panel/Margin/VBox/StrRow/StrPlus
@onready var agi_plus := $Panel/Margin/VBox/AgiRow/AgiPlus
@onready var int_plus := $Panel/Margin/VBox/IntRow/IntPlus
@onready var vit_plus := $Panel/Margin/VBox/VitRow/VitPlus

var _stats: Stats

func _ready() -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		if "stats" in p:
			_stats = p.stats
		if p.has_method("get_inventory"):
			var inv: Inventory = p.get_inventory()
			if inv:
				inv.item_equipped.connect(_on_inv_change)
				inv.item_unequipped.connect(_on_inv_change)
	_apply_bar_mode()
	visible = false
	str_plus.pressed.connect(_on_str_plus)
	agi_plus.pressed.connect(_on_agi_plus)
	int_plus.pressed.connect(_on_int_plus)
	vit_plus.pressed.connect(_on_vit_plus)
	$Panel/Margin/VBox/SaveRow/SaveBtn.pressed.connect(_on_save)
	$Panel/Margin/VBox/SaveRow/LoadBtn.pressed.connect(_on_load)
	$Panel/Margin/VBox/BarModeBtn.pressed.connect(_on_toggle_bar_mode)
	spawn_btn.pressed.connect(_on_spawn_items)
	$Panel/Margin/VBox/SpawnGenBtn.pressed.connect(_on_spawn_generated)

func _on_save() -> void:
	SaveManager.save_game()

func _on_load() -> void:
	SaveManager.load_game()

func _on_inv_change(_a = null, _b = null) -> void:
	if visible and _stats:
		refresh()

func _on_str_plus() -> void:
	if _stats and _stats.unspent_points > 0:
		_stats.allocate_point("str")
		AudioManager.play_sfx_channel4("ui_click")
		refresh()

func _on_agi_plus() -> void:
	if _stats and _stats.unspent_points > 0:
		_stats.allocate_point("agi")
		AudioManager.play_sfx_channel4("ui_click")
		refresh()

func _on_int_plus() -> void:
	if _stats and _stats.unspent_points > 0:
		_stats.allocate_point("int")
		AudioManager.play_sfx_channel4("ui_click")
		refresh()

func _on_vit_plus() -> void:
	if _stats and _stats.unspent_points > 0:
		_stats.allocate_point("vit")
		AudioManager.play_sfx_channel4("ui_click")
		refresh()

func toggle() -> void:
	visible = not visible
	if visible:
		if not _stats:
			var p := get_tree().get_first_node_in_group("player")
			if p and "stats" in p:
				_stats = p.stats
		if _stats:
			refresh()

func refresh() -> void:
	if not _stats: return
	str_value.text = str(_stats.strength)
	agi_value.text = str(_stats.agility)
	int_value.text = str(_stats.intelligence)
	vit_value.text = str(_stats.vitality)
	level_label.text = "Level %d" % _stats.level
	points_label.text = "Unspent: %d" % _stats.unspent_points
	hp_value.text = "%d" % _stats.get_max_hp_cached()
	mp_value.text = "%d" % _stats.get_max_mana_cached()
	var dmg_min := _stats.get_melee_damage_min()
	var dmg_max := _stats.get_melee_damage_max()
	melee_dmg_value.text = "%d-%d" % [dmg_min, dmg_max]
	spell_dmg_value.text = "%d" % _stats.get_spell_damage()
	speed_value.text = "%.1f" % _stats.get_speed()
	atk_spd_value.text = "%.2f" % _stats.get_attack_speed()
	crit_value.text = "%d%%" % (_stats.get_crit_chance() * 100)
	def_value.text = "%d" % _stats.get_defense()
	hp_regen_value.text = "%.1f/s" % _stats.get_hp_regen()
	mp_regen_value.text = "%.1f/s" % _stats.get_mana_regen()
	var has_pts := _stats.unspent_points > 0
	str_plus.disabled = not has_pts
	agi_plus.disabled = not has_pts
	int_plus.disabled = not has_pts
	vit_plus.disabled = not has_pts
	$Panel/Margin/VBox/BarModeBtn.text = "HP Bars: Hover" if _get_bar_mode() == "hover" else "HP Bars: Panel"

func _get_bar_mode() -> String:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		return p.get_meta("hp_bar_mode", "panel")
	return "panel"

func _set_bar_mode(mode: String) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		p.set_meta("hp_bar_mode", mode)

func _apply_bar_mode() -> void:
	var mode := _get_bar_mode()
	var hover := get_tree().root.find_child("EnemyHPBars", true, false)
	var panel := get_tree().root.find_child("EnemyHPPanel", true, false)
	if hover:
		hover.visible = (mode == "hover")
	if panel:
		panel.visible = (mode == "panel")

func _on_toggle_bar_mode() -> void:
	var mode := "hover" if _get_bar_mode() == "panel" else "panel"
	_set_bar_mode(mode)
	_apply_bar_mode()
	AudioManager.play_sfx_channel4("ui_click")

func _on_spawn_items() -> void:
	var p := get_tree().get_first_node_in_group("player")
	if not p or not p.has_method("get_inventory"):
		return
	var pickup_scene := preload("res://scenes/fx/item_pickup.tscn")
	var f := FileAccess.open("res://assets/textures/items/_item_data.json", FileAccess.READ)
	if not f:
		return
	var data: Array = JSON.parse_string(f.get_as_text()) as Array
	if not data:
		return
	var idx := 0
	for entry in data:
		var item := Item.from_dict(entry)
		var world := pickup_scene.instantiate()
		world.call("init", item)
		get_tree().current_scene.add_child(world)
		var angle := idx * 0.4
		var dist := 3.0 + idx * 0.15
		var ground_y := -0.49 if p.global_position.z <= 0.0 else 0.2
		world.global_position = Vector3(
			p.global_position.x + cos(angle) * dist,
			ground_y,
			p.global_position.z + sin(angle) * dist
		)
		idx += 1
	AudioManager.play_sfx_channel4("ui_click")

func _on_spawn_generated() -> void:
	var p := get_tree().get_first_node_in_group("player")
	if not p or not p.has_method("get_inventory"):
		return
	var f := FileAccess.open("res://assets/textures/items/_item_data.json", FileAccess.READ)
	if not f:
		return
	var data: Array = JSON.parse_string(f.get_as_text()) as Array
	if not data:
		return
	var pool: Array[Dictionary] = []
	for entry in data:
		if entry.get("rarity") == "common" and entry.get("cat", "") in ["Sword", "Axe", "Mace", "Bow", "Dagger", "Armor", "Headgear", "Shield", "Ring", "Amulet"]:
			pool.append(entry)
	if pool.is_empty():
		return
	var entry: Dictionary = pool[randi() % pool.size()]
	var base := Item.from_dict(entry)
	if not base:
		return
	var dungeon_lv: int = 1
	var dgn := get_tree().root.find_child("Dungeon", true, false)
	if dgn and dgn.has_method("get_dungeon_level"):
		dungeon_lv = dgn.call("get_dungeon_level")
	var rarity := "magic" if randf() < 0.75 else "rare"
	var gen := ItemGenerator.generate(base, rarity, dungeon_lv)
	var pickup_scene := preload("res://scenes/fx/item_pickup.tscn")
	var world := pickup_scene.instantiate()
	world.call("init", gen)
	get_tree().current_scene.add_child(world)
	var angle := randf() * TAU
	var dist := 2.0 + randf() * 1.0
	var ground_y := -0.49 if p.global_position.z <= 0.0 else 0.2
	world.global_position = Vector3(
		p.global_position.x + cos(angle) * dist,
		ground_y,
		p.global_position.z + sin(angle) * dist
	)
	AudioManager.play_sfx_channel4("ui_click")

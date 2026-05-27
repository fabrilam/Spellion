extends CanvasLayer

@onready var hp_fill := $HPBar/HPFill
@onready var mp_fill := $MPBar/MPFill
@onready var xp_fill := $XPBar/XPFill
@onready var hp_label := $HPBar/HPLabel
@onready var mp_label := $MPBar/MPLabel
@onready var xp_label := $XPBar/XPLabel
@onready var dungeon_label := $DungeonLevel
@onready var spell_icon := $SpellSlot/SpellIcon
@onready var spell_label := $SpellSlot/SpellLabel
@onready var spell_menu := $SpellMenu
@onready var spell_options := $SpellMenu/SpellOptions

var _stats: Stats
var _player: Node = null
var _dungeon_level: int = 1
var _spell_option_nodes: Array = []

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if _player and _player.has_method("get_stats"):
		_stats = _player.get_stats()
	elif _player:
		_stats = _player.stats if "stats" in _player else null
	if _stats:
		_stats.hp_changed.connect(_update_hp)
		_stats.mana_changed.connect(_update_mp)
		_stats.xp_changed.connect(_update_xp)
		_stats.level_changed.connect(_update_level)
		_update_hp(_stats.hp, _stats.get_max_hp())
		_update_mp(_stats.mana, _stats.get_max_mana())
		_update_xp(_stats.xp, _stats.xp_to_next)
		_update_level(_stats.level)

	if _player and _player.has_signal("spell_changed"):
		_player.spell_changed.connect(_on_spell_changed)
		_update_spell_slot()

	# Load button textures
	var inv_tex = load("res://assets/textures/ui/icon_inventory.svg")
	if inv_tex:
		$BtnInventory/Icon.texture = inv_tex
	var stats_tex = load("res://assets/textures/ui/icon_stats.svg")
	if stats_tex:
		$BtnStats/Icon.texture = stats_tex

	# Connect menu buttons
	$SpellSlot.gui_input.connect(_on_spell_slot_click)
	$BtnInventory.gui_input.connect(_on_btn_inventory)
	$BtnStats.gui_input.connect(_on_btn_stats)

	# Connect to dungeon level changes
	_update_dungeon_level()

func _update_dungeon_level() -> void:
	var dungeon := get_tree().root.find_child("Dungeon", true, false)
	if dungeon and "_dungeon_level" in dungeon:
		_dungeon_level = dungeon._dungeon_level
	dungeon_label.text = "Dungeon Lv.%d" % _dungeon_level

	if _player and _player.has_signal("goal_reached"):
		_player.goal_reached.disconnect(_on_dungeon_goal)
	var dungeon2 := get_tree().root.find_child("Dungeon", true, false)
	if dungeon2:
		if dungeon2.has_signal("goal_reached") and not dungeon2.goal_reached.is_connected(_on_dungeon_goal):
			dungeon2.goal_reached.connect(_on_dungeon_goal)
		if dungeon2.has_signal("dungeon_regenerating") and not dungeon2.dungeon_regenerating.is_connected(_on_dungeon_regenerate):
			dungeon2.dungeon_regenerating.connect(_on_dungeon_regenerate)

func _on_dungeon_goal(level: int) -> void:
	_dungeon_level = level + 1
	dungeon_label.text = "Dungeon Lv.%d" % _dungeon_level

func _on_dungeon_regenerate() -> void:
	_update_dungeon_level()

func _update_hp(hp: float, max_hp: float) -> void:
	var p := hp / max_hp if max_hp > 0 else 0.0
	hp_fill.size.x = 198.0 * p
	hp_label.text = "HP: %d/%d" % [ceil(hp), max_hp]

func _update_mp(mp: float, max_mp: float) -> void:
	var p := mp / max_mp if max_mp > 0 else 0.0
	mp_fill.size.x = 198.0 * p
	mp_label.text = "MP: %d/%d" % [ceil(mp), max_mp]

func _update_xp(xp: float, xp_to_next: float) -> void:
	var p := xp / xp_to_next if xp_to_next > 0 else 0.0
	xp_fill.size.x = 198.0 * p
	xp_label.text = "Lv.%d | XP: %d/%d" % [_stats.level, ceil(xp), xp_to_next]

func _update_level(level: int) -> void:
	if xp_fill:
		_update_xp(_stats.xp, _stats.xp_to_next)

func _on_spell_changed(idx: int) -> void:
	_update_spell_slot()

func _update_spell_slot() -> void:
	if not _player or not _player.has_method("get_current_spell"):
		return
	var spell = _player.get_current_spell()
	if not spell:
		spell_icon.texture = null
		spell_label.text = ""
		return
	var tex = load(spell.icon_path) if spell.icon_path else null
	spell_icon.texture = tex
	spell_label.text = spell.name + " [Q]"

func _on_spell_slot_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_spell_menu()

func toggle_spell_menu() -> void:
	spell_menu.visible = not spell_menu.visible
	if spell_menu.visible:
		_build_spell_menu()

func _build_spell_menu() -> void:
	for c in spell_options.get_children():
		c.queue_free()
	_spell_option_nodes.clear()
	if not _player or not _player.has_method("get_spells"):
		return
	var spells = _player.get_spells()
	for i in spells.size():
		var sp = spells[i]
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(64, 72)
		panel.size = Vector2(64, 72)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP

		var icon := TextureRect.new()
		icon.size = Vector2(56, 56)
		icon.position = Vector2(4, 4)
		icon.expand_mode = 1
		icon.stretch_mode = 5
		var tex = load(sp.icon_path) if sp.icon_path else null
		icon.texture = tex
		panel.add_child(icon)

		var lbl := Label.new()
		lbl.text = sp.name
		lbl.position = Vector2(0, 58)
		lbl.size = Vector2(64, 14)
		lbl.horizontal_alignment = 1
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		panel.add_child(lbl)

		var current_idx = _player._current_spell_index if _player.has_method("get_current_spell") else 0
		if i == current_idx:
			panel.modulate = Color(1, 1, 0.5)
		panel.gui_input.connect(func(event, idx=i): _on_spell_option_input(event, idx))
		panel.mouse_entered.connect(func(idx=i): _on_spell_option_hover(idx))
		panel.mouse_exited.connect(_on_spell_option_unhover)
		spell_options.add_child(panel)
		_spell_option_nodes.append(panel)

func _on_spell_option_input(event: InputEvent, idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _player and _player.has_method("set_spell_index"):
			var current = _player._current_spell_index if _player.has_method("get_current_spell") else -1
			if idx != current:
				_player.set_spell_index(idx)
				spell_menu.visible = false

func _on_spell_option_hover(idx: int) -> void:
	if not _player or not _player.has_method("get_spells"):
		return
	var spells = _player.get_spells()
	if idx < 0 or idx >= spells.size():
		return
	var sp = spells[idx]
	# Simple tooltip: show in the panel or via hint
	for i in _spell_option_nodes.size():
		var n = _spell_option_nodes[i]
		var existing = n.get_node_or_null("Tooltip")
		if existing:
			existing.queue_free()
		if i == idx:
			var tip := Label.new()
			tip.name = "Tooltip"
			tip.text = "DMG: %d-%d\nCost: %d MP" % [sp.min_val, sp.max_val, sp.mana_cost]
			tip.position = Vector2(0, -40)
			tip.size = Vector2(100, 36)
			tip.add_theme_font_size_override("font_size", 10)
			tip.add_theme_color_override("font_color", Color(1, 1, 0.8))
			n.add_child(tip)

func _on_spell_option_unhover() -> void:
	for n in _spell_option_nodes:
		var tip = n.get_node_or_null("Tooltip")
		if tip:
			tip.queue_free()

func _on_btn_inventory(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _player and _player.has_method("_toggle_inventory"):
			_player._toggle_inventory()

func _on_btn_stats(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _player and _player.has_method("_toggle_stats"):
			_player._toggle_stats()

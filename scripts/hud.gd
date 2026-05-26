extends CanvasLayer

@onready var hp_fill := $HPBar/HPFill
@onready var mp_fill := $MPBar/MPFill
@onready var xp_fill := $XPBar/XPFill
@onready var hp_label := $HPBar/HPLabel
@onready var mp_label := $MPBar/MPLabel
@onready var xp_label := $XPBar/XPLabel
@onready var dungeon_label := $DungeonLevel

var _stats: Stats
var _dungeon_level: int = 1

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_stats"):
		_stats = player.get_stats()
	elif player:
		_stats = player.stats if "stats" in player else null
	if _stats:
		_stats.hp_changed.connect(_update_hp)
		_stats.mana_changed.connect(_update_mp)
		_stats.xp_changed.connect(_update_xp)
		_stats.level_changed.connect(_update_level)
		_update_hp(_stats.hp, _stats.get_max_hp())
		_update_mp(_stats.mana, _stats.get_max_mana())
		_update_xp(_stats.xp, _stats.xp_to_next)
		_update_level(_stats.level)

	# Connect to dungeon level changes
	var dungeon := get_tree().root.find_child("Dungeon", true, false)
	if dungeon:
		if dungeon.has_signal("goal_reached"):
			dungeon.goal_reached.connect(_on_dungeon_goal)
		if dungeon.has_signal("dungeon_regenerating"):
			dungeon.dungeon_regenerating.connect(_on_dungeon_regenerate)
		_update_dungeon_level()

func _update_dungeon_level() -> void:
	var dungeon := get_tree().root.find_child("Dungeon", true, false)
	if dungeon and "_dungeon_level" in dungeon:
		_dungeon_level = dungeon._dungeon_level
	dungeon_label.text = "Dungeon Lv.%d" % _dungeon_level

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

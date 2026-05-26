extends CanvasLayer

const MAX_ENEMIES := 3
const UNTRACK_TIME := 5.0

var _tracked: Array[Dictionary] = []

func _ready() -> void:
	add_to_group("enemy_hp_panel")
	for i in MAX_ENEMIES:
		var row = get_node("Row" + str(i + 1))
		row.visible = false

func track(enemy: Node3D) -> void:
	for entry in _tracked:
		if entry.enemy == enemy:
			_tracked.erase(entry)
			break
	_tracked.push_front({"enemy": enemy, "time": UNTRACK_TIME})
	while _tracked.size() > MAX_ENEMIES:
		_tracked.pop_back()
	_update_rows()

func _process(delta: float) -> void:
	var changed := false
	for entry in _tracked:
		if not is_instance_valid(entry.enemy) or not entry.enemy.has_method("_update_hp_bar"):
			entry.time = -1.0
			changed = true
		else:
			entry.time -= delta
			if entry.time <= 0.0:
				changed = true
	if changed:
		_tracked = _tracked.filter(func(e): return e.time > 0.0 and is_instance_valid(e.enemy))
		_update_rows()

func _update_rows() -> void:
	for i in MAX_ENEMIES:
		var row = get_node("Row" + str(i + 1))
		if i < _tracked.size():
			var entry = _tracked[i]
			if is_instance_valid(entry.enemy) and entry.enemy.has_method("_update_hp_bar"):
				row.visible = true
				var enemy = entry.enemy
				var hp_max = enemy.max_hp if "max_hp" in enemy else 100.0
				var hp_cur = enemy.hp if "hp" in enemy else 0.0
				var ratio = max(hp_cur / hp_max, 0.0)
				row.get_node("Fill").size.x = row.get_node("Bg").size.x * ratio
				var lvl = enemy.level if "level" in enemy else 1
				var ename: String = enemy.name
				if "display_name" in enemy:
					ename = enemy.display_name
				row.get_node("Label").text = "Lv.%d %s" % [lvl, ename]
		else:
			row.visible = false

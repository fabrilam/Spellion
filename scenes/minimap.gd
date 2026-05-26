extends Control

@export var map_size: float = 150.0
@export var world_range: float = 75.0
@export var margin: float = 20.0
@export var player_color := Color(0.3, 0.6, 1.0)
@export var enemy_color := Color(1.0, 0.2, 0.2)
@export var wall_color := Color(0.25, 0.2, 0.18)
@export var floor_color := Color(0.1, 0.1, 0.1)
@export var door_color := Color(0.6, 0.4, 0.2)

var _player: Node3D
var _dungeon_vis: Node = null

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_dungeon_vis = get_tree().root.find_child("Dungeon", true, false)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
		if not _player:
			return

	var view := get_viewport_rect().size
	position = Vector2(view.x - map_size - margin, view.y - map_size - margin)
	size = Vector2(map_size, map_size)

	draw_rect(Rect2(Vector2(0, 0), Vector2(map_size, map_size)), Color(0, 0, 0, 0.55))
	draw_rect(Rect2(Vector2(0, 0), Vector2(map_size, map_size)), Color(1, 1, 1, 0.15), false, 1.0)

	var center := Vector2(map_size * 0.5, map_size * 0.5)
	var scale_f := map_size / (world_range * 2.0)

	# Draw dungeon tiles
	if _dungeon_vis and _dungeon_vis.has_method("get_grid"):
		var grid: Array = _dungeon_vis.get_grid()
		if grid.size() > 0:
			var gh: int = grid.size()
			var gw: int = grid[0].size()
			for dy in range(gh):
				for dx in range(gw):
					var tile: int = grid[dy][dx]
					if tile == 0:
						continue
					var wx: float = dx * 2.0 - gw * 0.5 * 2.0
					var wz: float = dy * 2.0 + 20.0
					var rel: Vector3 = Vector3(wx, 0.0, wz) - _player.global_position
					var sp: Vector2 = center + Vector2(rel.x * scale_f, rel.z * scale_f)
					if sp.x < -5 or sp.x > map_size + 5 or sp.y < -5 or sp.y > map_size + 5:
						continue
					var col: Color
					match tile:
						1: col = floor_color
						2: col = wall_color
						4: col = door_color
						_: continue
					draw_rect(Rect2(sp, Vector2(2, 2)), col)

	# Draw enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var rel: Vector3 = enemy.global_position - _player.global_position
		var sp: Vector2 = center + Vector2(rel.x * scale_f, rel.z * scale_f)
		if sp.x >= 0 and sp.x <= map_size and sp.y >= 0 and sp.y <= map_size:
			draw_circle(sp, 2.5, enemy_color)

	# Draw player last (on top)
	draw_circle(center, 3.0, player_color)
	draw_circle(center, 5.0, Color(player_color, 0.3))

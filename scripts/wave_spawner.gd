extends Node3D

@export var enemy_scene: PackedScene = preload("res://scenes/spider.tscn")
@export var super_spider_scene: PackedScene = preload("res://scenes/super_spider.tscn")
@export var player: Node3D
@export var scatter_count: int = 0
@export var min_enemies: int = 3
@export var max_enemies: int = 8
@export var wave: int = 1
@export var scatter_radius: float = 40.0

var _enemies: Array[Node] = []
var _dungeon: Node = null
var _scatter_done: bool = false

func _ready() -> void:
	if not player:
		player = get_node_or_null("../Howard")
	if not player:
		player = get_tree().get_first_node_in_group("player")
	_dungeon = get_node_or_null("../Dungeon")
	if player:
		if scatter_count > 0:
			_spawn_scatter()
		else:
			_spawn_wave()

func _process(_delta: float) -> void:
	if scatter_count > 0:
		return
	_enemies = _enemies.filter(func(e): return is_instance_valid(e))
	if _enemies.is_empty():
		wave += 1
		_spawn_wave()

func _spawn_scatter() -> void:
	var forest_center := Vector3(0.0, 0.0, -80.0)
	for i in scatter_count:
		var lvl := randi_range(1, 8)
		var pos := forest_center + Vector3(randf_range(-scatter_radius, scatter_radius), 0.0, randf_range(-scatter_radius, scatter_radius))
		var enemy := enemy_scene.instantiate()
		enemy.position = pos
		add_child(enemy)
		enemy.init(player, lvl)
		_enemies.append(enemy)

func _spawn_wave() -> void:
	var count := randi_range(min_enemies, max_enemies) + wave
	var min_lvl := mini(1 + wave / 2, 15)
	var max_lvl := mini(1 + wave, 15)
	for i in count:
		_spawn_enemy(min_lvl, max_lvl)
	if super_spider_scene and player:
		_spawn_super_spider(min_lvl, max_lvl)

func _spawn_enemy(min_lvl: int, max_lvl: int) -> void:
	if not enemy_scene or not player:
		return
	var enemy := enemy_scene.instantiate()
	var lvl := randi_range(min_lvl, max_lvl)
	var spawn_pos := _random_spawn_position()
	enemy.position = spawn_pos
	add_child(enemy)
	enemy.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else null
	enemy.init(player, lvl)
	_enemies.append(enemy)

func _spawn_super_spider(min_lvl: int, max_lvl: int) -> void:
	var enemy := super_spider_scene.instantiate()
	var lvl := clampi(max_lvl + 2, 3, 20)
	var spawn_pos := _random_spawn_position()
	enemy.position = spawn_pos
	add_child(enemy)
	enemy.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else null
	enemy.init(player, lvl)
	_enemies.append(enemy)

func _random_spawn_position() -> Vector3:
	if _dungeon and _dungeon.has_method("get_floor_positions"):
		var floors: Array = _dungeon.get_floor_positions()
		if floors.size() > 0:
			for _attempt in 10:
				var pos: Vector3 = floors[randi_range(0, floors.size() - 1)]
				if player:
					var dist := pos.distance_to(player.global_position)
					if dist > 8.0 and dist < 25.0:
						return pos
			return floors[randi_range(0, floors.size() - 1)]
	if player:
		var dir := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		var dist := randf_range(10, 25)
		return player.global_position + dir * dist
	return Vector3(randf_range(-190, 190), 0, randf_range(-190, 190))

func clear_super_spider() -> void:
	for e in _enemies:
		if is_instance_valid(e) and e.has_method("consume_orb") and e.display_name == "Super SPIDER":
			e.queue_free()

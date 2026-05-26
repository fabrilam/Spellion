extends Node3D

@export var radius: float = 65.0
@export var tree_count: int = 120
@export var bush_count: int = 80
@export var plant_count: int = 60
@export var min_tree_spacing: float = 3.5
@export var open_space_radius: float = 15.0

var _tree_scenes := [
	preload("res://assets/models/visitantes/trees/tree.tscn"),
	preload("res://assets/models/visitantes/trees/tree_2.tscn"),
	preload("res://assets/models/visitantes/trees/tree_3.tscn"),
	preload("res://assets/models/visitantes/trees/tree_4.tscn"),
]

var _bush_scenes := [
	preload("res://assets/models/visitantes/bushes/bush.tscn"),
	preload("res://assets/models/visitantes/bushes/bush_2.tscn"),
	preload("res://assets/models/visitantes/bushes/bushcubrevision.tscn"),
]

var _plant_scenes := [
	preload("res://assets/models/visitantes/plants/plant_1.tscn"),
	preload("res://assets/models/visitantes/plants/plant_2.tscn"),
	preload("res://assets/models/visitantes/plants/plant_3.tscn"),
	preload("res://assets/models/visitantes/plants/plant_4.tscn"),
]

var _placed_positions: Array[Vector2] = []

func _ready() -> void:
	randomize()
	_placed_positions.clear()
	_scatter_trees()
	_scatter_bushes()
	_scatter_plants()

func _random_pos() -> Vector2:
	var angle := randf() * TAU
	var dist := randf() * radius
	return Vector2(cos(angle) * dist, sin(angle) * dist)

func _in_open_space(pos2: Vector2) -> bool:
	return pos2.length() < open_space_radius

func _too_close(pos2: Vector2, min_dist: float) -> bool:
	for p in _placed_positions:
		if p.distance_squared_to(pos2) < min_dist * min_dist:
			return true
	return false

func _scatter_trees() -> void:
	for i in tree_count:
		for attempt in 10:
			var pos2 := _random_pos()
			if _in_open_space(pos2):
				continue
			if _too_close(pos2, min_tree_spacing):
				continue
			var tree_scene: PackedScene = _tree_scenes[randi() % _tree_scenes.size()]
			var tree: Node3D = tree_scene.instantiate()
			tree.position = Vector3(pos2.x, 0.0, pos2.y)
			var s := 0.8 + randf() * 0.6
			tree.scale = Vector3(s, s, s)
			tree.rotation.y = randf() * TAU
			tree.set_script(preload("res://scripts/decor_fade.gd"))
			add_child(tree)
			_placed_positions.append(pos2)
			break

func _scatter_bushes() -> void:
	for i in bush_count:
		for attempt in 10:
			var pos2 := _random_pos()
			if _in_open_space(pos2):
				continue
			if _too_close(pos2, 1.5):
				continue
			var bush_scene: PackedScene = _bush_scenes[randi() % _bush_scenes.size()]
			var bush: Node3D = bush_scene.instantiate()
			bush.position = Vector3(pos2.x, 0.0, pos2.y)
			var s := 0.6 + randf() * 0.8
			bush.scale = Vector3(s, s, s)
			bush.rotation.y = randf() * TAU
			bush.set_script(preload("res://scripts/decor_fade.gd"))
			add_child(bush)
			_placed_positions.append(pos2)
			break

func _scatter_plants() -> void:
	for i in plant_count:
		for attempt in 10:
			var pos2 := _random_pos()
			if _in_open_space(pos2):
				continue
			if _too_close(pos2, 0.8):
				continue
			var plant_scene: PackedScene = _plant_scenes[randi() % _plant_scenes.size()]
			var plant: Node3D = plant_scene.instantiate()
			plant.position = Vector3(pos2.x, 0.0, pos2.y)
			var s := 1.0 + randf() * 1.5
			plant.scale = Vector3(s, s, s)
			plant.rotation.y = randf() * TAU
			plant.set_script(preload("res://scripts/decor_fade.gd"))
			add_child(plant)
			_placed_positions.append(pos2)
			break

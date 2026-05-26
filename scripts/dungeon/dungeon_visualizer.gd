extends Node3D

@export var wall_material: Material
@export var floor_material: Material
@export var door_material: Material
@export var generate_on_ready: bool = true
@export var seed: int = -1

var _generator: DungeonGenerator
var _grid: Array = []
var _rooms: Array = []
var _grid_w: int = 0
var _grid_h: int = 0
var _spawn_pos: Vector3 = Vector3.ZERO
var _goal_area: Area3D = null
var _goal_mat: StandardMaterial3D = null
var _dungeon_level: int = 1
var _wall_sections: Array = []
var _goal_hue: float = 0.0
var _transparent: Array = []

signal goal_reached(dungeon_level: int)
signal dungeon_regenerating

func _ready() -> void:
	if generate_on_ready:
		generate(seed if seed >= 0 else randi())
		call_deferred("_spawn_enemies")
	goal_reached.connect(_on_goal_reached)

func _teleport_player_to_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = _spawn_pos + Vector3(0.0, 0.6, 0.0)

func _on_goal_reached(level: int) -> void:
	_teleport_player_to_spawn()

	# Clear old enemies
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e):
			e.queue_free()

	# Regenerate dungeon
	dungeon_regenerating.emit()
	seed = randi()
	generate(seed)
	call_deferred("_spawn_enemies_with_level", level + 1)

func generate(seed_val: int = -1) -> void:
	if not _generator:
		_generator = DungeonGenerator.new()
	var result: Dictionary = _generator.generate(seed_val)
	_grid = result.grid
	_rooms = result.rooms
	_grid_w = result.width
	_grid_h = result.height
	_spawn_pos = result.get("spawn_pos", Vector3.ZERO)
	_transparent = result.get("transparent", [])
	_build_meshes()
	_teleport_player_to_spawn()

func generate_from_data(grid: Array, rooms: Array, w: int, h: int) -> void:
	_grid = grid
	_rooms = rooms
	_grid_w = w
	_grid_h = h
	_build_meshes()

func _build_meshes() -> void:
	for c in get_children():
		c.queue_free()

	var wall_mat: Material = wall_material
	var floor_mat: Material = floor_material
	var door_mat: Material = door_material

	var rock_mat := preload("res://assets/textures/floor/floor_rock_material.tres") as StandardMaterial3D
	if not floor_mat:
		floor_mat = rock_mat
	if not wall_mat and rock_mat:
		wall_mat = rock_mat.duplicate()
		wall_mat.albedo_color = Color(0.35, 0.3, 0.28)
		wall_mat.uv1_scale = Vector3(0.5, 0.5, 0.5)
	if not wall_mat:
		wall_mat = StandardMaterial3D.new()
		wall_mat.albedo_color = Color(0.3, 0.25, 0.2)
	if not door_mat:
		door_mat = StandardMaterial3D.new()
		door_mat.albedo_color = Color(0.4, 0.3, 0.2)

	var st_floor := SurfaceTool.new()
	st_floor.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Build floor/door mesh as one merged mesh (including under walls)
	var st_perim := SurfaceTool.new()
	st_perim.begin(Mesh.PRIMITIVE_TRIANGLES)
	var border_mat: Material = floor_mat
	if border_mat and border_mat is StandardMaterial3D:
		border_mat = border_mat.duplicate()
		border_mat.albedo_color = Color(0.25, 0.18, 0.15)

	for y in range(_grid_h):
		for x in range(_grid_w):
			var tile: int = _grid[y][x]
			if tile == DungeonTiles.TileType.VOID:
				continue
			var px: float = x * 2.0 - _grid_w * 0.5 * 2.0
			var pz: float = y * 2.0 + 20.0
			# Check if this tile is adjacent to an opaque (exterior) wall
			var is_border := false
			if _transparent.size() > 0:
				for ny in [y - 1, y + 1]:
					if ny >= 0 and ny < _grid_h:
						if _grid[ny][x] == DungeonTiles.TileType.WALL and not _transparent[ny][x]:
							is_border = true
				for nx in [x - 1, x + 1]:
					if nx >= 0 and nx < _grid_w:
						if _grid[y][nx] == DungeonTiles.TileType.WALL and not _transparent[y][nx]:
							is_border = true
			if is_border:
				_add_cube(st_perim, Vector3(px, 0.12, pz), Vector3(2.0, 0.24, 2.0), border_mat)
			else:
				_add_cube(st_floor, Vector3(px, 0.1, pz), Vector3(2.0, 0.2, 2.0), floor_mat)

	var floor_mesh: Mesh = st_floor.commit()
	var floor_mii := MeshInstance3D.new()
	floor_mii.mesh = floor_mesh
	floor_mii.name = "FloorMesh"
	add_child(floor_mii)

	var perim_mesh: Mesh = st_perim.commit()
	var perim_mii := MeshInstance3D.new()
	perim_mii.mesh = perim_mesh
	perim_mii.name = "BorderMesh"
	add_child(perim_mii)

	# Build individual wall meshes (one per tile for per-wall transparency)
	_wall_sections.clear()
	var col_body := StaticBody3D.new()
	for y in range(_grid_h):
		for x in range(_grid_w):
			if _grid[y][x] != DungeonTiles.TileType.WALL:
				continue
			var px: float = x * 2.0 - _grid_w * 0.5 * 2.0
			var pz: float = y * 2.0 + 20.0
			var wmii := MeshInstance3D.new()
			var wall_mesh_ref := BoxMesh.new()
			wall_mesh_ref.size = Vector3(2.0, 4.0, 2.0)
			wmii.mesh = wall_mesh_ref
			var wall_mat_copy: Material = wall_mat.duplicate()
			var is_transparent: bool = _transparent.size() > y and _transparent[y].size() > x and _transparent[y][x]
			if is_transparent:
				var c: Color = wall_mat_copy.albedo_color
				c.a = 0.3
				wall_mat_copy.albedo_color = c
				wall_mat_copy.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			wmii.material_override = wall_mat_copy
			wmii.position = Vector3(px, 2.0, pz)
			add_child(wmii)
			_wall_sections.append({ "node": wmii, "mat": wall_mat_copy, "alpha": 0.3 if is_transparent else 1.0 })

			# Collision shape per wall tile
			var col_sh := CollisionShape3D.new()
			var box_sh := BoxShape3D.new()
			box_sh.size = Vector3(2.0, 4.0, 2.0)
			col_sh.shape = box_sh
			col_sh.position = Vector3(px, 2.0, pz)
			col_body.add_child(col_sh)

	col_body.add_to_group("dungeon_wall")
	add_child(col_body)

	_add_lights()
	_add_goal_tile()
	_add_exit_marker()

func _add_goal_tile() -> void:
	var candidates: Array = []
	var spawn_dist_sq := 40.0 * 40.0
	for y in range(_grid_h):
		for x in range(_grid_w):
			if _grid[y][x] != DungeonTiles.TileType.FLOOR:
				continue
			var wx: float = x * 2.0 - _grid_w * 0.5 * 2.0
			var wz: float = y * 2.0 + 20.0
			var dx := wx - _spawn_pos.x
			var dz := wz - _spawn_pos.z
			if dx * dx + dz * dz >= spawn_dist_sq:
				candidates.append(Vector3(wx, 0.0, wz))

	if candidates.is_empty():
		return
	var pos: Vector3 = candidates[randi() % candidates.size()]

	# Rainbow floor tile
	var mii := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.0, 0.15, 2.0)
	mii.mesh = box
	_goal_mat = StandardMaterial3D.new()
	_goal_mat.albedo_color = Color(1.0, 0.0, 0.0)
	_goal_mat.emission_enabled = true
	_goal_mat.emission = Color(1.0, 0.0, 0.0)
	mii.material_override = _goal_mat
	mii.position = pos + Vector3(0, 0.1, 0)
	add_child(mii)

	_goal_area = Area3D.new()
	var col_shape := CollisionShape3D.new()
	var col_box := BoxShape3D.new()
	col_box.size = Vector3(2.0, 0.5, 2.0)
	col_shape.shape = col_box
	_goal_area.add_child(col_shape)
	_goal_area.position = pos
	_goal_area.body_entered.connect(_on_goal_entered)
	add_child(_goal_area)

func _on_goal_entered(body: Node) -> void:
	if body.is_in_group("player"):
		goal_reached.emit(_dungeon_level)
		_dungeon_level += 1

func get_spawn_pos() -> Vector3:
	return _spawn_pos

func _add_exit_marker() -> void:
	# Stair-like mesh at the entrance door
	var stair_mat := StandardMaterial3D.new()
	stair_mat.albedo_color = Color(0.6, 0.5, 0.3)
	stair_mat.emission_enabled = true
	stair_mat.emission = Color(0.3, 0.25, 0.15)
	var step1 := MeshInstance3D.new()
	var box1 := BoxMesh.new()
	box1.size = Vector3(0.8, 0.1, 1.0)
	step1.mesh = box1
	step1.material_override = stair_mat
	step1.position = _spawn_pos + Vector3(-0.3, 0.05, 0.0)
	add_child(step1)
	var step2 := MeshInstance3D.new()
	var box2 := BoxMesh.new()
	box2.size = Vector3(0.6, 0.1, 0.8)
	step2.mesh = box2
	step2.material_override = stair_mat
	step2.position = _spawn_pos + Vector3(-0.5, 0.15, 0.0)
	add_child(step2)

func _add_lights() -> void:
	for ri in _rooms.size():
		var rd: Dictionary = _rooms[ri]
		var rw: int = rd.w
		var rh: int = rd.h
		var light_count := 1
		if rw >= 14 and rh >= 14:
			light_count = 3
		elif rw >= 10 and rh >= 10:
			light_count = 2
		var cx: float = (rd.x + rw / 2.0) * 2.0 - _grid_w * 0.5 * 2.0
		var cz: float = (rd.y + rh / 2.0) * 2.0 + 20.0
		for li in range(light_count):
			var ox: float = (li - (light_count - 1) * 0.5) * 4.0
			var lx: float = cx + ox
			var lz: float = cz
			var grid_x: int = int((lx + _grid_w) / 2.0 + 0.5)
			var grid_y: int = int((lz - 20.0) / 2.0 + 0.5)
			if grid_x >= 0 and grid_x < _grid_w and grid_y >= 0 and grid_y < _grid_h:
				if _grid[grid_y][grid_x] == DungeonTiles.TileType.WALL:
					continue
			var light := OmniLight3D.new()
			light.position = Vector3(lx, 3.5, lz)
			light.light_color = Color(1.0, 0.9, 0.7)
			light.light_energy = 1.2
			light.omni_range = 8.0
			add_child(light)

func _spawn_enemies() -> void:
	_spawn_enemies_with_level(1)

func _spawn_enemies_with_level(dlvl: int) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var enemy_scene := preload("res://scenes/spider.tscn")
	var floor_tiles: Array = []
	for y in range(_grid_h):
		for x in range(_grid_w):
			if _grid[y][x] == DungeonTiles.TileType.FLOOR:
				var px: float = x * 2.0 - _grid_w * 0.5 * 2.0
				var pz: float = y * 2.0 + 20.0
				floor_tiles.append(Vector3(px, 0.0, pz))
	if floor_tiles.is_empty():
		return
	var count_: int = maxi(20, floor_tiles.size() / 6)
	var parent := get_parent()
	var spawn_parent := parent if parent else self
	for i in count_:
		var idx: int = randi_range(0, floor_tiles.size() - 1)
		var pos: Vector3 = floor_tiles[idx]
		var enemy := enemy_scene.instantiate()
		enemy.position = pos + Vector3(0.0, 0.6, 0.0)
		var min_lvl: int = (dlvl - 1) * 3 + 1
		var max_lvl: int = dlvl * 3
		var lvl := randi_range(min_lvl, max_lvl)
		spawn_parent.call_deferred("add_child", enemy)
		enemy.call_deferred("init", player, lvl)
	# Spawn exactly one Super SPIDER per dungeon floor (near entrance)
	var super_scene := preload("res://scenes/super_spider.tscn")
	var super_enemy := super_scene.instantiate()
	var super_pos: Vector3 = _spawn_pos + Vector3(2.0, 0.0, 2.0)
	if floor_tiles.size() > 0:
		var nearest: Vector3 = floor_tiles[0]
		var near_dist := 99999.0
		for ft in floor_tiles:
			var d: float = ft.distance_squared_to(_spawn_pos)
			if d < near_dist:
				near_dist = d
				nearest = ft
		super_pos = nearest
	super_enemy.position = super_pos + Vector3(0.0, 0.6, 0.0)
	var super_lvl: int = clampi(dlvl * 3 + 2, 3, 20)
	spawn_parent.call_deferred("add_child", super_enemy)
	super_enemy.call_deferred("init", player, super_lvl)

func _process(delta: float) -> void:
	if _goal_mat:
		_goal_hue = fmod(_goal_hue + delta * 0.15, 1.0)
		var c: Color = Color.from_hsv(_goal_hue, 0.8, 1.0)
		_goal_mat.albedo_color = c
		_goal_mat.emission = Color.from_hsv(_goal_hue, 0.8, 0.6)

func _add_cube(st: SurfaceTool, center: Vector3, size: Vector3, mat: Material) -> void:
	st.set_material(mat)
	var half := size * 0.5
	var v: PackedVector3Array = PackedVector3Array()
	v.append(Vector3(-1, -1, -1))
	v.append(Vector3(1, -1, -1))
	v.append(Vector3(1, 1, -1))
	v.append(Vector3(-1, 1, -1))
	v.append(Vector3(-1, -1, 1))
	v.append(Vector3(1, -1, 1))
	v.append(Vector3(1, 1, 1))
	v.append(Vector3(-1, 1, 1))
	for i in v.size():
		v[i] = v[i] * half + center

	var norms: Array = [
		Vector3(0, 0, -1), Vector3(0, 0, 1),
		Vector3(-1, 0, 0), Vector3(1, 0, 0),
		Vector3(0, 1, 0), Vector3(0, -1, 0),
	]

	var tris: Array = [
		[0, 1, 2, 0, 2, 3],
		[5, 4, 7, 5, 7, 6],
		[4, 0, 3, 4, 3, 7],
		[1, 5, 6, 1, 6, 2],
		[3, 2, 6, 3, 6, 7],
		[4, 5, 1, 4, 1, 0],
	]

	var uvs: Array = [
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	]

	for f in 6:
		var face_tris: Array = tris[f]
		var normal: Vector3 = norms[f]
		for t in 6:
			var vi: int = face_tris[t]
			st.set_normal(normal)
			st.set_uv(uvs[vi % 4])
			st.add_vertex(v[vi])

func get_floor_positions() -> Array:
	var positions: Array = []
	for y in range(_grid_h):
		for x in range(_grid_w):
			var tile: int = _grid[y][x]
			if tile == DungeonTiles.TileType.FLOOR or tile == DungeonTiles.TileType.DOOR:
				var px: float = x * 2.0 - _grid_w * 0.5 * 2.0
				var pz: float = y * 2.0 + 20.0
				positions.append(Vector3(px, 0.0, pz))
	return positions

func get_grid() -> Array:
	return _grid

func get_rooms() -> Array:
	return _rooms

func get_grid_size() -> Vector2i:
	return Vector2i(_grid_w, _grid_h)

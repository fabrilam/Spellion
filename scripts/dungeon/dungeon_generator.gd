extends Resource
class_name DungeonGenerator

const TILE_SIZE := 2.0
const GRID_W := 80
const GRID_H := 60

const SPINE_ROOM_SIZE := 8
const SPINE_CORRIDOR_W := 1
const MIN_FLOOR_TILES := 400

const ROOM_NAMES := {
	DungeonTiles.RoomType.SPAWN:   "Spawn",
	DungeonTiles.RoomType.STORAGE: "Storage",
	DungeonTiles.RoomType.HALLWAY: "Hallway",
	DungeonTiles.RoomType.TREASURE: "Treasure",
	DungeonTiles.RoomType.ALTAR:   "Altar",
	DungeonTiles.RoomType.LIBRARY: "Library",
	DungeonTiles.RoomType.OPEN_AREA: "OpenArea",
	DungeonTiles.RoomType.BOSS:    "Boss",
}

var rng := RandomNumberGenerator.new()
var _grid: Array = []
var _rooms: Array = []
var _room_registry: Array = []
var _spawn_door_y: int = 0
var _transparent: Array = []

func generate(seed_val: int = -1) -> Dictionary:
	rng = RandomNumberGenerator.new()
	if seed_val >= 0:
		rng.seed = seed_val
	else:
		rng.randomize()

	for attempt in 30:
		_grid = []
		for y in range(GRID_H):
			var row: Array = []
			for x in range(GRID_W):
				row.append(DungeonTiles.TileType.VOID)
			_grid.append(row)
		_rooms = []
		_room_registry = []
		_transparent = []
		for y in range(GRID_H):
			var row: Array = []
			for x in range(GRID_W):
				row.append(false)
			_transparent.append(row)

		_generate_spine()
		if _room_registry.size() > 0:
			var sp: Dictionary = _room_registry[0]
			_l5_room_gen(sp.x, sp.y, sp.w, sp.h, 0)

		var floor_count := _count_floor()
		if floor_count < MIN_FLOOR_TILES:
			continue

		_build_walls()
		_fill_corners()
		_add_interior_walls()
		_analyze_transparency()

		if _is_fully_connected():
			break

	_assign_room_types()
	var spawn_world_x: float = 0.0 * 2.0 - GRID_W * 0.5 * 2.0
	var spawn_world_z: float = _spawn_door_y * 2.0 + 20.0
	return {
		"grid": _grid,
		"transparent": _transparent,
		"rooms": _rooms.duplicate(),
		"width": GRID_W,
		"height": GRID_H,
		"spawn_pos": Vector3(spawn_world_x, 0.0, spawn_world_z),
	}

func _generate_spine() -> void:
	var room_count := rng.randi_range(2, 3)
	var spine_y := (GRID_H - SPINE_ROOM_SIZE) / 2

	for i in room_count:
		var rx := 2 + i * (SPINE_ROOM_SIZE + SPINE_CORRIDOR_W)
		var ry := spine_y
		_draw_room(rx, ry, SPINE_ROOM_SIZE, SPINE_ROOM_SIZE)
		var room: Dictionary = { "x": rx, "y": ry, "w": SPINE_ROOM_SIZE, "h": SPINE_ROOM_SIZE }
		_room_registry.append(room)

		if i > 0:
			var prev_rx := 2 + (i - 1) * (SPINE_ROOM_SIZE + SPINE_CORRIDOR_W)
			var mid_y := spine_y + SPINE_ROOM_SIZE / 2
			for x in range(prev_rx + SPINE_ROOM_SIZE, rx):
				for w in range(SPINE_CORRIDOR_W):
					var yy := mid_y - SPINE_CORRIDOR_W / 2 + w
					if yy >= 0 and yy < GRID_H and x >= 0 and x < GRID_W:
						_grid[yy][x] = DungeonTiles.TileType.FLOOR

	_spawn_door_y = spine_y + SPINE_ROOM_SIZE / 2
	if _spawn_door_y >= 0 and _spawn_door_y < GRID_H:
		_grid[_spawn_door_y][0] = DungeonTiles.TileType.DOOR
		_grid[_spawn_door_y][1] = DungeonTiles.TileType.FLOOR

func _draw_room(rx: int, ry: int, rw: int, rh: int) -> void:
	for y in range(ry, ry + rh):
		for x in range(rx, rx + rw):
			if x >= 0 and x < GRID_W and y >= 0 and y < GRID_H:
				_grid[y][x] = DungeonTiles.TileType.FLOOR

func _diablo_room_size() -> int:
	var raw: int = (rng.randi_range(0, 5) + 2)
	raw = raw & 0xFFFFFFFE
	return raw * 2

func _l5_room_gen(x: int, y: int, w: int, h: int, axis: int) -> void:
	if rng.randf() < 0.25:
		axis = 1 - axis

	if axis == 0:
		var num := 0
		var cw := 0
		var ch := 0
		var cx1 := 0
		var cy1 := 0
		var ran := false
		while not ran and num < 20:
			cw = _diablo_room_size()
			ch = _diablo_room_size()
			cy1 = h / 2 + y - ch / 2
			cx1 = x - cw
			ran = _l5_check_room(cx1 - 1, cy1 - 1, cw + 1, ch + 2)
			num += 1

		if ran:
			_draw_room(cx1, cy1, cw, ch)
			_room_registry.append({ "x": cx1, "y": cy1, "w": cw, "h": ch })

		var cx2 := x + w
		var ran2 := _l5_check_room(cx2, cy1 - 1, cw + 1, ch + 2)
		if ran2:
			_draw_room(cx2, cy1, cw, ch)
			_room_registry.append({ "x": cx2, "y": cy1, "w": cw, "h": ch })

		if ran:
			_l5_room_gen(cx1, cy1, cw, ch, 1)
		if ran2:
			_l5_room_gen(cx2, cy1, cw, ch, 1)

	else:
		var num := 0
		var cw := 0
		var ch := 0
		var rx := 0
		var ry := 0
		var ran := false
		while not ran and num < 20:
			cw = _diablo_room_size()
			ch = _diablo_room_size()
			rx = w / 2 + x - cw / 2
			ry = y - ch
			ran = _l5_check_room(rx - 1, ry - 1, cw + 2, ch + 1)
			num += 1

		if ran:
			_draw_room(rx, ry, cw, ch)
			_room_registry.append({ "x": rx, "y": ry, "w": cw, "h": ch })

		var ry2 := y + h
		var ran2 := _l5_check_room(rx - 1, ry2, cw + 2, ch + 1)
		if ran2:
			_draw_room(rx, ry2, cw, ch)
			_room_registry.append({ "x": rx, "y": ry2, "w": cw, "h": ch })

		if ran:
			_l5_room_gen(rx, ry, cw, ch, 0)
		if ran2:
			_l5_room_gen(rx, ry2, cw, ch, 0)

func _l5_check_room(tx: int, ty: int, tw: int, th: int) -> bool:
	if tx < 0 or ty < 0 or tx + tw > GRID_W or ty + th > GRID_H:
		return false
	for y in range(ty, ty + th):
		for x in range(tx, tx + tw):
			if _grid[y][x] != DungeonTiles.TileType.VOID:
				return false
	return true

func _room_fits(rx: int, ry: int, rw: int, rh: int) -> bool:
	if rx < 0 or ry < 0 or rx + rw > GRID_W or ry + rh > GRID_H:
		return false
	for y in range(ry, ry + rh):
		for x in range(rx, rx + rw):
			if _grid[y][x] != DungeonTiles.TileType.VOID:
				return false
	return true

func _analyze_transparency() -> void:
	for y in range(GRID_H):
		for x in range(GRID_W):
			if _grid[y][x] != DungeonTiles.TileType.WALL:
				continue
			if y > 0:
				var n: int = _grid[y - 1][x]
				if n == DungeonTiles.TileType.FLOOR or n == DungeonTiles.TileType.DOOR:
					_transparent[y][x] = true

func _count_floor() -> int:
	var count := 0
	for y in range(GRID_H):
		for x in range(GRID_W):
			if _grid[y][x] == DungeonTiles.TileType.FLOOR:
				count += 1
	return count

func _build_walls() -> void:
	# Marching squares: any VOID adjacent to FLOOR becomes WALL
	var to_wall: Array = []
	for y in range(GRID_H):
		for x in range(GRID_W):
			if _grid[y][x] != DungeonTiles.TileType.VOID:
				continue
			var adj_floor := false
			for ny in [y - 1, y + 1]:
				if ny >= 0 and ny < GRID_H:
					if _grid[ny][x] == DungeonTiles.TileType.FLOOR:
						adj_floor = true
						break
			if not adj_floor:
				for nx in [x - 1, x + 1]:
					if nx >= 0 and nx < GRID_W:
						if _grid[y][nx] == DungeonTiles.TileType.FLOOR:
							adj_floor = true
							break
			if adj_floor:
				to_wall.append(Vector2i(x, y))

	for pos in to_wall:
		_grid[pos.y][pos.x] = DungeonTiles.TileType.WALL

	# Clean up floating walls (WALL tiles with no FLOOR neighbors)
	var floating: Array = []
	for y in range(GRID_H):
		for x in range(GRID_W):
			if _grid[y][x] != DungeonTiles.TileType.WALL:
				continue
			var has_floor := false
			for ny in [y - 1, y, y + 1]:
				for nx in [x - 1, x, x + 1]:
					if ny >= 0 and ny < GRID_H and nx >= 0 and nx < GRID_W:
						if _grid[ny][nx] == DungeonTiles.TileType.FLOOR:
							has_floor = true
			if not has_floor:
				floating.append(Vector2i(x, y))

	for pos in floating:
		_grid[pos.y][pos.x] = DungeonTiles.TileType.VOID

func _fill_corners() -> void:
	for y in range(GRID_H):
		for x in range(GRID_W):
			if _grid[y][x] != DungeonTiles.TileType.VOID:
				continue
			var has_top: bool = y > 0 and _grid[y - 1][x] == DungeonTiles.TileType.WALL
			var has_bot: bool = y < GRID_H - 1 and _grid[y + 1][x] == DungeonTiles.TileType.WALL
			var has_lft: bool = x > 0 and _grid[y][x - 1] == DungeonTiles.TileType.WALL
			var has_rgt: bool = x < GRID_W - 1 and _grid[y][x + 1] == DungeonTiles.TileType.WALL
			if (has_top and has_lft) or (has_top and has_rgt) or (has_bot and has_lft) or (has_bot and has_rgt):
				_grid[y][x] = DungeonTiles.TileType.WALL

func _add_interior_walls() -> void:
	for _w in range(4):
		var saved := _snapshot_grid()
		_try_add_cross_wall()
		if not _is_fully_connected():
			_restore_grid(saved)

func _snapshot_grid() -> Array:
	var snap: Array = []
	for y in range(GRID_H):
		var row: Array = []
		for x in range(GRID_W):
			row.append(_grid[y][x])
		snap.append(row)
	return snap

func _restore_grid(snap: Array) -> void:
	for y in range(GRID_H):
		for x in range(GRID_W):
			_grid[y][x] = snap[y][x]

func _try_add_cross_wall() -> void:
	var horizontal: bool = rng.randf() < 0.5
	var max_attempts := 30

	for _a in max_attempts:
		var pos: int
		var start_x: int = -1
		var start_y: int = -1
		var end_x: int = -1
		var end_y: int = -1

		if horizontal:
			pos = rng.randi_range(3, GRID_H - 4)
			for x in range(GRID_W):
				if _grid[pos][x] == DungeonTiles.TileType.FLOOR:
					if start_x < 0: start_x = x
					end_x = x
			if start_x < 0 or end_x - start_x < 6:
				continue
			# Check both ends touch WALL
			if (start_x <= 0 or _grid[pos][start_x - 1] != DungeonTiles.TileType.WALL) and \
			   (end_x >= GRID_W - 1 or _grid[pos][end_x + 1] != DungeonTiles.TileType.WALL):
				continue
			_build_wall_line(pos, start_x, end_x, true)
			return
		else:
			pos = rng.randi_range(3, GRID_W - 4)
			for y in range(GRID_H):
				if _grid[y][pos] == DungeonTiles.TileType.FLOOR:
					if start_y < 0: start_y = y
					end_y = y
			if start_y < 0 or end_y - start_y < 6:
				continue
			if (start_y <= 0 or _grid[start_y - 1][pos] != DungeonTiles.TileType.WALL) and \
			   (end_y >= GRID_H - 1 or _grid[end_y + 1][pos] != DungeonTiles.TileType.WALL):
				continue
			_build_wall_line(pos, start_y, end_y, false)
			return

func _build_wall_line(fixed: int, from_a: int, to_a: int, is_horizontal: bool) -> void:
	var mid := (from_a + to_a) / 2
	for i in range(from_a, to_a + 1):
		var x := i if is_horizontal else fixed
		var y := fixed if is_horizontal else i
		if i == mid:
			_grid[y][x] = DungeonTiles.TileType.DOOR
		else:
			_grid[y][x] = DungeonTiles.TileType.WALL

func _is_fully_connected() -> bool:
	# Floodfill from first FLOOR tile found
	var start: Vector2i
	var found := false
	for y in range(GRID_H):
		for x in range(GRID_W):
			if _grid[y][x] == DungeonTiles.TileType.FLOOR or _grid[y][x] == DungeonTiles.TileType.DOOR:
				start = Vector2i(x, y)
				found = true
				break
		if found: break

	if not found:
		return false

	var visited: Array = []
	for y in range(GRID_H):
		visited.append([])
		for x in range(GRID_W):
			visited[y].append(false)

	var stack: Array = [start]
	visited[start.y][start.x] = true
	var reachable := 0

	while stack.size() > 0:
		var pos: Vector2i = stack.pop_back()
		reachable += 1
		for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: int = pos.x + dir.x
			var ny: int = pos.y + dir.y
			if nx < 0 or nx >= GRID_W or ny < 0 or ny >= GRID_H:
				continue
			if visited[ny][nx]:
				continue
			var tile: int = _grid[ny][nx]
			if tile == DungeonTiles.TileType.FLOOR or tile == DungeonTiles.TileType.DOOR:
				visited[ny][nx] = true
				stack.append(Vector2i(nx, ny))

	var total := 0
	for y in range(GRID_H):
		for x in range(GRID_W):
			var t: int = _grid[y][x]
			if t == DungeonTiles.TileType.FLOOR or t == DungeonTiles.TileType.DOOR:
				total += 1

	return reachable == total

func _assign_room_types() -> void:
	# Assign types based on depth from spawn
	_rooms = []
	for ri in _room_registry.size():
		var rd: Dictionary = _room_registry[ri]
		var depth := _compute_depth(ri)
		var rtype: int
		match depth:
			0: rtype = DungeonTiles.RoomType.SPAWN
			1: rtype = DungeonTiles.RoomType.STORAGE
			2: rtype = DungeonTiles.RoomType.HALLWAY
			3: rtype = DungeonTiles.RoomType.TREASURE
			4: rtype = DungeonTiles.RoomType.BOSS
			_: rtype = DungeonTiles.RoomType.HALLWAY
		_rooms.append({
			"x": rd.x, "y": rd.y,
			"w": rd.w, "h": rd.h,
			"type": rtype,
		})

func _compute_depth(ri: int) -> int:
	if ri == 0:
		return 0
	# Simple heuristic: depth increases with room index
	# In a proper BFS, we'd compute distance from spawn
	return mini(ri, 5)

func get_room_at(tx: int, ty: int) -> Dictionary:
	for r in _rooms:
		var rd: Dictionary = r
		if tx >= rd.x and tx < rd.x + rd.w and ty >= rd.y and ty < rd.y + rd.h:
			return rd
	return { "type": DungeonTiles.RoomType.NONE }

extends CanvasLayer

var _layout: Dictionary = {}
var _layout_slots: Array = []
var _slot_nodes: Dictionary = {}
var _inventory: Inventory
var _player: Node3D
var _drag_item: Item = null
var _drag_origin: Vector2i = Vector2i(-1, -1)
var _drag_from_equip: int = -1
var _drop_target: Vector2i = Vector2i(-1, -1)
var _slot_map: Dictionary = {}
var _grid_cells: Array = []
var _grid_rect: Rect2 = Rect2()
var _default_cell_size: Vector2 = Vector2(24, 24)

@onready var panel: Control = $Panel
@onready var drag_texture: TextureRect = $DragItem
@onready var highlight: ColorRect = $Panel/Highlight
@onready var tooltip: Panel = $Tooltip
@onready var tooltip_name: Label = $Tooltip/TooltipName
@onready var tooltip_desc: Label = $Tooltip/TooltipDesc
@onready var tooltip_stats: Label = $Tooltip/TooltipStats
@onready var backdrop: TextureRect = $Panel/Backdrop

const GRID_PAD := 2

func _ready() -> void:
	visible = false
	_load_layout()
	_setup()

func _load_layout() -> void:
	var f: FileAccess = FileAccess.open("res://assets/textures/items/_inventory_layout.json", FileAccess.READ)
	if not f:
		push_error("Inventory layout not found")
		return
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		push_error("Failed to parse inventory layout")
		return
	_layout = json.data
	_layout_slots = _layout.get("slots", [])

func _setup() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		return
	if _player.has_method("get_inventory"):
		_inventory = _player.get_inventory()
	else:
		_inventory = Inventory.new()
	_player.set_meta("inventory", _inventory)

	var tex: Texture2D = load(_layout.get("backdrop", ""))
	if tex:
		backdrop.texture = tex
		backdrop.size = Vector2(tex.get_width(), tex.get_height())

	var bsize: Array = _layout.get("backdrop_size", [320, 351])
	panel.size = Vector2(bsize[0], bsize[1])

	var inv_rect: Rect2
	var equip_sorted: Array = []

	for i in _layout_slots.size():
		var sd: Array = _layout_slots[i]
		var sx: int = sd[0]; var sy: int = sd[1]
		var sw: int = sd[2] - sd[0]; var sh: int = sd[3] - sd[1]
		var stype: String = sd[4]

		var bg := ColorRect.new()
		bg.name = "SlotBG_%d" % i
		bg.position = Vector2(sx, sy)
		bg.size = Vector2(sw, sh)
		bg.color = Color(0.1, 0.1, 0.15, 0.4)
		bg.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.add_child(bg)

		var icon := TextureRect.new()
		icon.name = "SlotIcon_%d" % i
		icon.position = Vector2(sx + 2, sy + 2)
		icon.size = Vector2(sw - 4, sh - 4)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.add_child(icon)

		_slot_nodes[i] = {"bg": bg, "icon": icon, "type": stype, "rect": Rect2(sx, sy, sw, sh)}

		if stype == "inventory":
			_grid_rect = Rect2(sx, sy, sw, sh)
		elif stype == "equip":
			equip_sorted.append({"idx": i, "y": sy, "x": sx})

	var cell_w: float = (_grid_rect.size.x - GRID_PAD * (Inventory.GRID_COLS + 1)) / Inventory.GRID_COLS
	var cell_h: float = (_grid_rect.size.y - GRID_PAD * (Inventory.GRID_ROWS + 1)) / Inventory.GRID_ROWS

	for gy in Inventory.GRID_ROWS:
		for gx in Inventory.GRID_COLS:
			var cx: float = _grid_rect.position.x + GRID_PAD + gx * (cell_w + GRID_PAD)
			var cy: float = _grid_rect.position.y + GRID_PAD + gy * (cell_h + GRID_PAD)
			var cell := TextureRect.new()
			cell.name = "GridCell_%d_%d" % [gx, gy]
			cell.position = Vector2(cx, cy)
			cell.size = Vector2(cell_w, cell_h)
			cell.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			cell.mouse_filter = Control.MOUSE_FILTER_STOP
			cell.modulate = Color(0, 0, 0, 0)
			panel.add_child(cell)
			_grid_cells.append(cell)
	_default_cell_size = Vector2(cell_w, cell_h)

	# Identify equip slots by position
	for entry in equip_sorted:
		var ex: int = entry["x"]
		var ey: int = entry["y"]
		var idx: int = entry["idx"]
		if ey < 60 and ex > 180:
			_slot_map[idx] = Inventory.EquipSlot.RING_1
		elif ey < 60:
			_slot_map[idx] = Inventory.EquipSlot.HEAD
		elif ey > 150 and ex < 100:
			_slot_map[idx] = Inventory.EquipSlot.RING_2
		elif ey > 150:
			_slot_map[idx] = Inventory.EquipSlot.AMULET
		elif ex < 100:
			_slot_map[idx] = Inventory.EquipSlot.RIGHT_HAND
		else:
			_slot_map[idx] = Inventory.EquipSlot.LEFT_HAND

	refresh()

func _mouse_pos() -> Vector2:
	return get_viewport().get_mouse_position()

func cell_rect(gx: int, gy: int) -> Rect2:
	var cell: TextureRect = _grid_cells[gy * Inventory.GRID_COLS + gx]
	return Rect2(cell.position, cell.size)

func footprint_rect(origin_x: int, origin_y: int, w: int, h: int) -> Rect2:
	var first: TextureRect = _grid_cells[origin_y * Inventory.GRID_COLS + origin_x]
	var last: TextureRect = _grid_cells[(origin_y + h - 1) * Inventory.GRID_COLS + (origin_x + w - 1)]
	var pos := first.position
	var sz := (last.position + last.size) - first.position + Vector2(0, 0)
	return Rect2(pos, last.position + last.size - first.position)

func best_origin(mpos: Vector2, w: int, h: int) -> Vector2i:
	# Find the closest cell under cursor
	var cx: int = -1
	var cy: int = -1
	for gy in Inventory.GRID_ROWS:
		for gx in Inventory.GRID_COLS:
			if cell_rect(gx, gy).has_point(mpos):
				cx = gx; cy = gy
				break
		if cx >= 0: break
	if cx < 0:
		return Vector2i(-1, -1)

	# Try to center the item under cursor by finding the best offset
	# The cursor cell becomes somewhere inside the item footprint
	# Try offsets that keep the item in bounds
	var best_dist := INF
	var best := Vector2i(cx, cy)
	for ox in range(cx - w + 1, cx + 1):
		for oy in range(cy - h + 1, cy + 1):
			if ox < 0 or oy < 0 or ox + w > Inventory.GRID_COLS or oy + h > Inventory.GRID_ROWS:
				continue
			if not _inventory._has_room_direct(ox, oy, w, h):
				continue
			# Calculate distance from cursor to center of footprint
			var fp := footprint_rect(ox, oy, w, h)
			var fp_center := fp.position + fp.size * 0.5
			var dist := fp_center.distance_to(mpos)
			if dist < best_dist:
				best_dist = dist
				best = Vector2i(ox, oy)
	if best_dist < INF:
		return best
	return Vector2i(-1, -1)

func refresh() -> void:
	if not _inventory:
		return
	for node_idx in _slot_nodes:
		var sn: Dictionary = _slot_nodes[node_idx]
		if sn["type"] != "equip":
			continue
		var eslot: int = _slot_map.get(node_idx, -1)
		var item: Item = _inventory.get_equipped(eslot) if eslot >= 0 else null
		var tex_rect: TextureRect = sn["icon"]
		if item:
			tex_rect.texture = item.get_texture()
			tex_rect.modulate = Color(1, 1, 1, 1)
		else:
			tex_rect.texture = null
			tex_rect.modulate = Color(0, 0, 0, 0)

	for cell in _grid_cells:
		cell.texture = null
		cell.modulate = Color(0, 0, 0, 0)

	for gy in Inventory.GRID_ROWS:
		for gx in Inventory.GRID_COLS:
			var item: Item = _inventory.get_at(gx, gy)
			if not item:
				continue
			var origin := _inventory.find_item(item)
			if origin.x != gx or origin.y != gy:
				continue
			var cell: TextureRect = _grid_cells[gy * Inventory.GRID_COLS + gx]
			if item:
				cell.texture = item.get_texture()
				cell.modulate = Color(1, 1, 1, 1)
				if item.grid_width > 1 or item.grid_height > 1:
					cell.size = footprint_rect(gx, gy, item.grid_width, item.grid_height).size

func _update_item_visual() -> void:
	for gy in Inventory.GRID_ROWS:
		for gx in Inventory.GRID_COLS:
			var cell: TextureRect = _grid_cells[gy * Inventory.GRID_COLS + gx]
			cell.size = _default_cell_size
	refresh()

func toggle() -> void:
	visible = not visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if visible:
		_update_item_visual()
	else:
		if _drag_item:
			_cancel_drag()

func _show_tooltip(item: Item) -> void:
	if not item:
		_hide_tooltip()
		return
	tooltip_name.text = item.name
	var cat: String = item.category
	var desc: String = item.description
	tooltip_desc.text = cat + "\n" + desc
	var stats_text: String = ""
	if item.stats.has("min_damage"):
		var dmg_min: int = item.stats.min_damage
		var dmg_max: int = item.stats.max_damage
		stats_text += "Damage: %d-%d" % [dmg_min, dmg_max]
	if item.stats.has("defense"):
		stats_text += "\nDefense: %d" % item.stats.defense
	tooltip_stats.text = stats_text
	tooltip.visible = true
	tooltip.size = Vector2(200, 80)
	_update_tooltip_pos()

func _hide_tooltip() -> void:
	tooltip.visible = false

func _update_tooltip_pos() -> void:
	var mp: Vector2 = _mouse_pos()
	tooltip.global_position = mp + Vector2(15, 15)
	if tooltip.global_position.y + tooltip.size.y > get_viewport().size.y:
		tooltip.global_position.y = mp.y - tooltip.size.y - 5
	if tooltip.global_position.x + tooltip.size.x > get_viewport().size.x:
		tooltip.global_position.x = mp.x - tooltip.size.x - 5

func _process(_delta: float) -> void:
	if not visible or not _inventory:
		return
	if _drag_item and drag_texture.visible:
		_update_drag_pos()

	var mpos: Vector2 = panel.get_local_mouse_position()
	_update_highlight(mpos)

	var hovered_item: Item = _get_hovered_item(mpos)
	if hovered_item:
		_show_tooltip(hovered_item)
	else:
		_hide_tooltip()

func _update_highlight(mpos: Vector2) -> void:
	if not _drag_item:
		highlight.visible = false
		return

	var best := best_origin(mpos, _drag_item.grid_width, _drag_item.grid_height)
	if best.x >= 0:
		var fp := footprint_rect(best.x, best.y, _drag_item.grid_width, _drag_item.grid_height)
		highlight.position = fp.position
		highlight.size = fp.size
		highlight.visible = true
	else:
		highlight.visible = false

func _get_hovered_item(mpos: Vector2) -> Item:
	for node_idx in _slot_nodes:
		var sn: Dictionary = _slot_nodes[node_idx]
		if not sn["rect"].has_point(mpos):
			continue
		if sn["type"] == "equip":
			var eslot: int = _slot_map.get(node_idx, -1)
			if eslot >= 0:
				return _inventory.get_equipped(eslot)
		elif sn["type"] == "inventory":
			for gy in Inventory.GRID_ROWS:
				for gx in Inventory.GRID_COLS:
					var cell: TextureRect = _grid_cells[gy * Inventory.GRID_COLS + gx]
					if Rect2(cell.position, cell.size).has_point(mpos):
						return _inventory.get_at(gx, gy)
	return null

func _input(event: InputEvent) -> void:
	if not visible or not _inventory:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mpos: Vector2 = panel.get_local_mouse_position()
		if _drag_item:
			_place_item(mpos)
		else:
			_pick_item(mpos)

func _find_slot(mpos: Vector2) -> int:
	for i in _slot_nodes:
		var sn: Dictionary = _slot_nodes[i]
		if sn["rect"].has_point(mpos):
			return i
	return -1

func _pick_item(mpos: Vector2) -> void:
	var idx := _find_slot(mpos)
	if idx >= 0:
		var sn: Dictionary = _slot_nodes[idx]
		if sn["type"] == "equip":
			var eslot: int = _slot_map.get(idx, -1)
			if eslot >= 0:
				var item: Item = _inventory.get_equipped(eslot)
				if item:
					_drag_item = item
					_drag_origin = Vector2i(-1, -1)
					_drag_from_equip = eslot
					_inventory.unequip(eslot)
					_update_item_visual()
					_show_drag(item)
			return

	var gpos := _grid_cell_at(mpos)
	if gpos.x >= 0:
		var item: Item = _inventory.get_at(gpos.x, gpos.y)
		if item:
			var origin := _inventory.find_item(item)
			_drag_item = item
			_drag_origin = origin
			_drag_from_equip = -1
			_inventory._remove(item)
			_update_item_visual()
			_show_drag(item)

func _place_item(mpos: Vector2) -> void:
	if not _drag_item:
		return
	highlight.visible = false

	var panel_rect := Rect2(Vector2(0, 0), panel.size)
	if not panel_rect.has_point(mpos):
		_drop_to_world(_drag_item)
		_cancel_drag()
		return

	var idx := _find_slot(mpos)
	if idx >= 0 and _slot_nodes[idx]["type"] == "equip":
		var eslot: int = _slot_map.get(idx, -1)
		if eslot >= 0:
			var allowed: Array = Inventory.EQUIP_SLOT_CATEGORIES.get(eslot, [])
			if _drag_item.category in allowed:
				var old: Item = _inventory.unequip(eslot)
				_inventory.equip(_drag_item, eslot)
				if old and not _inventory.add_item(old):
					_drop_to_world(old)
				_cancel_drag()
				return

	var gpos := best_origin(mpos, _drag_item.grid_width, _drag_item.grid_height)
	if gpos.x >= 0:
		var existing: Item = _inventory.get_at(gpos.x, gpos.y)
		if existing:
			if existing == _drag_item:
				_inventory._place(_drag_item, gpos.x, gpos.y)
				_cancel_drag()
				return
			# Swap
			if _drag_origin.x >= 0:
				_inventory._remove(existing)
				_inventory._place(_drag_item, gpos.x, gpos.y)
				_drag_item = existing
				_drag_origin = gpos
				_show_drag(existing)
				_update_item_visual()
				return
			return
		else:
			if _inventory._has_room(_drag_item, gpos.x, gpos.y):
				_inventory._place(_drag_item, gpos.x, gpos.y)
				_cancel_drag()
				return

	if _drag_from_equip >= 0:
		_inventory.equip(_drag_item, _drag_from_equip)
	elif _drag_origin.x >= 0:
		_inventory._place(_drag_item, _drag_origin.x, _drag_origin.y)
	else:
		_inventory.add_item(_drag_item)
	_cancel_drag()

func _show_drag(item: Item) -> void:
	var tex: Texture2D = item.get_texture()
	if tex:
		drag_texture.texture = tex
		drag_texture.size = Vector2(36, 36)
		drag_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		drag_texture.visible = true
		drag_texture.modulate = Color(1, 1, 1, 0.8)
	_update_drag_pos()

func _update_drag_pos() -> void:
	drag_texture.global_position = _mouse_pos() - Vector2(18, 18)

func _cancel_drag() -> void:
	_drag_item = null
	_drag_origin = Vector2i(-1, -1)
	_drag_from_equip = -1
	drag_texture.visible = false
	highlight.visible = false
	_update_item_visual()

func _grid_cell_at(mpos: Vector2) -> Vector2i:
	for gy in Inventory.GRID_ROWS:
		for gx in Inventory.GRID_COLS:
			var cell: TextureRect = _grid_cells[gy * Inventory.GRID_COLS + gx]
			if Rect2(cell.position, cell.size).has_point(mpos):
				return Vector2i(gx, gy)
	return Vector2i(-1, -1)

func _drop_to_world(item: Item) -> void:
	var pickup_scene := preload("res://scenes/fx/item_pickup.tscn")
	var world_node: Node = pickup_scene.instantiate()
	if world_node.has_method("init"):
		world_node.call("init", item)
	get_tree().current_scene.add_child(world_node)
	if _player:
		var dir := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		world_node.global_position = _player.global_position + dir * 2.0 + Vector3(0, -0.4, 0)

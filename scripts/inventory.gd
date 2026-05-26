extends Resource
class_name Inventory

signal grid_changed
signal item_equipped(item: Item, slot_name: String)
signal item_unequipped(item: Item, slot_name: String)

const GRID_COLS := 10
const GRID_ROWS := 4

enum EquipSlot {
	NONE = -1,
	RIGHT_HAND,
	LEFT_HAND,
	HEAD,
	TORSO,
	RING_1,
	RING_2,
	AMULET,
}

const EQUIP_SLOT_NAMES := {
	EquipSlot.RIGHT_HAND: "Weapon",
	EquipSlot.LEFT_HAND: "Shield",
	EquipSlot.HEAD: "Head",
	EquipSlot.TORSO: "Torso",
	EquipSlot.RING_1: "Ring L",
	EquipSlot.RING_2: "Ring R",
	EquipSlot.AMULET: "Amulet",
}

const EQUIP_SLOT_CATEGORIES := {
	EquipSlot.RIGHT_HAND: ["Sword", "Axe", "Mace", "Dagger", "Staff", "Bow"],
	EquipSlot.LEFT_HAND: ["Shield"],
	EquipSlot.HEAD: ["Helmet", "Headgear"],
	EquipSlot.TORSO: ["Armor"],
	EquipSlot.RING_1: ["Ring"],
	EquipSlot.RING_2: ["Ring"],
	EquipSlot.AMULET: ["Amulet"],
}

# Grid stores item references. Multi-cell items occupy multiple cells.
var _grid: Array = []
var _equip: Dictionary = {}

func _init() -> void:
	_grid.resize(GRID_COLS * GRID_ROWS)
	for i in _grid.size():
		_grid[i] = null
	for slot in EquipSlot.values():
		if slot >= 0:
			_equip[slot] = null

func _idx(x: int, y: int) -> int:
	return y * GRID_COLS + x

func _has_room(item: Item, x: int, y: int) -> bool:
	for dy in item.grid_height:
		for dx in item.grid_width:
			var cx := x + dx
			var cy := y + dy
			if cx >= GRID_COLS or cy >= GRID_ROWS:
				return false
			if _grid[_idx(cx, cy)] != null:
				return false
	return true

func _place(item: Item, x: int, y: int) -> bool:
	if x < 0 or y < 0: return false
	if x + item.grid_width > GRID_COLS: return false
	if y + item.grid_height > GRID_ROWS: return false
	for dy in item.grid_height:
		for dx in item.grid_width:
			_grid[_idx(x + dx, y + dy)] = item
	return true

func _remove(item: Item) -> void:
	for i in _grid.size():
		if _grid[i] == item:
			_grid[i] = null

func _has_room_direct(x: int, y: int, w: int, h: int) -> bool:
	for dy in h:
		for dx in w:
			var cx := x + dx; var cy := y + dy
			if cx >= GRID_COLS or cy >= GRID_ROWS:
				return false
			if _grid[_idx(cx, cy)] != null:
				return false
	return true

func add_item(item: Item) -> bool:
	for y in GRID_ROWS:
		for x in GRID_COLS:
			if _has_room(item, x, y):
				return _place(item, x, y)
	return false

func add_item_at(item: Item, x: int, y: int) -> bool:
	if not _has_room(item, x, y):
		return false
	return _place(item, x, y)

func remove_at(x: int, y: int) -> Item:
	var item := _grid[_idx(x, y)] as Item
	if item:
		_remove(item)
	return item

func get_at(x: int, y: int) -> Item:
	return _grid[_idx(x, y)] as Item

func has_space(item: Item) -> bool:
	for y in GRID_ROWS:
		for x in GRID_COLS:
			if _has_room(item, x, y):
				return true
	return false

func find_item(item: Item) -> Vector2i:
	for y in GRID_ROWS:
		for x in GRID_COLS:
			if _grid[_idx(x, y)] == item:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func equip(item: Item, slot: int) -> bool:
	if not EQUIP_SLOT_CATEGORIES.has(slot):
		return false
	var allowed: Array = EQUIP_SLOT_CATEGORIES[slot]
	if item.category not in allowed:
		return false
	_equip[slot] = item
	item_equipped.emit(item, EQUIP_SLOT_NAMES[slot])
	return true

func unequip(slot: int) -> Item:
	var item := _equip.get(slot) as Item
	if item:
		_equip[slot] = null
		item_unequipped.emit(item, EQUIP_SLOT_NAMES[slot])
	return item

func get_equipped(slot: int) -> Item:
	return _equip.get(slot) as Item

func is_equipped(item: Item) -> bool:
	for slot in _equip:
		if _equip[slot] == item:
			return true
	return false

func find_equip_slot(item: Item) -> int:
	for slot in _equip:
		if _equip[slot] == item:
			return slot
	return -1

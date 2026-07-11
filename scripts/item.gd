extends Resource
class_name Item

@export var id: String = ""
@export var name: String = "Unknown"
@export var category: String = "Misc"
@export var description: String = ""
@export var texture_path: String = ""
@export var scene_path: String = ""

@export var stackable: bool = false
@export var stack_count: int = 1
@export var max_stack: int = 1

@export var stats: Dictionary = {}

@export var str_scale_min: float = 0.15
@export var str_scale_max: float = 0.3
@export var dex_scale_min: float = 0.0
@export var dex_scale_max: float = 0.0

@export var grid_width: int = 1
@export var grid_height: int = 1

@export var equip_slot: String = ""
@export var rarity: String = "common"
@export var attack_type: String = ""

@export var material: String = ""

@export var trail_type: String = "tracer_modulated"
@export var trail_offset: Vector3 = Vector3(0.036, 0.38, 0.023)
@export var trail_width: float = 0.55
@export var trail_color: Color = Color(1.0, 0.7, 0.2)
@export var trail_max_samples: int = 15
var trail_params: Dictionary = {}

@export var effects: Array[Dictionary] = []

@export var color_modulate: Color = Color.WHITE

var texture: Texture2D = null

func load_texture() -> Texture2D:
	if not texture and texture_path:
		texture = load(texture_path)
	return texture

func get_texture() -> Texture2D:
	return load_texture()

func get_world_scene() -> PackedScene:
	if scene_path.is_empty():
		return null
	return load(scene_path)

static func from_dict(data: Dictionary) -> Item:
	var item := Item.new()
	item.id = data.get("id", "")
	item.name = data.get("name", "Unknown")
	item.category = data.get("cat", "Misc")
	item.description = data.get("desc", "")
	var icon: String = data.get("icon", "")
	if not icon.is_empty():
		item.texture_path = "res://assets/textures/items/" + icon
	var scene: String = data.get("scene", "")
	if not scene.is_empty():
		item.scene_path = "res://assets/models/weapons/" + scene
	var grid: Array = data.get("grid", [])
	if grid.size() >= 2:
		item.grid_width = grid[0]
		item.grid_height = grid[1]
	item.equip_slot = data.get("slot", "")
	item.rarity = data.get("rarity", "common")
	item.material = data.get("material", "")
	item.attack_type = data.get("atk", "")
	item.stackable = data.get("stack", false)
	item.max_stack = data.get("max_stack", 1)
	item.stats = data.get("stats", {})

	var scale: Dictionary = data.get("scale", {})
	if scale:
		item.str_scale_min = scale.get("str_min", 0.15)
		item.str_scale_max = scale.get("str_max", 0.3)
		item.dex_scale_min = scale.get("dex_min", 0.0)
		item.dex_scale_max = scale.get("dex_max", 0.0)

	var trail: Dictionary = data.get("trail", {})
	if trail:
		item.trail_type = trail.get("type", "tracer_modulated")
		item.trail_params = trail.duplicate()
		var ofs: Array = trail.get("ofs", [])
		if ofs.size() >= 3:
			item.trail_offset = Vector3(ofs[0], ofs[1], ofs[2])
		item.trail_width = trail.get("w", 0.55)
		var col: Array = trail.get("col", [])
		if col.size() >= 3:
			item.trail_color = Color(col[0], col[1], col[2])
		item.trail_max_samples = trail.get("len", 15)

	item.effects.clear()
	var fx_raw: Array = data.get("fx", [])
	for entry in fx_raw:
		item.effects.append(entry as Dictionary)
	var mod_arr: Array = data.get("mod", [])
	if mod_arr.size() >= 3:
		item.color_modulate = Color(mod_arr[0], mod_arr[1], mod_arr[2])
	return item

static func drop_sound(item: Item) -> String:
	if item.material:
		match item.material:
			"metal": return "item_metal"
			"leather": return "item_leather"
			"cloth": return "item_cloth"
			"wood": return "item_wood"
			"stone": return "item_stone"
	match item.category:
		"Sword", "Axe", "Dagger": return "item_metal"
		"Mace": return "item_metal_heavy"
		"Shield", "Armor", "Headgear": return "item_leather"
		"Bow": return "item_wood"
		"Ring", "Amulet": return "item_metal"
		"Potion": return "potion_drink"
		_: return "ui_click"

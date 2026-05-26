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

@export var grid_width: int = 1
@export var grid_height: int = 1

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
	item.category = data.get("category", "Misc")
	item.description = data.get("desc", "")
	item.texture_path = data.get("texture_path", "")
	item.scene_path = data.get("scene_path", "")
	item.grid_width = data.get("grid_width", 1)
	item.grid_height = data.get("grid_height", 1)
	item.stats = data.get("stats", {})
	var stack = data.get("stackable", false)
	item.stackable = stack
	item.max_stack = data.get("max_stack", 1)
	return item

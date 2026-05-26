extends Marker3D

@export var target: Node3D
@export var follow_speed: float = 100.0
@export var zoom_distance: float = 10.0
@export var zoom_min: float = 4.0
@export var zoom_max: float = 25.0

func _ready() -> void:
	if not target:
		target = get_node_or_null("../Howard")
	if not target:
		target = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not target:
		return
	var offset := Vector3(0.0, zoom_distance * 1.4, zoom_distance)
	var target_pos := target.global_position + offset
	global_position = global_position.lerp(target_pos, min(1.0, follow_speed * delta))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_distance = max(zoom_min, zoom_distance - 2.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_distance = min(zoom_max, zoom_distance + 2.0)

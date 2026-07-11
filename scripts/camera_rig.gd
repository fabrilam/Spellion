extends Marker3D

@export var target: Node3D
@export var follow_speed: float = 100.0
@export var zoom_min: float = 1.5
@export var zoom_max: float = 40.0
@export var zoom_speed: float = 6.0

var _zoom_target: float = 10.0
var _zoom_current: float = 10.0

func _ready() -> void:
	if not target:
		target = get_node_or_null("../Howard")
	if not target:
		target = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not target:
		return
	# Don't follow when in first-person mode
	var fp_cam := get_node_or_null("../Howard/Camera_FPV")
	if fp_cam and fp_cam.current:
		return
	_zoom_current = lerp(_zoom_current, _zoom_target, min(1.0, zoom_speed * delta))
	var offset := Vector3(0.0, _zoom_current * 1.4, _zoom_current)
	var target_pos := target.global_position + offset
	global_position = global_position.lerp(target_pos, min(1.0, follow_speed * delta))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_target = max(zoom_min, _zoom_target - 0.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_target = min(zoom_max, _zoom_target + 0.5)

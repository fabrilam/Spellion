extends CanvasLayer

var _y_offset: float = 0.0: set = _set_y_offset

func _set_y_offset(val: float) -> void:
	_y_offset = val
	$Label.position.y = val

func init(amount: float, world_pos: Vector3) -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		queue_free()
		return
	var screen_pos := cam.unproject_position(world_pos + Vector3(0, 0.5, 0))
	var label = $Label as Label
	if not label:
		return
	label.text = str(ceil(amount))
	offset = screen_pos
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "_y_offset", -60.0, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.4)
	tween.tween_callback(queue_free).set_delay(1.3)

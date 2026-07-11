extends Control

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	visible = player and player.has_method("is_fp_mode") and player.is_fp_mode()
	queue_redraw()

func _draw() -> void:
	var c := Vector2(16, 16)
	var col := Color(1, 1, 1, 0.85)
	draw_circle(c, 10.0, Color(0, 0, 0, 0.25), false, 1.5)
	draw_circle(c, 10.0, col, false, 1.5)
	draw_circle(c, 2.5, col)

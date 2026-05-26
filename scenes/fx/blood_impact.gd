extends AnimatedSprite3D

func _ready() -> void:
	play("default")
	animation_finished.connect(queue_free)

	# spawn particles from the impact
	var spray := preload("res://scenes/fx/blood_spray.tscn").instantiate()
	get_parent().add_child(spray)
	spray.global_position = global_position

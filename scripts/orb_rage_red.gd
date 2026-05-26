extends Area3D

@export var duration: float = 10.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(180.0).timeout.connect(queue_free)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_apply_rage_to_all(duration)
		AudioManager.play_sfx("orb_pickup")
		queue_free()

func _apply_rage_to_all(dur: float) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("apply_rage"):
			enemy.call("apply_rage", dur)

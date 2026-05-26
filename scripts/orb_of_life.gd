extends Area3D

@export var heal_amount: float = 15.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(180.0).timeout.connect(queue_free)

func _on_body_entered(body: Node) -> void:
	if body.has_method("heal"):
		body.call("heal", heal_amount)
		AudioManager.play_sfx("orb_pickup")
		queue_free()

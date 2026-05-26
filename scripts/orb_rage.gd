extends Area3D

var _falling: bool = true
var _fall_speed: float = 3.0
var _wobble_time: float = 0.0
var _wobble_amp: float = 0.3
var _wobble_freq: float = 1.5
var _base_x: float
var _base_z: float

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(180.0).timeout.connect(queue_free)
	var p := position
	_base_x = p.x
	_base_z = p.z

func _physics_process(delta: float) -> void:
	if not _falling:
		return
	_wobble_time += delta
	var pos: Vector3 = position
	pos.y -= _fall_speed * delta
	pos.x = _base_x + sin(_wobble_time * _wobble_freq) * _wobble_amp
	pos.z = _base_z + cos(_wobble_time * _wobble_freq * 0.7) * _wobble_amp
	if pos.y <= 0.0:
		pos.y = 0.0
		_falling = false
	position = pos

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("consume_orb"):
			if not body.call("consume_orb"):
				return
		AudioManager.play_sfx("orb_pickup")
		queue_free()

extends RigidBody3D

@export var speed: float = 20.0
@export var damage: float = 25.0

var _direction: Vector3

func _ready() -> void:
	body_entered.connect(_on_hit)

func init(dir: Vector3, dmg: float) -> void:
	_direction = dir.normalized()
	damage = dmg
	linear_velocity = _direction * speed

func _on_hit(body: Node) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
	queue_free()

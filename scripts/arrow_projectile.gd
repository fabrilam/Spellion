extends Node3D

@export var speed: float = 30.0
@export var damage: float = 25.0

var _direction: Vector3
var _stuck := false
var _area: Area3D = null

func _ready() -> void:
	_area = Area3D.new()
	_area.name = "Hitbox"
	_area.collision_mask = 1
	var col := CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(0.3, 1.2, 0.3)
	col.position = Vector3(0, -0.5, 0)
	_area.add_child(col)
	_area.body_entered.connect(_on_hit)
	add_child(_area)

func init(dir: Vector3, dmg: float) -> void:
	_direction = dir.normalized()
	damage = dmg
	var up := Vector3.UP
	if abs(_direction.dot(up)) > 0.99:
		up = Vector3.FORWARD
	transform.basis = Basis.looking_at(_direction, up)

func _physics_process(delta: float) -> void:
	if _stuck:
		return
	global_position += _direction * speed * delta

func _on_hit(body: Node) -> void:
	if _stuck or not is_instance_valid(body):
		return
	if body.is_in_group("player"):
		return
	_stuck = true
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
		AudioManager.play_sfx("arrow_impact")
		if body.has_method("stun"):
			body.call("stun", 1.5)
		reparent(body, true)

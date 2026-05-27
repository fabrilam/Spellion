extends Node3D

@export var speed: float = 20.0
@export var damage: float = 25.0

var _direction: Vector3
var _exploding := false
var _area: Area3D = null

func _ready() -> void:
	_area = Area3D.new()
	_area.name = "Hitbox"
	_area.collision_mask = 1
	var col := CollisionShape3D.new()
	col.shape = SphereShape3D.new()
	col.shape.radius = 0.3
	_area.add_child(col)
	_area.body_entered.connect(_on_hit)
	add_child(_area)

func init(dir: Vector3, dmg: float) -> void:
	_direction = dir.normalized()
	damage = dmg

func _physics_process(delta: float) -> void:
	if _exploding:
		return
	global_position += _direction * speed * delta

func _on_hit(body: Node) -> void:
	if _exploding or not is_instance_valid(body):
		return
	if body.is_in_group("player"):
		return
	_exploding = true
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
	AudioManager.play_sfx("fireball")
	_area.collision_mask = 0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3(2.0, 2.0, 2.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	# Fade mesh material
	var mesh = $Mesh as MeshInstance3D
	if mesh and mesh.material_override:
		var mat := mesh.material_override.duplicate() as StandardMaterial3D
		if mat:
			mat.transparency = 1
			mesh.material_override = mat
			tween.tween_property(mat, "albedo_color:a", 0.0, 0.4)
			tween.tween_property(mat, "emission_energy_multiplier", 0.0, 0.4)
	var light = $Mesh/Light as OmniLight3D
	if light:
		tween.tween_property(light, "light_energy", 0.0, 0.3)
	tween.tween_callback(queue_free).set_delay(0.5)

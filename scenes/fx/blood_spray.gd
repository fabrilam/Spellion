extends Node3D

const COUNT := 6
var _decal_scene = preload("res://scenes/fx/blood_decal.tscn")

var _tex := [
	preload("res://assets/textures/fx/decal_1.png"),
	preload("res://assets/textures/fx/decal_2.png"),
	preload("res://assets/textures/fx/decal_3.png"),
	preload("res://assets/textures/fx/decal_4.png"),
	preload("res://assets/textures/fx/decal_5.png"),
]

var _parts: Array[MeshInstance3D] = []
var _mats: Array[StandardMaterial3D] = []
var _vels: Array[Vector3] = []
var _lives: Array[float] = []

func _ready() -> void:
	randomize()
	for i in COUNT:
		var m := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(0.6, 0.6)
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = _tex[randi() % _tex.size()]
		mat.albedo_color = Color(0.7, 0.0, 0.0, 1.0)
		mat.billboard_mode = StandardMaterial3D.BILLBOARD_ENABLED
		mat.cull_mode = StandardMaterial3D.CULL_DISABLED
		mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
		m.material_override = mat
		m.mesh = quad
		m.scale = Vector3(1.0, 1.0, 1.0)
		var angle := randf() * TAU
		var dist := randf_range(0.2, 0.8)
		m.position = Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		add_child(m)
		_parts.append(m)
		_mats.append(mat)
		var dir := Vector3(randf_range(-0.6, 0.6), randf_range(0.5, 1.0), randf_range(-0.6, 0.6)).normalized()
		_vels.append(dir * randf_range(4.0, 8.0))
		_lives.append(randf_range(0.3, 0.7))

func _process(delta: float) -> void:
	var alive := 0
	for i in _parts.size():
		var m := _parts[i]
		if not m.visible:
			continue
		_lives[i] -= delta
		if _lives[i] <= 0.0:
			_spawn_decal(m.global_position)
			m.visible = false
			continue
		alive += 1
		_vels[i].y -= 15.0 * delta
		m.position += _vels[i] * delta
		var fade: float = clamp(_lives[i] / 0.2, 0.0, 1.0)
		_mats[i].albedo_color.a = fade
	if alive == 0:
		queue_free()

func _spawn_decal(world_pos: Vector3) -> void:
	var parent := get_parent()
	if not is_instance_valid(parent):
		return
	var d := _decal_scene.instantiate()
	parent.add_child(d)
	var decal_y: float = -0.49
	if world_pos.z > 0.0:
		decal_y = 0.21
	d.global_position = Vector3(world_pos.x, decal_y, world_pos.z)

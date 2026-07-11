extends Node3D

var _decal_floor = preload("res://scenes/fx/blood_decal.tscn")
var _decal_wall = preload("res://scenes/fx/blood_decals_wall.tscn")

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
var _hit: Array[bool] = []
var _space: PhysicsDirectSpaceState3D = null

const GRAVITY: float = -15.0
const DROPLET_COUNT: int = 5

func _ready() -> void:
	randomize()
	_space = get_world_3d().direct_space_state
	for i in DROPLET_COUNT:
		var m := MeshInstance3D.new()
		var qs := randf_range(0.15, 0.4)
		var quad := QuadMesh.new()
		quad.size = Vector2(qs, qs)
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = _tex[randi() % _tex.size()]
		mat.albedo_color = Color(0.6, 0.0, 0.0, 1.0)
		mat.billboard_mode = StandardMaterial3D.BILLBOARD_ENABLED
		mat.cull_mode = StandardMaterial3D.CULL_DISABLED
		mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
		m.material_override = mat
		m.mesh = quad
		add_child(m)
		_parts.append(m)
		_mats.append(mat)
		var dir := Vector3(randf_range(-0.8, 0.8), randf_range(0.4, 1.0), randf_range(-0.8, 0.8)).normalized()
		_vels.append(dir * randf_range(3.0, 8.0))
		_lives.append(randf_range(1.5, 3.0))
		_hit.append(false)

func _process(delta: float) -> void:
	var alive := 0
	for i in _parts.size():
		var m := _parts[i]
		if _hit[i]:
			continue
		_lives[i] -= delta
		if _lives[i] <= 0.0:
			m.visible = false
			_hit[i] = true
			continue
		alive += 1
		var last_pos := m.global_position
		_vels[i].y += GRAVITY * delta
		m.global_position += _vels[i] * delta
		# Raycast from last_pos to new_pos
		if _space:
			var q := PhysicsRayQueryParameters3D.new()
			q.from = last_pos
			q.to = m.global_position
			q.collision_mask = 1
			q.exclude = [self]
			var r := _space.intersect_ray(q)
			if r:
				m.global_position = r.position
				_on_hit(i, r.position, r.normal)
		# Fade as life runs out
		var fade: float = clamp(_lives[i] / 0.3, 0.0, 1.0)
		_mats[i].albedo_color.a = min(_mats[i].albedo_color.a, fade)
	if alive == 0:
		queue_free()

func _on_hit(idx: int, hit_pos: Vector3, normal: Vector3) -> void:
	_hit[idx] = true
	_parts[idx].visible = false
	var parent := get_parent()
	if not is_instance_valid(parent):
		return
	if normal.y > 0.7:
		# Floor decal
		var d := _decal_floor.instantiate()
		parent.add_child(d)
		d.init(hit_pos)
	else:
		# Wall decal with drip
		var d := _decal_wall.instantiate()
		parent.add_child(d)
		d.init(hit_pos, normal, _space)

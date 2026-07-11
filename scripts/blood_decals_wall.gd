extends Node3D

var _tex := [
	preload("res://assets/textures/fx/decal_1.png"),
	preload("res://assets/textures/fx/decal_2.png"),
	preload("res://assets/textures/fx/decal_3.png"),
	preload("res://assets/textures/fx/decal_4.png"),
	preload("res://assets/textures/fx/decal_5.png"),
]

var _max_drip: float = 2.5
var _drip_target: float = 1.5

func init(hit_pos: Vector3, hit_normal: Vector3, space: PhysicsDirectSpaceState3D) -> void:
	global_position = hit_pos + hit_normal * 0.01
	# Orient to face along normal
	var up := Vector3.UP
	if abs(hit_normal.dot(Vector3.UP)) > 0.99:
		up = Vector3.FORWARD
	look_at(global_position + hit_normal, up)
	rotate_object_local(Vector3.RIGHT, PI / 2.0)
	# Find floor below for drip length
	var q := PhysicsRayQueryParameters3D.new()
	q.from = hit_pos
	q.to = hit_pos + Vector3.DOWN * 10.0
	q.collision_mask = 1
	var r := space.intersect_ray(q)
	if r:
		_drip_target = min(hit_pos.y - r.position.y, _max_drip)
	else:
		_drip_target = 1.5

func _ready() -> void:
	var m := MeshInstance3D.new()
	var quad := QuadMesh.new()
	var w := randf_range(1.5, 3.0)
	quad.size = Vector2(w, _max_drip)
	m.mesh = quad
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _tex[randi() % _tex.size()]
	mat.albedo_color = Color(0.6, 0.0, 0.0, randf_range(0.7, 1.0))
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.material_override = mat
	# Position mesh so top edge is at hit point
	m.position.y = -_max_drip / 2.0
	add_child(m)
	# Animate drip: scale from line to full drip length
	var target_y: float = _drip_target / _max_drip if _max_drip > 0 else 1.0
	m.scale = Vector3(1.0, 0.01, 1.0)
	var tw := create_tween()
	tw.tween_property(m, "scale:y", target_y, 0.4).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 4.0).set_delay(8.0)
	tw.chain().tween_callback(queue_free)

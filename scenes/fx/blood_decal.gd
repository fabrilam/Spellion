extends Node3D

var _tex := [
	preload("res://assets/textures/fx/decal_1.png"),
	preload("res://assets/textures/fx/decal_2.png"),
	preload("res://assets/textures/fx/decal_3.png"),
	preload("res://assets/textures/fx/decal_4.png"),
	preload("res://assets/textures/fx/decal_5.png"),
]

func init(world_pos: Vector3) -> void:
	# Raycast down to find actual floor Y
	var space := get_world_3d().direct_space_state
	if space:
		var q := PhysicsRayQueryParameters3D.new()
		q.from = world_pos + Vector3.UP * 2.0
		q.to = world_pos + Vector3.DOWN * 10.0
		q.collision_mask = 1
		var r := space.intersect_ray(q)
		if r:
			global_position = Vector3(world_pos.x, r.position.y + 0.005, world_pos.z)
		else:
			queue_free()
			return
	else:
		global_position = world_pos
	_start()

func _start() -> void:
	randomize()
	var m := $Decal as MeshInstance3D
	if not m:
		queue_free()
		return

	m.rotation.x = -PI / 2
	m.rotation.z = randf() * TAU
	var final_scale := randf_range(0.9, 2.7)
	m.scale = Vector3(0.01, 1.0, 0.01)

	var mat := m.material_override.duplicate() as StandardMaterial3D
	if not mat:
		queue_free()
		return

	m.material_override = mat
	mat.albedo_texture = _tex[randi() % _tex.size()]
	mat.albedo_color.a = randf_range(0.6, 1.0)

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(m, "scale", Vector3(final_scale, 1.0, final_scale), 0.3).set_ease(Tween.EASE_OUT)
	tw.tween_property(mat, "albedo_color:a", 0.0, 4.0).set_delay(8.0)
	tw.chain().tween_callback(_kill)

func _kill() -> void:
	var m := $Decal as MeshInstance3D
	if m:
		var mat := m.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color.a = 0.0
	queue_free()

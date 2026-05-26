extends Node3D

@export var lifetime: float = 12.0
@export var fade_start: float = 8.0

var _decals: Array[MeshInstance3D] = []
var _initial_alphas: Dictionary = {}

func _ready() -> void:
	randomize()
	for child in get_children():
		if child is MeshInstance3D:
			_decals.append(child)
	_scatter()
	_kill_timer()

func _scatter() -> void:
	for d in _decals:
		d.rotation.x = -PI / 2
		d.rotation.z = randf() * TAU
		var s := 0.3 + randf() * 0.5
		d.scale = Vector3(s, 1.0, s)
		var offset := Vector2(randf_range(-0.6, 0.6), randf_range(-0.6, 0.6))
		d.position = Vector3(offset.x, 0.005, offset.y)
		var mat: StandardMaterial3D = d.material_override
		if mat:
			mat.albedo_color.a = randf_range(0.4, 0.9)
			_initial_alphas[d] = mat.albedo_color.a

func _kill_timer() -> void:
	var tw := create_tween()
	var delay_tween := create_tween()
	delay_tween.tween_callback(_start_fade).set_delay(fade_start)
	tw.tween_interval(lifetime)
	tw.tween_callback(queue_free)

func _start_fade() -> void:
	var t := lifetime - fade_start
	for d in _decals:
		var mat: StandardMaterial3D = d.material_override
		if mat and _initial_alphas.has(d):
			var tw := create_tween()
			tw.tween_property(mat, "albedo_color:a", 0.0, t)

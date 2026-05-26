extends Node3D

@export var fade_alpha: float = 0.15

class SurfaceMat:
	var mi: MeshInstance3D
	var surf_idx: int
	var mat: Material
	var orig_alpha: float

var _player: Node3D
var _surfaces: Array[SurfaceMat] = []
var _fading: bool = false

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	for mi in find_children("*", "MeshInstance3D"):
		if not mi is MeshInstance3D:
			continue
		var m: MeshInstance3D = mi
		if not m.mesh:
			continue
		for s in m.mesh.get_surface_count():
			var src := m.mesh.surface_get_material(s) as Material
			if not src:
				continue
			var dup := src.duplicate()
			m.set_surface_override_material(s, dup)
			var sm := SurfaceMat.new()
			sm.mi = m
			sm.surf_idx = s
			sm.mat = dup
			if dup is StandardMaterial3D:
				sm.orig_alpha = dup.albedo_color.a
			else:
				sm.orig_alpha = 1.0
			_surfaces.append(sm)

func _process(_delta: float) -> void:
	if not _player or _surfaces.is_empty():
		return
	var pz := _player.global_position.z
	var oz := global_position.z
	var should_fade := oz > pz + 1.0
	if should_fade != _fading:
		_fading = should_fade
		for sm in _surfaces:
			if sm.mat is StandardMaterial3D:
				var std: StandardMaterial3D = sm.mat
				std.albedo_color.a = fade_alpha if should_fade else sm.orig_alpha

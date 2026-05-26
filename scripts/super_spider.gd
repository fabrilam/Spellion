extends "res://scripts/enemy.gd"

func _ready() -> void:
	super()
	display_name = "Super SPIDER"
	_add_red_light()

func _apply_level_stats() -> void:
	super()
	var scl := scale.x * 3.0
	scale = Vector3(scl, scl, scl)
	max_hp *= 3
	hp = max_hp
	attack_damage *= 3
	move_speed *= 0.5
	xp_reward *= 5
	_base_speed = move_speed

func _add_red_light() -> void:
	var light := OmniLight3D.new()
	light.light_color = Color(1, 0.2, 0)
	light.light_energy = 20.0
	light.omni_range = 15.0
	light.shadow_enabled = false
	add_child(light)

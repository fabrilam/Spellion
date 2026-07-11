extends CharacterBody3D

enum Action { MELEE, RANGED }

@export var stats: Stats
@export var inventory: Inventory
var _anim: AnimationPlayer
var _action_cd: float = 0.0
var _current_action: int = Action.MELEE
var _attacking := false
var _sword_hitbox: Area3D = null
var _hit_something := false
var _hp_regen_delay: float = 0.0
var _hp_regen_tick: float = 0.0
var _arrow_visual: Node3D = null
var _bow_firing := false
const _arrow_scene := preload("res://scenes/fx/arrow_projectile.tscn")
var _spells: Array[SpellData] = []
var _current_spell_index: int = 0
var _q_held := false
signal spell_changed(index: int)
var _fp_mode := false
var _fp_camera: Camera3D = null
var _iso_camera: Camera3D = null
var _v_held := false
var _fp_pitch: float = 0.0
var _f5_held := false
var _f9_held := false
var _life_steal: float = 0.0
var _item_db: Dictionary = {}
var _hovered_item: Node = null
var _aim_marker: MeshInstance3D = null
var _trail_active := true
var _trail_positions: Array[Vector3] = []
var _trail_bases: Array[Basis] = []
var _trail_next_position: float = 0.0
var _trail_interval: float = 0.03
var _trail_mesh: MeshInstance3D = null
var _physics_frames := 0

var _weapon_attach: Node3D = null
var _weapon_nodes: Dictionary = {}

func _ready() -> void:
	if not stats:
		stats = Stats.new()
	stats.died.connect(_on_died)
	add_to_group("player")
	var model = get_node("KnightRoot")
	if model:
		_anim = model.get_node("Breathing Idle/AnimationPlayer")
		if _anim and _anim.has_animation("idle_loop"):
			_anim.play("idle_loop", 0.0)
		_fp_camera = get_node_or_null("Camera_FPV")
		var skel = model.find_child("Skeleton3D", true, false)
		if skel:
			_weapon_attach = skel
		for child in model.find_children("*", "BoneAttachment3D", true, false):
			if child.name == "SwordAttach":
				_weapon_attach = child
				_arrow_visual = child.get_node_or_null("ArrowVisual")
			for wpn in child.get_children():
				if wpn.name.begins_with("Weapon"):
					var cat := wpn.name.trim_prefix("Weapon")
					_weapon_nodes[cat] = wpn
					wpn.visible = false
	_iso_camera = get_node("/root/Main/CameraRig/IsometricCamera")

	# Sword hitbox
	_sword_hitbox = Area3D.new()
	_sword_hitbox.name = "SwordHitbox"
	_sword_hitbox.collision_mask = 5
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(3.0, 2.0, 3.0)
	col.shape = shape
	_sword_hitbox.add_child(col)
	_sword_hitbox.position = Vector3(0, 0.5, -1.5)
	_sword_hitbox.monitoring = false
	add_child(_sword_hitbox)

	_setup_inventory()
	_setup_spells()
	_setup_aim_marker()

func _toggle_stats() -> void:
	var ss := get_node_or_null("../StatsScreen")
	if not ss:
		ss = get_node("/root/Main/StatsScreen")
	if ss and ss.has_method("toggle"):
		ss.toggle()

func _setup_inventory() -> void:
	if not inventory:
		inventory = Inventory.new()
	set_meta("inventory", inventory)
	set_meta("stats", stats)

	inventory.item_equipped.connect(_on_item_equipped)
	inventory.item_unequipped.connect(_on_item_unequipped)
	inventory.item_equipped.connect(_on_equip_stats)
	inventory.item_unequipped.connect(_on_unequip_stats)

	# Load item database from JSON
	var f := FileAccess.open("res://assets/textures/items/_item_data.json", FileAccess.READ)
	if f:
		var json_str := f.get_as_text()
		var data: Array = JSON.parse_string(json_str) as Array
		if data:
			for entry in data:
				var item := Item.from_dict(entry)
				_item_db[item.id] = item

	# Starting items
	var start_sword := _item_db.get("sword_shortsword") as Item
	if start_sword:
		var copy: Item = start_sword.duplicate()
		inventory.equip(copy, Inventory.EquipSlot.RIGHT_HAND)
	var start_bow := _item_db.get("bow_poor") as Item
	if start_bow:
		inventory.add_item(start_bow.duplicate())
	for i in 3:
		var lp := _item_db.get("lifepotion") as Item
		if lp:
			inventory.add_item(lp.duplicate())
		var mp := _item_db.get("manapotion") as Item
		if mp:
			inventory.add_item(mp.duplicate())
	var bl := _item_db.get("sword_bloodletter") as Item
	if bl:
		inventory.add_item(bl.duplicate())

	_update_weapon_visibility()
	_apply_equip_stats()

func _setup_aim_marker() -> void:
	_aim_marker = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.15
	cyl.bottom_radius = 0.15
	cyl.height = 0.8
	_aim_marker.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0.5, 0.2, 0.1)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1, 0.5, 0.2)
	mat.emission_energy_multiplier = 2.0
	_aim_marker.material_override = mat
	_aim_marker.visible = false
	add_child(_aim_marker)

func _on_item_equipped(item: Item, slot_name: String) -> void:
	_update_weapon_visibility()
	if not item.attack_type.is_empty():
		if item.attack_type == "ranged":
			_current_action = Action.RANGED
		else:
			_current_action = Action.MELEE
	# Apply innate effects
	for fx in item.effects:
		if fx.get("type") == "life_steal":
			_life_steal = fx.get("val", 0.0)

func _on_item_unequipped(item: Item, slot_name: String) -> void:
	_update_weapon_visibility()
	if slot_name == "RIGHT_HAND":
		_current_action = Action.MELEE
		_life_steal = 0.0

func _on_equip_stats(item: Item, _slot_name: String) -> void:
	_apply_equip_stats()

func _on_unequip_stats(item: Item, _slot_name: String) -> void:
	_apply_equip_stats()

func _apply_equip_stats() -> void:
	if not inventory or not stats:
		return
	var min_dmg: float = 1.0
	var max_dmg: float = 2.0
	var s_min: float = 0.15
	var s_max: float = 0.3
	var atk_spd_mod: float = 0.0
	var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND)
	if weapon:
		min_dmg = weapon.stats.get("min_dmg", 1.0)
		max_dmg = weapon.stats.get("max_dmg", 2.0)
		s_min = weapon.str_scale_min
		s_max = weapon.str_scale_max
		atk_spd_mod = weapon.stats.get("atk_spd", 0.0)
	stats.set_item_melee_damage(min_dmg, max_dmg, s_min, s_max, weapon.dex_scale_min if weapon else 0.0, weapon.dex_scale_max if weapon else 0.0)
	stats.set_attack_speed_mod(atk_spd_mod)
	var bow_bonus := -1.0 if (weapon and weapon.category == "Bow") else 0.0
	stats.set_bow_speed_bonus(bow_bonus)

	# Defense from shield, headgear, armor
	var equip_def: float = 0.0
	for slot in [Inventory.EquipSlot.LEFT_HAND, Inventory.EquipSlot.HEAD, Inventory.EquipSlot.TORSO]:
		var eq := inventory.get_equipped(slot)
		if eq:
			equip_def += eq.stats.get("defense", 0)
	stats.set_equip_defense(equip_def)

func _update_weapon_visibility() -> void:
	if not _weapon_attach:
		return
	for cat in _weapon_nodes:
		_weapon_nodes[cat].visible = false

	var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND)
	if not weapon:
		return

	var cat := weapon.category
	if _weapon_nodes.has(cat):
		_weapon_nodes[cat].visible = true

func get_inventory() -> Inventory:
	return inventory

func _toggle_inventory() -> void:
	var inv_screen := get_node_or_null("../InventoryScreen")
	if not inv_screen:
		inv_screen = get_node("/root/Main/InventoryScreen")
	if inv_screen and inv_screen.has_method("toggle"):
		inv_screen.toggle()

func _show_all_item_labels(v: bool) -> void:
	for node in get_tree().get_nodes_in_group("items"):
		if node.has_method("set_alt_label"):
			node.call("set_alt_label", v)


func _toggle_fp() -> void:
	_fp_mode = not _fp_mode
	if _fp_camera and _iso_camera:
		_fp_camera.current = _fp_mode
		_iso_camera.current = not _fp_mode
	if _fp_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_fp_pitch = _fp_camera.rotation.x if _fp_camera else 0.0
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func is_fp_mode() -> bool:
	return _fp_mode

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fp") or (event is InputEventKey and event.keycode == KEY_V and event.pressed and not event.echo):
		_toggle_fp()
		return
	if _fp_mode and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.003)
		_fp_pitch -= event.relative.y * 0.003
		_fp_pitch = clamp(_fp_pitch, -1.4, 1.4)
		if _fp_camera:
			_fp_camera.rotation.x = _fp_pitch
	if event is InputEventKey and event.keycode == KEY_ALT:
		_show_all_item_labels(event.pressed)

func _is_stats_open() -> bool:
	var ss := get_node_or_null("../StatsScreen")
	if not ss:
		ss = get_node("/root/Main/StatsScreen")
	return ss and ss.visible

func _is_inventory_open() -> bool:
	var inv := get_node_or_null("../InventoryScreen")
	if not inv:
		inv = get_node("/root/Main/InventoryScreen")
	return inv and inv.visible

func _process(delta: float) -> void:
	stats.regen_mana(delta)
	if _hp_regen_delay > 0.0:
		_hp_regen_delay -= delta
	else:
		_hp_regen_tick += delta
		if _hp_regen_tick >= 0.1:
			_hp_regen_tick -= 0.1
			stats.regen_hp(0.1)
	if _action_cd > 0:
		_action_cd -= delta
	if Input.is_key_pressed(KEY_F5):
		if not _f5_held:
			_f5_held = true
			SaveManager.save_game()
	elif _f5_held:
		_f5_held = false
	if Input.is_key_pressed(KEY_F9):
		if not _f9_held:
			_f9_held = true
			SaveManager.load_game()
	elif _f9_held:
		_f9_held = false
	if not _is_stats_open() and not _is_inventory_open() and not _attacking:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _action_cd <= 0:
			if not _hovered_item:
				if _current_action == Action.MELEE:
					_melee_attack()
				elif _current_action == Action.RANGED:
					_ranged_attack()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if _spells.size() > _current_spell_index and _current_spell_index >= 0:
				_cast_current_spell()
	if Input.is_key_pressed(KEY_C) and not _v_held:
		_v_held = true
		get_tree().create_timer(0.2).timeout.connect(func(): _v_held = false)
		_toggle_stats()
	if Input.is_key_pressed(KEY_TAB) and not _v_held:
		_v_held = true
		get_tree().create_timer(0.2).timeout.connect(func(): _v_held = false)
		_toggle_inventory()
	if Input.is_key_pressed(KEY_Q) and not _q_held:
		_q_held = true
		_toggle_spell_menu()
	elif not Input.is_key_pressed(KEY_Q) and _q_held:
		_q_held = false

	# Mouse hover pickup for world items (also works with inventory open)
	if not _is_stats_open():
		var cam: Camera3D = get_viewport().get_camera_3d()
		if cam:
			var from := cam.project_ray_origin(get_viewport().get_mouse_position())
			var dir := cam.project_ray_normal(get_viewport().get_mouse_position())
			var space := get_world_3d().direct_space_state
			var query := PhysicsRayQueryParameters3D.new()
			query.from = from
			query.to = from + dir * 50.0
			query.collision_mask = 8
			var result: Dictionary = space.intersect_ray(query)
			var new_hover: Node = null
			if result:
				var col: Variant = result.get("collider")
				if col is RigidBody3D and col.has_method("set_hovered"):
					new_hover = col
			if new_hover != _hovered_item:
				if _hovered_item and _hovered_item.has_method("set_hovered"):
					_hovered_item.call("set_hovered", false)
				_hovered_item = new_hover
				if _hovered_item and _hovered_item.has_method("set_hovered"):
					_hovered_item.call("set_hovered", true)
			if _hovered_item and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var inv: Inventory = get_inventory()
				if _hovered_item.has_method("pickup_by_mouse"):
					_hovered_item.call("pickup_by_mouse", inv)

			# Aim marker: raycast to find ground
			if _aim_marker:
				var aq := PhysicsRayQueryParameters3D.new()
				aq.from = from
				aq.to = from + dir * 100.0
				aq.collision_mask = 1
				var ar := space.intersect_ray(aq)
				if ar:
					# Bottom-aligned: center + half height
					var half_h: float = 0.4
					var base: Vector3 = ar.position + Vector3.UP * half_h
					# Hide if pointing above player + 2m (inside wall)
					if ar.position.y > global_position.y + 2.0:
						_aim_marker.visible = false
					else:
						_aim_marker.visible = not _hovered_item and not _fp_mode
					# Color cycling + pulse
					var t: float = Time.get_ticks_msec() * 0.001
					var hue: float = fmod(t * 0.3, 1.0)
					var mat := _aim_marker.material_override as StandardMaterial3D
					if mat:
						mat.emission = Color.from_hsv(hue, 0.8, 1.0)
						mat.albedo_color = Color.from_hsv(hue, 0.8, 1.0, 0.1)
					var pulse: float = 1.0 + sin(t * 3.0) * 0.1
					_aim_marker.scale = Vector3(pulse, 1.0, pulse)
					_aim_marker.global_position = base
				else:
					_aim_marker.visible = false

	# Sword trail: continuo, cada frame, ring buffer mantiene cola
	if _trail_active and inventory:
		var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND)
		if weapon:
			_sample_trail()
			if _trail_bases.size() >= 2:
				_build_trail_ribbon()

func _physics_process(delta: float) -> void:
	_physics_frames += 1
	# Delay gravity for ~1s to let physics world (floor, dungeon) settle
	if _physics_frames < 60:
		move_and_slide()
		return

	# Gravity
	velocity.y += -15.0 * delta

	# Gravity
	velocity.y += -15.0 * delta
	var speed := stats.get_speed() if stats else 5.5
	var vx := 0.0
	var vz := 0.0
	if Input.is_key_pressed(KEY_W): vz -= 1
	if Input.is_key_pressed(KEY_S): vz += 1
	if Input.is_key_pressed(KEY_A): vx -= 1
	if Input.is_key_pressed(KEY_D): vx += 1
	var moving := vx != 0.0 or vz != 0.0
	if not _attacking:
		if moving:
			if _fp_mode and _fp_camera:
				var fwd := -_fp_camera.global_transform.basis.z
				var right := _fp_camera.global_transform.basis.x
				var dir := (fwd * (-vz) + right * vx).normalized()
				velocity.x = dir.x * speed
				velocity.z = dir.z * speed
			else:
				var d := Vector3(vx, 0.0, vz).normalized()
				velocity.x = d.x * speed
				velocity.z = d.z * speed
				_rotate_toward_direction(d, delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, speed)
			velocity.z = move_toward(velocity.z, 0.0, speed)
	else:
		velocity *= 0.92
	move_and_slide()
	_update_anim(moving)

func _aim_dir() -> Vector3:
	if _fp_mode and _fp_camera:
		return -_fp_camera.global_transform.basis.z.normalized()
	return -global_transform.basis.z.normalized()

func _rotate_toward_direction(d: Vector3, delta: float) -> void:
	if d.length_squared() < 0.001:
		return
	var target := Basis.looking_at(d, Vector3.UP)
	var from_q := Quaternion(transform.basis)
	var to_q := Quaternion(target)
	transform.basis = Basis(from_q.slerp(to_q, min(1.0, 8.0 * delta)))

func _rotate_toward_mouse() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if not cam: return
	var from: Vector3 = cam.project_ray_origin(get_viewport().get_mouse_position())
	var d: Vector3 = cam.project_ray_normal(get_viewport().get_mouse_position())
	var t: float = -from.y / d.y
	if t <= 0.0: return
	var diff := Vector3((from + d * t).x, global_position.y, (from + d * t).z) - global_position
	if diff.length_squared() < 0.001: return
	transform.basis = Basis.looking_at(diff, Vector3.UP)

var _sword_hit_enemies: Array[Node] = []

func _melee_attack() -> void:
	if not _fp_mode:
		_rotate_toward_mouse()
	var atk_speed := stats.get_attack_speed() if stats else 1.0
	_action_cd = 0.6 / atk_speed
	_attacking = true
	_hit_something = false
	_sword_hit_enemies.clear()
	if _anim:
		_anim.speed_scale = atk_speed
	if _anim.has_animation("Sword1"):
		_anim.play("Sword1", 0.1)
	elif _anim.has_animation("testanim"):
			_anim.play("testanim", 0.1)
	if _sword_hitbox:
		_sword_hitbox.monitoring = true
		_sword_hitbox.monitorable = true
		get_tree().create_timer(0.65 / atk_speed).timeout.connect(_apply_sword_window)
		get_tree().create_timer(0.85 / atk_speed).timeout.connect(func(): _sword_hitbox.monitoring = false)

	# Sword trail: sample from animation start (zero-area quads invisible)
	_trail_positions.clear()
	_trail_bases.clear()
	_trail_active = true
	_trail_next_position = 0.0
	_sample_trail()
	_trail_next_position = _trail_interval

func _sample_trail() -> void:
	var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND) if inventory else null
	if not weapon:
		return
	match weapon.trail_type:
		"tracer_modulated":
			_sample_tracer_modulated()
		_:
			_sample_tracer_modulated()

func _build_trail_ribbon() -> void:
	var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND) if inventory else null
	if not weapon:
		return
	match weapon.trail_type:
		"tracer_modulated":
			_build_tracer_modulated()
		_:
			_build_tracer_modulated()

func _sample_tracer_modulated() -> void:
	if not _weapon_attach:
		return
	var src := _weapon_attach.get_node("SwordTrail") as Node3D
	if not src:
		return
	_trail_positions.append(src.global_position)
	_trail_bases.append(src.global_transform.basis)

func _build_tracer_modulated() -> void:
	var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND) if inventory else null
	var offset_v: Vector3 = weapon.trail_offset if weapon and weapon.trail_offset else Vector3(0, 0.279, 0)
	var hw: float = (weapon.trail_width * 0.5) if weapon else 0.275
	var base_color: Color = weapon.trail_color if weapon else Color(1.0, 1.0, 1.0)
	if weapon and weapon.color_modulate != Color.WHITE:
		base_color = weapon.color_modulate
	var max_samples: int = weapon.trail_max_samples if weapon else 5
	var max_keep: int = max_samples
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var last_p: Vector3
	var kept := 0
	var n := _trail_positions.size()
	for i in n:
		var p: Vector3 = _trail_positions[i] + _trail_bases[i] * offset_v
		if kept > 0 and p.distance_to(last_p) < 0.03:
			continue
		var alpha: float = float(i) / max(n - 1, 1)
		var c: Color = base_color
		c.a = alpha
		st.set_color(c)
		var blade: Vector3 = _trail_bases[i].y.normalized() * hw
		st.add_vertex(p + blade)
		st.add_vertex(p - blade)
		last_p = p
		kept += 1
	if kept < 2:
		return
	var mesh := st.commit()
	if not mesh:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = false
	mat.emission = base_color
	mat.emission_energy_multiplier = 5.0
	mat.transparency = 1
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mi.material_override = mat
	get_tree().current_scene.add_child(mi)
	if _trail_mesh:
		_trail_mesh.queue_free()
	_trail_mesh = mi
	var tw := create_tween()
	tw.tween_property(mat, "emission_energy_multiplier", 0.0, 0.2)
	tw.tween_callback(mi.queue_free).set_delay(0.25)

func _apply_sword_window() -> void:
	if not _sword_hitbox or not _sword_hitbox.monitoring: return
	var dmg_min := stats.get_melee_damage_min() if stats else 5.0
	var dmg_max := stats.get_melee_damage_max() if stats else 5.0
	var dmg := randf_range(dmg_min, dmg_max)
	var bodies := _sword_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body != self and not _sword_hit_enemies.has(body) and body.has_method("take_damage"):
			_sword_hit_enemies.append(body)
			body.call("take_damage", dmg)
			if _life_steal > 0.0:
				stats.heal(dmg * _life_steal)
			if inventory and inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND):
				AudioManager.play_sfx_overlap("sword_impact")
			else:
				AudioManager.play_sfx_random("punch")
			_hit_something = true
	var areas := _sword_hitbox.get_overlapping_areas()
	for area in areas:
		var enemy: Node = area
		if not enemy.has_method("take_damage"):
			enemy = area.get_parent()
		if not _sword_hit_enemies.has(enemy) and enemy.has_method("take_damage"):
			_sword_hit_enemies.append(enemy)
			enemy.call("take_damage", dmg)
			if _life_steal > 0.0:
				stats.heal(dmg * _life_steal)
			if inventory and inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND):
				AudioManager.play_sfx_overlap("sword_impact")
			else:
				AudioManager.play_sfx_random("punch")

func _do_action() -> void:
	var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND)
	if weapon and weapon.category == "Bow":
		_ranged_attack()
		return
	_melee_attack()

func _setup_spells() -> void:
	var fire := SpellData.new()
	fire.id = "fireball"
	fire.name = "Fireball"
	fire.description = "Launches a fireball"
	fire.icon_path = "res://assets/textures/ui/spell_fire.svg"
	fire.mana_cost = 5
	fire.min_val = 12.0
	fire.max_val = 16.0
	fire.color = Color(1, 0.5, 0)

	var heal_data := SpellData.new()
	heal_data.id = "heal"
	heal_data.name = "Heal"
	heal_data.description = "Restores HP"
	heal_data.icon_path = "res://assets/textures/ui/spell_heal.svg"
	heal_data.mana_cost = 10
	heal_data.min_val = 10.0
	heal_data.max_val = 15.0
	heal_data.color = Color(0.2, 0.5, 1)

	_spells = [fire, heal_data]

func get_spells() -> Array[SpellData]:
	return _spells

func get_current_spell() -> SpellData:
	if _current_spell_index >= 0 and _current_spell_index < _spells.size():
		return _spells[_current_spell_index]
	return null

func set_spell_index(idx: int) -> void:
	if idx >= 0 and idx < _spells.size() and idx != _current_spell_index:
		_current_spell_index = idx
		spell_changed.emit(idx)

func _toggle_spell_menu() -> void:
	var hud := get_node_or_null("../HUD")
	if hud and hud.has_method("toggle_spell_menu"):
		hud.toggle_spell_menu()

func _spell_light(color: Color) -> void:
	var light_scene := preload("res://scenes/fx/spell_light.tscn")
	var light := light_scene.instantiate()
	if _weapon_attach:
		_weapon_attach.add_child(light)
		light.light_color = color
	else:
		add_child(light)
		light.position = Vector3(0, 0.5, 0)
		light.light_color = color
	var tween := create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.4)
	tween.tween_callback(light.queue_free)

func _cast_current_spell() -> void:
	if _attacking or not stats or not _spells.size():
		return
	var spell := get_current_spell()
	if not spell:
		return
	if stats.mana < spell.mana_cost:
		return
	if not _fp_mode:
		_rotate_toward_mouse()
	stats.mana -= spell.mana_cost
	var int_spd := 1.0 + (stats.intelligence if stats else 0) * 0.01
	_action_cd = 0.6 / int_spd
	_attacking = true
	_spell_light(spell.color)
	match spell.id:
		"fireball":
			var dmg_base := randf_range(spell.min_val, spell.max_val)
			var dmg := dmg_base + (stats.intelligence if stats else 0) * 0.25
			var dir := _aim_dir()
			if _anim:
				_anim.speed_scale = 4.0 * int_spd
				if _anim.has_animation("magic_attack"):
					_anim.play("magic_attack", 0.1)
				elif _anim.has_animation("Sword1"):
					_anim.play("Sword1", 0.1)
				elif _anim.has_animation("testanim"):
					_anim.play("testanim", 0.1)
			await get_tree().create_timer(0.25 / int_spd).timeout
			if not is_instance_valid(self):
				return
			var proj = preload("res://scenes/projectile.tscn").instantiate()
			proj.init(dir, dmg)
			get_parent().add_child(proj)
			proj.global_position = _weapon_attach.global_position if _weapon_attach else (global_position + dir * 0.5 + Vector3(0, 0.3, 0))
		"heal":
			var amt := randf_range(spell.min_val, spell.max_val)
			stats.heal(amt)
			AudioManager.play_sfx("orb_pickup")
			if _anim:
				_anim.speed_scale = 1.0
				if _anim.has_animation("spell_cast"):
					_anim.play("spell_cast", 0.1)
				elif _anim.has_animation("Bow1"):
					_anim.play("Bow1", 0.1)
				elif _anim.has_animation("default_001"):
					_anim.play("default_001", 0.1)

func _ranged_attack() -> void:
	if _bow_firing:
		return
	_bow_firing = true
	if not _fp_mode:
		_rotate_toward_mouse()
	var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND)
	if not weapon:
		_bow_firing = false
		return
	var dir := _aim_dir()
	var dmg_min := stats.get_melee_damage_min() if stats else 2.0
	var dmg_max := stats.get_melee_damage_max() if stats else 4.0
	var dmg := randf_range(dmg_min, dmg_max)
	var atk_spd := stats.get_attack_speed() if stats else 3.0
	_action_cd = 0.9 / atk_spd
	_attacking = true

	if _anim:
		_anim.speed_scale = atk_spd
		if _anim.has_animation("Bow1"):
			_anim.play("Bow1", 0.1)
		elif _anim.has_animation("default_001"):
			_anim.play("default_001", 0.1)

	# Show static arrow during draw (child of SwordAttach, follows hand)
	if _arrow_visual:
		_arrow_visual.visible = true

	# Play bow string animation and wait for release
	var bow_node = _weapon_nodes.get("bow")
	if bow_node:
		var bow_anim = bow_node.get_node_or_null("AnimPlayer")
		if bow_anim and bow_anim.has_animation("bow_string"):
			bow_anim.stop()
			bow_anim.speed_scale = atk_spd
			bow_anim.play("bow_string")
			await bow_anim.animation_finished
	else:
		await get_tree().create_timer(0.9 / atk_spd).timeout

	if not is_instance_valid(self):
		_bow_firing = false
		return

	# Hide static arrow
	if _arrow_visual:
		_arrow_visual.visible = false

	# Spawn real arrow at SwordAttach position, fly straight
	if _arrow_scene:
		var proj = _arrow_scene.instantiate()
		if proj:
			proj.init(dir, dmg)
			var p = get_parent()
			if p:
				p.add_child(proj)
				if _weapon_attach:
					proj.global_position = _weapon_attach.global_position
				else:
					proj.global_position = global_position + dir * 1.5 + Vector3(0, 0.4, 0)
				AudioManager.play_sfx("bow_shoot")
	_bow_firing = false

func _update_anim(moving: bool) -> void:
	if not _anim:
		return
	if _attacking:
		if not _anim.is_playing():
			_anim.speed_scale = 1.0
			_attacking = false
			if not _hit_something:
				AudioManager.play_sfx("woosh_miss")
		else:
			return
	var anim := "run_loop" if moving else "idle_loop"
	if _anim.has_animation(anim):
		if _anim.current_animation != anim or not _anim.is_playing():
			_anim.play(anim, 0.2)

func _spawn_blood_effects() -> void:
	var pos := global_position
	var root := get_parent()

	var impact := preload("res://scenes/fx/blood_impact.tscn").instantiate()
	root.add_child(impact)
	impact.global_position = pos + Vector3(0, 1.2, 0)
	var iscale := randf_range(0.8, 1.8)
	impact.scale = Vector3(iscale, iscale, iscale)
	impact.rotation.y = randf() * TAU

func take_damage(amount: float) -> void:
	if stats:
		stats.take_damage(amount)
		_hp_regen_delay = 5.0
		AudioManager.play_sfx("player_hit")
		_spawn_blood_effects()

func heal(amount: float) -> void:
	if stats: stats.heal(amount)

func add_xp(amount: float) -> void:
	if stats: stats.add_xp(amount)

func _on_died() -> void:
	set_physics_process(false)
	set_process_input(false)
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	AudioManager.play_sfx_channel3("player_die")
	if _anim and _anim.has_animation("death"):
		var death_anim = _anim.get_animation("death")
		death_anim.loop_mode = Animation.LOOP_NONE
		_anim.play("death")
		await _anim.animation_finished
	# Stay visible in death pose; game restart handled externally

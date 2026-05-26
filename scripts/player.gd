extends CharacterBody3D

enum Action { MELEE, FIREBALL }

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

func _ready() -> void:
	if not stats:
		stats = Stats.new()
	stats.died.connect(_on_died)
	add_to_group("player")
	var model = get_node("HowardModel")
	if model:
		_anim = model.get_node("AnimationPlayer") if model.has_node("AnimationPlayer") else null
		if _anim and _anim.has_animation("idle"):
			_anim.play("idle", 0.0)
	_setup_inventory()
	_sword_hitbox = Area3D.new()
	_sword_hitbox.name = "SwordHitbox"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(3.0, 2.0, 3.0)
	col.shape = shape
	_sword_hitbox.add_child(col)
	_sword_hitbox.position = Vector3(0, 0.5, -1.5)
	_sword_hitbox.monitoring = false
	add_child(_sword_hitbox)

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
	if not _is_stats_open() and not _attacking:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _action_cd <= 0:
			_do_action()
	if Input.is_key_pressed(KEY_C):
		if not _c_held:
			_c_held = true
			_toggle_stats()
	elif _c_held:
		_c_held = false

	if Input.is_key_pressed(KEY_TAB):
		if not _i_held:
			_i_held = true
			_toggle_inventory()
	elif _i_held:
		_i_held = false

var _c_held := false
var _i_held := false
var _f5_held := false
var _f9_held := false

var _weapon_attach: Node3D = null
var _weapon_nodes: Dictionary = {}

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

	var model := get_node("HowardModel")
	if model:
		_weapon_attach = model.get_node("Armature/Skeleton3D/SwordAttach")
		for child in _weapon_attach.get_children():
			if child.name.begins_with("Weapon"):
				var cat := child.name.trim_prefix("Weapon")
				_weapon_nodes[cat] = child
				child.visible = false

	inventory.item_equipped.connect(_on_item_equipped)
	inventory.item_unequipped.connect(_on_item_unequipped)
	inventory.item_equipped.connect(_on_equip_stats)
	inventory.item_unequipped.connect(_on_unequip_stats)

	var weapons := [
		["sword_basic", "Rusty Shortsword", "Sword", "sword (1).png", "sword.glb", 2, 3, 0.4, 0.7, 4, 7, -0.5, 0.0],
		["dagger_basic", "Iron Dagger", "Dagger", "dagger (1).png", "dagger.tscn", 1, 1, 0.35, 0.5, 3, 5, -0.1, 0.0],
		["axe_basic", "Hand Axe", "Axe", "axe (1).png", "hand_axe.tscn", 2, 2, 0.5, 0.8, 5, 9, -0.4, 0.0],
		["mace_basic", "Wooden Mace", "Mace", "club (1).png", "mace.tscn", 2, 2, 0.45, 0.65, 4, 8, -0.35, 0.0],
		["flail_basic", "Iron Flail", "Mace", "club (5).png", "flail.tscn", 2, 3, 0.5, 0.75, 5, 10, -0.45, 0.0],
		["sword_vampiric", "Bloodletter", "Sword", "sword (2).png", "sword.glb", 2, 3, 0.4, 0.7, 4, 7, 2.0, 1.0],
	]

	for w in weapons:
		var item := Item.new()
		item.id = w[0]
		item.name = w[1]
		item.category = w[2]
		item.description = "A basic " + w[1].to_lower() + "."
		item.texture_path = "res://assets/textures/items/" + w[3]
		item.scene_path = "res://assets/models/weapons/" + w[4]
		item.grid_width = w[5]
		item.grid_height = w[6]
		item.str_scale_min = w[7]
		item.str_scale_max = w[8]
		item.stats = {"min_damage": w[9], "max_damage": w[10], "attack_speed_mod": w[11], "hp_regen": w[12]}
		if w[0] == "sword_basic":
			inventory.equip(item, Inventory.EquipSlot.RIGHT_HAND)
		else:
			inventory.add_item(item)

	_update_weapon_visibility()
	_apply_equip_stats()

func _on_item_equipped(item: Item, slot_name: String) -> void:
	_update_weapon_visibility()

func _on_item_unequipped(item: Item, slot_name: String) -> void:
	_update_weapon_visibility()

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
	var hp_regen_bonus: float = 0.0
	var weapon := inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND)
	if weapon:
		min_dmg = weapon.stats.get("min_damage", 1.0)
		max_dmg = weapon.stats.get("max_damage", 2.0)
		s_min = weapon.str_scale_min
		s_max = weapon.str_scale_max
		atk_spd_mod = weapon.stats.get("attack_speed_mod", 0.0)
		hp_regen_bonus = weapon.stats.get("hp_regen", 0.0)
	stats.set_item_melee_damage(min_dmg, max_dmg, s_min, s_max)
	stats.set_attack_speed_mod(atk_spd_mod)
	stats.set_hp_regen_add(hp_regen_bonus)

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

func _is_stats_open() -> bool:
	var ss := get_node_or_null("../StatsScreen")
	if not ss:
		ss = get_node("/root/Main/StatsScreen")
	if ss and ss.visible:
		return true
	var inv := get_node_or_null("../InventoryScreen")
	if not inv:
		inv = get_node("/root/Main/InventoryScreen")
	return inv and inv.visible

func _physics_process(delta: float) -> void:
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
			if inventory and inventory.get_equipped(Inventory.EquipSlot.RIGHT_HAND):
				AudioManager.play_sfx_overlap("sword_impact")
			else:
				AudioManager.play_sfx_random("punch")

func _do_action() -> void:
	match _current_action:
		Action.MELEE:
			_melee_attack()
		Action.FIREBALL:
			_cast_fireball()

func _cast_fireball() -> void:
	_rotate_toward_mouse()
	if not stats or stats.mana < 5:
		return
	_action_cd = 0.5
	stats.mana -= 5
	var proj = preload("res://scenes/projectile.tscn").instantiate()
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam:
		var from: Vector3 = cam.project_ray_origin(get_viewport().get_mouse_position())
		var d: Vector3 = cam.project_ray_normal(get_viewport().get_mouse_position())
		var t: float = -from.y / d.y
		if t > 0.0:
			proj.init((from + d * t - global_position).normalized(), stats.spell_damage)
	get_parent().add_child(proj)
	proj.global_position = global_position + Vector3(0, 0.5, 0)
	AudioManager.play_sfx("fireball")
	_attacking = true
	if _anim:
		_anim.speed_scale = 1.0
		if _anim.has_animation("testanim"):
			_anim.play("testanim", 0.1)
		elif _anim.has_animation("default_001"):
			_anim.play("default_001", 0.1)

func _update_anim(moving: bool) -> void:
	if not _anim: return
	if _attacking:
		if not _anim.is_playing():
			_anim.speed_scale = 1.0
			_attacking = false
			if not _hit_something:
				AudioManager.play_sfx("woosh_miss")
		else:
			return
	var anim := "run" if moving else "idle"
	if _anim.current_animation != anim:
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
	queue_free()

extends CharacterBody3D

@export var level: int = 1
@export var hp: float = 25.0
@export var max_hp: float = 25.0
@export var move_speed: float = 1.25
@export var attack_damage: float = 5.0
@export var xp_reward: float = 10.0
@export var windup_time: float = 0.6
@export var attack_range: float = 2.3

var _player: Node3D
var _attack_cooldown: float = 0.0
var _alive: bool = true

func is_alive() -> bool:
	return _alive

var _hp_bar: Control = null
var _hp_bar_fill: ColorRect = null
var _hp_bar_label: Label = null
var _attacking := false
var _attack_windup: float = 0.0
var _bar_hover := false
var _bar_hit := false
var _bar_show_timer: float = 0.0
var _wander_target: Vector3
var _wander_timer: float = 0.0
var _rage_mult: float = 1.0
var _rage_vision: float = 1.0
var _rage_timer: float = 0.0
var _base_speed: float = 1.25
var _base_vision: float = 7.5
var _purple_orb_count: int = 0
var _slow_timer: float = 0.0
@export var display_name: String = ""
var _anim: AnimationPlayer = null
var _pain_timer: float = 0.0
var _model_node: Node3D = null
var _snap_frames := 0
var _item_db_cache: Array = []

const MAX_PURPLE_ORBS: int = 10
const MAX_LEVEL: int = 20

func _ready() -> void:
	randomize()
	if level < 1: level = 1
	if level > MAX_LEVEL: level = MAX_LEVEL
	_apply_level_stats()
	_model_node = get_node_or_null("ZombieModel")
	if not _model_node:
		_model_node = get_node_or_null("SpiderModel")
	if not _model_node:
		_model_node = get_node_or_null("Skeleton3D")
	if not _model_node:
		_model_node = get_node_or_null("Demon")
	_apply_palette()
	_base_speed = move_speed
	_base_vision = 15.0
	_create_hp_bar()
	add_to_group("enemies")
	if display_name == "":
		display_name = "Spider"
	_anim = get_node_or_null("AnimationPlayer")
	if _anim and _anim.has_animation("idle_loop"):
		_anim.play("idle_loop", 0.0)

func _apply_level_stats() -> void:
	max_hp = 18 + level * 20
	hp = max_hp
	attack_damage = 3 + level * 3.8
	move_speed = 1.15 + level * 0.12
	if display_name == "Zombie":
		move_speed *= 0.5
	if display_name == "Demon":
		move_speed *= 1.3
		attack_damage *= 1.5
	xp_reward = 5 + level * 11
	var scl = 0.54 + level * 0.08
	scale = Vector3(scl, scl, scl)

var _palette_shader: Shader = preload("res://assets/shaders/palette_swap3d.gdshader")

const PAL_MAX_COLORS := 6

func _apply_palette() -> void:
	if not _model_node:
		return
	_apply_palette_recursive(_model_node)

func _extract_dominant_colors(tex: Texture2D, max_c: int) -> Array:
	var img: Image = tex.get_image()
	if not img and tex.resource_path:
		var loaded = load(tex.resource_path)
		if loaded and loaded is Texture2D:
			img = loaded.get_image()
	if not img:
		return []
	img.convert(Image.FORMAT_RGBA8)
	# Sample every 4th pixel for a 128x128 texture (about 1024 samples)
	var samples: Array = []
	var step := 4
	for x in range(0, img.get_width(), step):
		for y in range(0, img.get_height(), step):
			var c: Color = img.get_pixel(x, y)
			if c.a > 0.5:
				samples.append(c)
	if samples.is_empty():
		return []
	# Group similar colors (within 0.15 distance)
	var groups: Array = []
	for c in samples:
		var found := false
		for g in groups:
			var gc: Color = g[0]
			var dr: float = gc.r - c.r
			var dg: float = gc.g - c.g
			var db: float = gc.b - c.b
			if dr * dr + dg * dg + db * db < 0.0225:
				g[1] += 1
				g[0] = (g[0] + c) / 2.0
				found = true
				break
		if not found:
			groups.append([c, 1])
	groups.sort_custom(func(a, b): return a[1] > b[1])
	var result: Array = []
	for g in groups:
		if result.size() >= max_c:
			break
		var col: Color = g[0]
		result.append(col)
	return result

func _build_palette_image(source_colors: Array) -> Image:
	var img := Image.create(8, 2, false, Image.FORMAT_RGBA8)
	for i in 8:
		if i < source_colors.size():
			var src: Color = source_colors[i]
			var rep := _vibrant_replace(src)
			img.set_pixel(i, 0, src)
			img.set_pixel(i, 1, rep)
		else:
			img.set_pixel(i, 0, Color(0, 0, 0, 0))
			img.set_pixel(i, 1, Color(0, 0, 0, 0))
	return img

func _vibrant_replace(base: Color) -> Color:
	var h: float
	var s: float
	var v: float
	if base.r + base.g + base.b < 0.05:
		h = randf_range(0.0, 1.0)
		s = randf_range(0.6, 1.0)
		v = randf_range(0.3, 0.7)
	elif base.s < 0.2 and base.v > 0.7:
		h = fmod(base.h + randf_range(-0.3, 0.3), 1.0)
		s = randf_range(0.1, 0.3)
		v = randf_range(0.8, 1.0)
	else:
		h = fmod(base.h + randf_range(-0.4, 0.4), 1.0)
		s = randf_range(0.6, 1.0)
		v = randf_range(0.6, 1.0)
	return Color.from_hsv(h, s, v)

func _apply_palette_recursive(node: Node) -> void:
	if node is MeshInstance3D and node.mesh:
		for i in node.mesh.get_surface_count():
			var orig: Material = node.get_surface_override_material(i)
			if not orig:
				orig = node.mesh.surface_get_material(i)
			if not orig:
				orig = node.mesh.surface_get_material(0)
			if orig and orig is StandardMaterial3D:
				var tex: Texture2D = orig.albedo_texture
				if not tex:
					continue
				var src_colors := _extract_dominant_colors(tex, PAL_MAX_COLORS)
				if src_colors.is_empty():
					continue
				var pal_tex := ImageTexture.create_from_image(_build_palette_image(src_colors))
				var sm := ShaderMaterial.new()
				sm.shader = _palette_shader
				sm.set_shader_parameter("albedo_texture", tex)
				sm.set_shader_parameter("palette_tex", pal_tex)
				sm.set_shader_parameter("tolerance", 0.15)
				node.set_surface_override_material(i, sm)
	for child in node.get_children():
		_apply_palette_recursive(child)

func init(player: Node3D, lvl: int) -> void:
	_player = player
	level = clampi(lvl, 1, MAX_LEVEL)
	_apply_level_stats()
	_base_speed = move_speed
	_base_vision = 15.0
	if _hp_bar:
		_update_hp_bar()
	else:
		_create_hp_bar()

func _create_hp_bar() -> void:
	if _hp_bar:
		return
	var tree := get_tree()
	if not tree or not tree.root:
		return
	var layer: CanvasLayer = tree.root.find_child("EnemyHPBars", true, false)
	if not layer:
		return
	var scene = preload("res://scenes/enemy_hp_bar.tscn")
	_hp_bar = scene.instantiate()
	layer.add_child(_hp_bar)
	_hp_bar_fill = _hp_bar.get_node("Fill")
	_hp_bar_label = _hp_bar.get_node("Label")
	_hp_bar.visible = false
	_update_hp_bar()

func _remove_hp_bar() -> void:
	if _hp_bar:
		_hp_bar.queue_free()
		_hp_bar = null
		_hp_bar_fill = null
		_hp_bar_label = null

func _process(delta: float) -> void:
	if not _alive or not _hp_bar:
		return
	if _bar_hit:
		_bar_show_timer -= delta
		if _bar_show_timer <= 0.0:
			_bar_hit = false
	_check_mouse_proximity()
	if not _hp_bar.visible:
		return
	_update_hp_bar_position()

func _check_mouse_proximity() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if not cam: return
	var from := cam.project_ray_origin(get_viewport().get_mouse_position())
	var dir := cam.project_ray_normal(get_viewport().get_mouse_position())
	var t: float = -from.y / dir.y
	if t <= 0.0: return
	var mouse_pos := from + dir * t
	var dist := global_position.distance_to(mouse_pos)
	var was := _bar_hover
	_bar_hover = dist < 4.0
	if _bar_hover != was:
		_update_bar_visibility()

func _update_hp_bar_position() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if not cam:
		return
	var world_pos := global_position + Vector3(0, 3.2, 0)
	var screen_pos := cam.unproject_position(world_pos)
	_hp_bar.position = screen_pos - Vector2(_hp_bar.size.x * 0.5, 0)

func apply_rage(dur: float) -> void:
	_rage_mult = 1.5
	_rage_vision = 4.0
	_rage_timer = dur

func _physics_process(delta: float) -> void:
	if not _alive or not _player:
		return
	if not is_instance_valid(_player) or _player.get_collision_layer_value(3) == false:
		return
	_snap_frames += 1
	if _snap_frames < 60:
		move_and_slide()
		return
	if _slow_timer > 0.0:
		_slow_timer -= delta
	else:
		_base_speed = move_speed
	_attack_cooldown = max(_attack_cooldown - delta, 0.0)

	if _pain_timer > 0.0:
		_pain_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		velocity.y += -15.0 * delta
		move_and_slide()
		return
	if _rage_timer > 0.0:
		_rage_timer -= delta
		if _rage_timer <= 0.0:
			_rage_mult = 1.0
			_rage_vision = 1.0

	var dist := global_position.distance_to(_player.global_position)
	var vision_range := _base_vision * _rage_vision
	var current_speed := _base_speed * _rage_mult

	if _attacking:
		_attack_windup -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		if _attack_windup <= 0.0:
			_attacking = false
			if dist < attack_range:
				_attack_player()
		velocity.y += -15.0 * delta
		move_and_slide()
		return

	if dist < attack_range:
		_look_at_player()
		if _attack_cooldown <= 0.0:
			_attack_cooldown = 1.0
			if _anim and _anim.has_animation("attack"):
				_anim.play("attack")
				_attacking = true
				_attack_windup = _anim.get_animation("attack").length
			else:
				_attacking = true
				_attack_windup = windup_time
		velocity.y += -15.0 * delta
		move_and_slide()
		return

	if dist < vision_range:
		_look_at_player()
		var dir := (_player.global_position - global_position).normalized()
		velocity.x = dir.x * current_speed
		velocity.z = dir.z * current_speed
		velocity.y += -15.0 * delta
		move_and_slide()
		if _anim and _anim.has_animation("walk") and _anim.current_animation != "walk":
			_anim.play("walk")
		return

	# Wander when player is far
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_wander_target = global_position + Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
		_wander_timer = randf_range(2.0, 5.0)
	var wdir := (_wander_target - global_position)
	wdir.y = 0.0
	if wdir.length_squared() > 0.5:
		wdir = wdir.normalized()
		velocity.x = wdir.x * current_speed * 0.5
		velocity.z = wdir.z * current_speed * 0.5
		var _s := scale
		transform.basis = Basis.looking_at(-wdir, Vector3.UP)
		scale = _s
		if _anim and _anim.has_animation("walk") and _anim.current_animation != "walk":
			_anim.play("walk")
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if _anim and _anim.has_animation("idle_loop") and _anim.current_animation != "idle_loop":
			_anim.play("idle_loop")
	velocity.y += -15.0 * delta
	move_and_slide()

func _look_at_player() -> void:
	if not _player:
		return
	var diff := _player.global_position - global_position
	diff.y = 0.0
	if diff.length_squared() < 0.001:
		return
	var _s := scale
	transform.basis = Basis.looking_at(-diff.normalized(), Vector3.UP)
	scale = _s

func _attack_player() -> void:
	if not _player or not _player.has_method("take_damage"):
		return
	_player.call("take_damage", attack_damage)

func _update_bar_visibility() -> void:
	if not _hp_bar:
		return
	_hp_bar.visible = _bar_hover or _bar_hit
	if _hp_bar.visible:
		_hp_bar.modulate.a = 0.8

func _spawn_blood_effects() -> void:
	var pos := global_position
	var root := get_parent()

	var impact := preload("res://scenes/fx/blood_impact.tscn").instantiate()
	impact.position = pos + Vector3(0, 0.65, 0)
	root.add_child(impact)
	var iscale := randf_range(0.4, 1.0)
	impact.scale = Vector3(iscale, iscale, iscale)
	impact.rotation.y = randf() * TAU

func take_damage(amount: float) -> void:
	if not _alive:
		return
	hp -= amount
	_bar_hit = true
	_bar_show_timer = 3.0
	_update_hp_bar()
	_update_bar_visibility()
	match display_name:
		"Zombie": AudioManager.play_sfx_random_overlap("zombie_hit")
		"Spider": AudioManager.play_sfx_random_overlap("spider_hit")
		"Demon": AudioManager.play_sfx_random_overlap("demon_hit")
		_: AudioManager.play_sfx_overlap("enemy_hit")
	_spawn_blood_effects()
	_spawn_damage_number(amount)
	var panel = get_tree().get_first_node_in_group("enemy_hp_panel")
	if panel and panel.has_method("track"):
		panel.track(self)
	if hp <= 0.0:
		_die()
	elif _anim and _anim.has_animation("hit"):
		_pain_timer = _anim.get_animation("hit").length
		_anim.play("hit")
		velocity = Vector3.ZERO

func _spawn_damage_number(amount: float) -> void:
	var scene := preload("res://scenes/fx/floating_damage.tscn")
	var dmg := scene.instantiate()
	get_parent().add_child(dmg)
	dmg.init(amount, global_position)

func stun(duration: float) -> void:
	_slow_timer = duration
	_base_speed = move_speed * 0.2
	velocity = Vector3.ZERO

func _update_hp_bar() -> void:
	if not _hp_bar_fill or not _hp_bar_label:
		return
	var ratio: float = max(hp / max_hp, 0.0)
	_hp_bar_fill.size.x = _hp_bar.size.x * ratio
	_hp_bar_label.text = "HP: %d/%d" % [ceil(hp), max_hp]

func _die() -> void:
	_alive = false
	velocity.y = 0.0
	move_and_slide()
	match display_name:
		"Zombie": AudioManager.play_sfx_random_overlap("zombie_die")
		"Spider": AudioManager.play_sfx_random_overlap("spider_die")
		"Demon": AudioManager.play_sfx_random_overlap("demon_die")
		_: AudioManager.play_sfx_overlap("enemy_die")
	_drop_loot()
	_drop_xp()
	_remove_hp_bar()
	set_physics_process(false)
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)

	_spawn_blood_puddle()

	if _anim and _anim.has_animation("die"):
		_anim.play("die")
		await _anim.animation_finished
	elif _model_node:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position:y", position.y - 0.3, 1.0)
		_fade_to_black(tween, _model_node)
		await tween.finished

func _spawn_blood_puddle() -> void:
	var puddle = preload("res://scenes/fx/blood_decal.tscn").instantiate()
	get_parent().add_child(puddle)
	if puddle.has_method("init"):
		puddle.call("init", global_position)

func _fade_to_black(tween: Tween, node: Node) -> void:
	if node is MeshInstance3D:
		node.set_surface_override_material(0, null)
		for i in node.mesh.get_surface_count():
			var mat: Material = node.mesh.surface_get_material(i)
			if mat is StandardMaterial3D:
				var copy := StandardMaterial3D.new()
				copy.albedo_color = mat.albedo_color
				copy.albedo_texture = mat.albedo_texture
				node.set_surface_override_material(i, copy)
				tween.tween_property(copy, "albedo_color", Color.BLACK, 1.0)
	for child in node.get_children():
		_fade_to_black(tween, child)

func consume_orb() -> bool:
	if _purple_orb_count >= MAX_PURPLE_ORBS or level >= MAX_LEVEL:
		return false
	_purple_orb_count += 1
	level += 1
	_apply_level_stats()
	_update_hp_bar()
	_update_bar_visibility()
	return true

func _drop_loot() -> void:
	var kind := randf()
	if kind < 0.10:
		_drop_world_potion("lifepotion")
	elif kind < 0.20:
		_drop_world_potion("manapotion")
	elif kind < 0.30:
		_drop_basic_item()
	elif kind < 0.95:
		_drop_generated_item()
	else:
		_drop_unique_item()

func _filter_items(rarity: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in _get_item_db():
		if entry.get("rarity") != rarity:
			continue
		var cat: String = entry.get("cat", "")
		if cat in ["Sword", "Axe", "Mace", "Bow", "Dagger", "Armor", "Headgear", "Shield", "Ring", "Amulet"]:
			result.append(entry)
	return result

func _filter_basic_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in _get_item_db():
		if entry.get("rarity") != "common":
			continue
		var cat: String = entry.get("cat", "")
		if cat in ["Sword", "Axe", "Mace", "Bow", "Dagger", "Armor", "Headgear", "Shield"]:
			result.append(entry)
	return result

func _drop_basic_item() -> void:
	var pool := _filter_basic_items()
	if pool.is_empty():
		return
	var entry: Dictionary = pool[randi() % pool.size()]
	var item := Item.from_dict(entry)
	if not item:
		return
	print("Dropped: ", item.name)
	_drop_world_item(item)

func _drop_unique_item() -> void:
	var pool := _filter_items("unique")
	if pool.is_empty():
		return
	var entry: Dictionary = pool[randi() % pool.size()]
	var item := Item.from_dict(entry)
	if not item:
		return
	print("Dropped: ", item.name, " (unique)")
	_drop_world_item(item)

func _drop_generated_item() -> void:
	var pool := _filter_items("common")
	if pool.is_empty():
		return
	var entry: Dictionary = pool[randi() % pool.size()]
	var base := Item.from_dict(entry)
	if not base:
		return
	var dungeon_lv: int = 1
	var dgn := get_tree().root.find_child("Dungeon", true, false)
	if dgn and dgn.has_method("get_dungeon_level"):
		dungeon_lv = dgn.call("get_dungeon_level")
	var rarity := "magic" if randf() < 0.75 else "rare"
	var gen := ItemGenerator.generate(base, rarity, dungeon_lv)
	print("Dropped: ", gen.name, " (", gen.rarity, " ", gen.category, ")")
	_drop_world_item(gen)

func _get_item_db() -> Array:
	if _item_db_cache.is_empty():
		var f := FileAccess.open("res://assets/textures/items/_item_data.json", FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Array:
				_item_db_cache = parsed
	return _item_db_cache

func _drop_world_potion(potion_id: String) -> void:
	var data: Array = _get_item_db()
	if data.is_empty():
		return
	for entry in data:
		if entry.get("id") == potion_id:
			var item := Item.from_dict(entry)
			if not item:
				return
			print("Dropped: ", item.name)
			_drop_world_item(item)
			return

func _drop_world_item(item: Item) -> void:
	var pickup := preload("res://scenes/fx/item_pickup.tscn").instantiate()
	if pickup.has_method("init"):
		pickup.call("init", item)
	get_parent().add_child(pickup)
	pickup.global_position = global_position

func _drop_xp() -> void:
	var player = _player
	if player and player.has_method("add_xp"):
		player.call("add_xp", xp_reward)

extends RigidBody3D

@export var item: Item

var _pickup_range: Area3D = null
var _pickup_label: CanvasLayer = null
var _player_near: bool = false

func _ready() -> void:
	if not item:
		return
	gravity_scale = 0.0
	freeze = true

	# 3D model
	if item.scene_path and not item.scene_path.is_empty():
		var scene := load(item.scene_path) as PackedScene
		if scene:
			var inst := scene.instantiate()
			add_child(inst)
			inst.position = Vector3(0, -0.2, 0)
			inst.scale = Vector3(0.27, 0.27, 0.27)
		else:
			_fallback_mesh()
	else:
		_fallback_mesh()

	# Collision
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.16, 0.16, 0.16)
	col.shape = shape
	add_child(col)

	# Pickup Area
	_pickup_range = Area3D.new()
	var col_range := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.5
	col_range.shape = sphere
	_pickup_range.add_child(col_range)
	_pickup_range.body_entered.connect(_on_body_entered)
	add_child(_pickup_range)

	# Label
	_pickup_label = CanvasLayer.new()
	var label := Label.new()
	label.text = "[E] " + (item.name if item else "Item")
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = Color(1, 1, 0.5, 0.9)
	label.add_theme_color_override("font_color", Color(1, 1, 0.5))
	_pickup_label.add_child(label)
	_pickup_label.visible = false
	add_child(_pickup_label)

func _fallback_mesh() -> void:
	var mii := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.16, 0.16, 0.16)
	mii.mesh = box
	if item and item.texture_path and not item.texture_path.is_empty():
		var mat := StandardMaterial3D.new()
		var tex := load(item.texture_path) as Texture2D
		if tex:
			mat.albedo_texture = tex
			mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
			mii.material_override = mat
	add_child(mii)
	mii.position = Vector3(0, 0.08, 0)

func _process(delta: float) -> void:
	if not _pickup_label:
		return
	_update_label_position()

func _update_label_position() -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam: return
	var screen_pos := cam.unproject_position(global_position + Vector3(0, 0.5, 0))
	_pickup_label.position = screen_pos - Vector2(_pickup_label.get_child(0).size.x * 0.5, 0)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true
		_pickup_label.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _player_near:
		_pick()
	elif event.is_action_pressed("pickup") and _player_near:
		_pick()

func _pick() -> void:
	if not item:
		return
	var p := get_tree().get_first_node_in_group("player")
	if not p or not p.has_method("get_inventory"):
		return
	var inv: Inventory = p.get_inventory()
	if inv.add_item(item):
		AudioManager.play_sfx("orb_pickup")
		queue_free()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
		_pickup_label.visible = false

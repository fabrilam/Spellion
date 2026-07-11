extends RigidBody3D

@export var item: Item

var _pickup_range: Area3D = null
var _pickup_label: CanvasLayer = null
var _hover_label: CanvasLayer = null
var _alt_label: CanvasLayer = null
var _player_near: bool = false
var _hovered: bool = false
var _ready_for_pickup := false

func init(item_data: Item) -> void:
	item = item_data

func _ready() -> void:
	if not item:
		return
	add_to_group("items")
	_setup_mesh()
	_setup_labels()
	_setup_collision()
	freeze = true
	gravity_scale = 0.0
	# Cooldown: 1s antes de ser agarrable
	collision_layer = 0
	get_tree().create_timer(1.0).timeout.connect(func():
		_ready_for_pickup = true
		collision_layer = 8
	)

func _setup_mesh() -> void:
	var spr := Sprite3D.new()
	spr.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	spr.pixel_size = 0.0075
	spr.centered = true
	if item and item.texture_path:
		spr.texture = load(item.texture_path)
	spr.position = Vector3(0, 0.35, 0)
	add_child(spr)

func _setup_collision() -> void:
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.5, 1.5, 1.5)
	col.shape = shape
	add_child(col)
	collision_layer = 0
	collision_mask = 0

func _setup_labels() -> void:
	# Proximity label [E]
	_pickup_label = CanvasLayer.new()
	var elabel := Label.new()
	elabel.text = "[E] " + (item.name if item else "Item")
	elabel.add_theme_font_size_override("font_size", 14)
	elabel.modulate = Color(1, 1, 0.5, 0.9)
	elabel.add_theme_color_override("font_color", Color(1, 1, 1))
	_pickup_label.add_child(elabel)
	_pickup_label.visible = false
	add_child(_pickup_label)
	# Hover label (mouse over)
	_hover_label = CanvasLayer.new()
	var hlabel := Label.new()
	hlabel.text = item.name if item else "Item"
	hlabel.add_theme_font_size_override("font_size", 16)
	var rcol: Color = Color.WHITE
	match item.rarity if item else "":
		"magic": rcol = Color(0.3, 0.5, 1.0)
		"rare": rcol = Color(1.0, 0.85, 0.15)
		"unique": rcol = Color(1.0, 0.85, 0.15)
	hlabel.add_theme_color_override("font_color", rcol)
	_hover_label.add_child(hlabel)
	_hover_label.visible = false
	add_child(_hover_label)
	# ALT label (permanent name when ALT held)
	_alt_label = CanvasLayer.new()
	var alabel := Label.new()
	alabel.text = item.name if item else "Item"
	alabel.add_theme_font_size_override("font_size", 16)
	alabel.add_theme_color_override("font_color", Color(1, 1, 1))
	alabel.modulate = Color(1, 1, 1, 0.85)
	_alt_label.add_child(alabel)
	_alt_label.visible = false
	add_child(_alt_label)

func _process(delta: float) -> void:
	if _pickup_label:
		_update_label_position(_pickup_label, 0.5)
	if _hover_label:
		_update_label_position(_hover_label, 0.8)
	if _alt_label:
		_update_label_position(_alt_label, 0.65)

func _update_label_position(layer: CanvasLayer, offset_y: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if not cam: return
	var screen_pos := cam.unproject_position(global_position + Vector3(0, offset_y, 0))
	var label = layer.get_child(0) as Control
	if label:
		label.position = screen_pos - Vector2(label.size.x * 0.5, 0)

func set_hovered(h: bool) -> void:
	_hovered = h
	if _hover_label:
		_hover_label.visible = h

func set_alt_label(v: bool) -> void:
	if _alt_label:
		_alt_label.visible = v

func pickup_by_mouse(inv: Inventory) -> bool:
	if not _ready_for_pickup or not item or not inv:
		return false
	# If inventory screen is open → world drag (Diablo style)
	var inv_screen = get_tree().root.find_child("InventoryScreen", true, false)
	if inv_screen and inv_screen.visible and inv_screen.has_method("start_world_drag"):
		inv_screen.call("start_world_drag", item)
		AudioManager.play_sfx_channel4(Item.drop_sound(item))
		queue_free()
		return true
	# Auto-add if inventory closed
	if inv.add_item(item):
		AudioManager.play_sfx_channel4(Item.drop_sound(item))
		queue_free()
		return true
	return false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true
		_pickup_label.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _player_near and _ready_for_pickup:
		_pick()
	elif event.is_action_pressed("pickup") and _player_near and _ready_for_pickup:
		_pick()

func _pick() -> void:
	if not item or not _ready_for_pickup:
		return
	var p := get_tree().get_first_node_in_group("player")
	if not p or not p.has_method("get_inventory"):
		return
	var inv: Inventory = p.get_inventory()
	if inv.add_item(item):
		AudioManager.play_sfx_channel4(Item.drop_sound(item))
		queue_free()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
		_pickup_label.visible = false

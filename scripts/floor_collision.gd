extends StaticBody3D

func _ready() -> void:
	var sh := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var cover_z := 210.0
	box.size = Vector3(400, 0.2, cover_z)
	sh.shape = box
	sh.position = Vector3(0, 0.0, -95.0)
	add_child(sh)

extends Timer

@export var spawn_interval_min: float = 6.0
@export var spawn_interval_max: float = 15.0
@export var spawn_height: float = 20.0
@export var spawn_offset: float = 5.0

func _ready() -> void:
	timeout.connect(_spawn)
	_restart()

func _restart() -> void:
	wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	start()

func _spawn() -> void:
	# Purple orbs disabled for now
	_restart()

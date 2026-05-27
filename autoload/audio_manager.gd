extends Node

var _sounds := {
	"sword": preload("res://assets/audio/sfx_sword.mp3"),
	"sword_impact": preload("res://assets/audio/sfx_sword_impact.mp3"),
	"woosh_miss": preload("res://assets/audio/sfx_sword.mp3"),
	"gore": preload("res://assets/audio/sfx_sword_hit.mp3"),
	"fireball": preload("res://assets/audio/sfx_fireball.wav"),
	"player_hit": preload("res://assets/audio/sfx_player_hit.wav"),
	"enemy_hit": preload("res://assets/audio/sfx_enemy_hit.wav"),
	"enemy_die": preload("res://assets/audio/sfx_enemy_die.wav"),
	"orb_pickup": preload("res://assets/audio/sfx_orb_pickup.mp3"),
	"levelup": preload("res://assets/audio/sfx_levelup.mp3"),
	"ui_click": preload("res://assets/audio/sfx_ui_click.mp3"),
	"bow_shoot": preload("res://assets/audio/rf_sfx_database/Arrow01.WAV"),
	"arrow_impact": preload("res://assets/audio/rf_sfx_database/ArrHit.WAV"),
}

var _sound_groups := {
	"punch": [
		preload("res://assets/audio/sfx_punch.mp3"),
	],
}

var _music_tracks := {
	"ambient": preload("res://assets/audio/music_ambient.mp3"),
	"forest": preload("res://assets/audio/Ambiance_Wind_Forest_Loop_Stereo.wav"),
}

@onready var music_player := $MusicPlayer
@onready var sfx_player := $SFXPlayer
@onready var sfx_player2 := $SFXPlayer2

func _ready() -> void:
	music_player.finished.connect(_on_music_finished)
	play_music("forest")

func play_sfx(name: String) -> void:
	if not _sounds.has(name):
		return
	sfx_player.stream = _sounds[name]
	sfx_player.pitch_scale = 1.0
	sfx_player.play()

func play_sfx_overlap(name: String) -> void:
	if not _sounds.has(name):
		return
	sfx_player2.stream = _sounds[name]
	sfx_player2.pitch_scale = 1.0
	sfx_player2.play()

func play_sfx_random(name: String, pitch_min: float = 0.85, pitch_max: float = 1.15) -> void:
	if not _sound_groups.has(name) or _sound_groups[name].is_empty():
		return
	var streams: Array = _sound_groups[name]
	var s = streams[randi() % streams.size()]
	sfx_player.stream = s
	sfx_player.pitch_scale = randf_range(pitch_min, pitch_max)
	sfx_player.play()

func play_music(name: String) -> void:
	if not _music_tracks.has(name):
		return
	music_player.stream = _music_tracks[name]
	music_player.play()

func _on_music_finished() -> void:
	music_player.play()

func stop_music(fade: float = 0.0) -> void:
	if fade <= 0.0:
		music_player.stop()
	else:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade)
		tween.tween_callback(music_player.stop)

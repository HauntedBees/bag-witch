class_name AudioManager extends Node

@onready var _music1: AudioStreamPlayer = %Music1
@onready var _music2: AudioStreamPlayer = %Music2

var _current_player: AudioStreamPlayer = null

func _ready() -> void:
	SignalBus.change_song.connect(_change_song)

func _change_song(song: AudioStream, fade_time: float) -> void:
	# probably don't need to worry about threaded loads
	if _current_player == null:
		_current_player = _music1
		_current_player.stream = song
		_current_player.play(0.0)
		return
	var prev_player := _current_player
	_current_player = _music2 if _current_player == _music1 else _music1
	prev_player.volume_linear = 1.0
	_current_player.volume_linear = 0.0
	_current_player.stream = song
	_current_player.play(0.0)
	var t := create_tween().set_parallel()
	t.tween_property(prev_player, "volume_linear", 0.0, fade_time)
	t.tween_property(_current_player, "volume_linear", 1.0, fade_time)
	t.set_parallel(false)
	t.tween_callback(func() -> void:
		prev_player.stop()
	)

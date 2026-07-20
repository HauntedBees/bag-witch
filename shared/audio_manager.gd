class_name AudioManager extends Node

@onready var _music1: AudioStreamPlayer = %Music1
@onready var _music2: AudioStreamPlayer = %Music2

@onready var _sounds: Array[AudioStreamPlayer] = [
	%Sound1, %Sound2, %Sound3, %Sound4, %Sound5, %Sound6
]

var _current_music_player: AudioStreamPlayer = null
var _next_music_loop: AudioStream = null
var _sound_idx := 0

func _ready() -> void:
	SignalBus.change_song.connect(_change_song)
	SignalBus.change_looping_song.connect(_change_looping_song)
	SignalBus.stop_all_sounds.connect(silence_all_sounds)
	SignalBus.play_sound.connect(play_sound)
	_music1.finished.connect(_on_song_finished)
	_music2.finished.connect(_on_song_finished)

func silence_all_sounds() -> void:
	for s in _sounds:
		s.stop()
	_sound_idx = 0

func play_sound(s: AudioStream) -> void:
	var p := _sounds[_sound_idx]
	p.stream = s
	p.play()
	_sound_idx = (_sound_idx + 1) % _sounds.size()

func fade_out_music() -> Signal:
	var t := create_tween()
	t.tween_property(_current_music_player, "volume_linear", 0.0, 0.125)
	return t.finished

func _on_song_finished() -> void:
	if _next_music_loop == null:
		return
	print("loop: %s" % _next_music_loop.resource_path)
	_current_music_player.stream = _next_music_loop
	_current_music_player.play()
	_next_music_loop = null

func _change_song(song: AudioStream, fade_time: float) -> void:
	_change_looping_song(song, null, fade_time)

func _change_looping_song(start: AudioStream, loop: AudioStream, fade_time: float) -> void:
	print("song: %s" % start.resource_path)
	_next_music_loop = loop
	if _current_music_player == null:
		_set_and_play_stream(_music1, start, 1.0)
		return
	var prev_player := _current_music_player
	var next_player := _music2 if _current_music_player == _music1 else _music1
	prev_player.volume_linear = 1.0
	_set_and_play_stream(next_player, start, 0.0)
	var t := create_tween().set_parallel()
	t.tween_property(prev_player, "volume_linear", 0.0, fade_time)
	t.tween_property(_current_music_player, "volume_linear", 1.0, fade_time)
	t.set_parallel(false)
	t.tween_callback(func() -> void:
		prev_player.stop()
	)
	pass

func _set_and_play_stream(player: AudioStreamPlayer, song: AudioStream, volume: float) -> void:
	_current_music_player = player
	player.stream = song
	player.volume_linear = volume
	player.play(0.0)

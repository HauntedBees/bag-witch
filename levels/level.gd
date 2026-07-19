class_name Level extends Node3D

@export var song: AudioStream

# If the song loops, use "song" as the start and this as the looping part.
@export var song_loop: AudioStream

func _ready() -> void:
	if song_loop == null:
		SignalBus.change_song.emit.call_deferred(song, 0.25)
	else:
		SignalBus.change_looping_song.emit.call_deferred(song, song_loop, 0.25)

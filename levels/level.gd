class_name Level extends Node3D

## Basically just for the opening cutscene.
@export var no_sound_if_this_cutscene_is_incomplete := &""

@export var song: AudioStream

# If the song loops, use "song" as the start and this as the looping part.
@export var song_loop: AudioStream

func _ready() -> void:
	if !no_sound_if_this_cutscene_is_incomplete.is_empty() && !Player.has_completed(no_sound_if_this_cutscene_is_incomplete):
		return
	if song_loop == null:
		SignalBus.change_song.emit.call_deferred(song, 0.25)
	else:
		SignalBus.change_looping_song.emit.call_deferred(song, song_loop, 0.25)

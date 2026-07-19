class_name Level extends Node3D

@export var song: AudioStream

func _ready() -> void:
	SignalBus.change_song.emit.call_deferred(song, 0.25)

class_name PlayerOptions extends Resource

signal music_volume_changed(new_value: float)
signal sound_volume_changed(new_value: float)

@export var music_volume := 1.0:
	set(value):
		music_volume = value
		music_volume_changed.emit(value)

@export var sound_volume := 1.0:
	set(value):
		sound_volume = value
		sound_volume_changed.emit(value)

@export var font_scale := 1.0:
	set(value):
		font_scale = value
		GASText.override_font_scale = font_scale

@export var tooltips := true

class_name PlayerOptions extends Resource

signal music_volume_changed(new_value: float)
signal sound_volume_changed(new_value: float)

enum EquipType { AutomaticPersist, AutomaticCurrent, Manual }

@export var resolution := Vector2(1920, 1080):
	set(value):
		if value == resolution:
			return
		resolution = value
		# using SignalBus to get the viewport is just me being lazy. don't do this, kids!
		SignalBus.get_viewport().get_window().size = resolution

var full_screen := false:
	set(value):
		if value == full_screen:
			return
		full_screen = value
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if full_screen else DisplayServer.WINDOW_MODE_WINDOWED)

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

@export var hold_to_bag_enemies := true

@export var equip_type := EquipType.AutomaticPersist

@export var look_sensitivity := 1.0

@export var actions_json: String = ""

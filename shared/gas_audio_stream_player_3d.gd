class_name GASAudioStreamPlayer3D extends AudioStreamPlayer3D

func _ready() -> void:
	volume_linear = Player.data.options.sound_volume
	Player.data.options.sound_volume_changed.connect(_on_sound_volume_changed)

func _on_sound_volume_changed(new_value: float) -> void:
	volume_linear = new_value

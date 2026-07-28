class_name TitleAudioManager extends Node

@onready var _ui_confirm: AudioStreamPlayer = %UI_Confirm
@onready var _ui_cancel: AudioStreamPlayer = %UI_Cancel
@onready var _ui_back: AudioStreamPlayer = %UI_Back
@onready var _ui_cursor: AudioStreamPlayer = %UI_Cursor

func _ready() -> void:
	SignalBus.ui_confirm.connect(_ui_confirm.play)
	SignalBus.ui_cancel.connect(_ui_cancel.play)
	SignalBus.ui_back.connect(_ui_back.play)
	SignalBus.ui_cursor.connect(_ui_cursor.play)
	Player.data.options.sound_volume_changed.connect(_on_sound_volume_changed)

func _on_sound_volume_changed(new_value: float) -> void:
	_ui_confirm.volume_linear = new_value
	_ui_cancel.volume_linear = new_value
	_ui_cursor.volume_linear = new_value
	_ui_back.volume_linear = new_value

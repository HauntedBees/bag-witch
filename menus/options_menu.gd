class_name OptionsMenu extends CanvasLayer

signal closed()

const _SOUND_SCALES := [0.0, 0.25, 0.50, 0.75, 1.0]
const _FONT_SCALES := [1.0, 1.25, 1.5]

@export var active := true:
	set(value):
		active = value
		if !is_inside_tree():
			await ready
		visible = active
		if active:
			_load_from_options()

@onready var _music_volume: Option = %MusicVolume
@onready var _sound_volume: Option = %SoundVolume
@onready var _font_size: Option = %FontSize
@onready var _info_text: Option = %InfoText

var _original_settings: PlayerOptions

func _ready() -> void:
	_load_from_options()

func _load_from_options() -> void:
	_original_settings = Player.data.options.duplicate()
	_music_volume.value_idx = _SOUND_SCALES.find(_original_settings.music_volume)
	_sound_volume.value_idx = _SOUND_SCALES.find(_original_settings.sound_volume)
	_font_size.value_idx = _FONT_SCALES.find(_original_settings.font_scale)
	_info_text.value_idx = 1 if _original_settings.tooltips else 0

func _on_music_volume_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.music_volume = _SOUND_SCALES[new_idx]

func _on_sound_volume_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.sound_volume = _SOUND_SCALES[new_idx]

func _on_font_size_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.font_scale = _FONT_SCALES[new_idx]

func _on_info_text_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.tooltips = new_idx == 1

func _on_save_button_pressed() -> void:
	closed.emit()

func _on_cancel_button_pressed() -> void:
	Player.data.options.music_volume = _original_settings.music_volume
	Player.data.options.sound_volume = _original_settings.sound_volume
	Player.data.options.font_scale = _original_settings.font_scale
	Player.data.options.tooltips = _original_settings.tooltips
	_original_settings = null
	closed.emit()

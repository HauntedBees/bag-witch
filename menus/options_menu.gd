class_name OptionsMenu extends CanvasLayer

signal closed()

const _SOUND_SCALES := [0.0, 0.25, 0.50, 0.75, 1.0]
const _FONT_SCALES := [1.0, 1.25, 1.5]
const _LOOK_SENSITIVITY_SCALES := [0.25, 0.5, 1.0, 1.25, 1.5]

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
@onready var _item_equip: Option = %ItemEquip
@onready var _bag_hold: Option = %BagHold
@onready var _look_sensitivity: Option = %LookSensitivity

@onready var _option_container: VBoxContainer = %OptionContainer
@onready var _scroll_container: ScrollContainer = %ScrollContainer

@onready var _buttons: Array[TextureButton] = [%SaveButton, %ResetButton, %CancelButton]

var _original_settings: PlayerOptions
var _options: Array[BaseOption] = []
var _current_idx := Vector2i.ZERO
var _current_editing_input: InputOption = null
var _buttons_y := 0

func _ready() -> void:
	_load_from_options()
	for o in _option_container.get_children():
		if o is BaseOption:
			_options.append(o)
			o.mouse_entered.connect(_on_option_selected, CONNECT_APPEND_SOURCE_OBJECT)
			if o is InputOption:
				o.pressed.connect(_on_option_pressed, CONNECT_APPEND_SOURCE_OBJECT)
	_buttons_y = _options.size()
	_toggle_highlight(_options[0], true)

func _on_option_pressed(o: InputOption) -> void:
	_current_editing_input = o

func _on_option_selected(o: BaseOption) -> void:
	if _current_idx.y == _buttons_y:
		_toggle_button_highlight(_buttons[_current_idx.x], false)
	else:
		_toggle_highlight(_options[_current_idx.y], false)
	_current_idx.y = _options.find(o)
	_toggle_highlight(_options[_current_idx.y], true, false)

func _unhandled_input(event: InputEvent) -> void:
	if !active:
		return
	get_viewport().set_input_as_handled()
	if _current_editing_input != null:
		if _current_editing_input.try_set_new_input(event):
			_current_editing_input = null
		return
	if _current_idx.y == _buttons_y && BWEnum.is_menu_action_pressed(event):
		_buttons[_current_idx.x].pressed.emit()
		return
	var dir := BWEnum.get_input_dir(event)
	if dir == Vector2i.ZERO:
		return
	if dir.y == 0 && _current_idx.y != _buttons_y:
		return
	if _current_idx.y == _buttons_y:
		_toggle_button_highlight(_buttons[_current_idx.x], false)
	else:
		_toggle_highlight(_options[_current_idx.y], false)
	_current_idx = Vector2i(
		posmod(_current_idx.x + dir.x, 3),
		posmod(_current_idx.y + dir.y, _buttons_y + 1)
	)
	print(_current_idx)
	if _current_idx.y == _buttons_y:
		_toggle_button_highlight(_buttons[_current_idx.x], true)
	else:
		_toggle_highlight(_options[_current_idx.y], true)

func _toggle_highlight(o: BaseOption, is_highlighted: bool, move_mouse := true) -> void:
	o.is_highlighted = is_highlighted
	if is_highlighted:
		_scroll_container.ensure_control_visible(o)
		if move_mouse:
			o.mouse_entered.emit.call_deferred() # lmao

func _toggle_button_highlight(b: TextureButton, is_highlighted: bool) -> void:
	if is_highlighted:
		b.mouse_entered.emit.call_deferred()

func _load_from_options() -> void:
	_original_settings = Player.data.options.duplicate()
	_music_volume.value_idx = _SOUND_SCALES.find(_original_settings.music_volume)
	_sound_volume.value_idx = _SOUND_SCALES.find(_original_settings.sound_volume)
	_font_size.value_idx = _FONT_SCALES.find(_original_settings.font_scale)
	_info_text.value_idx = 1 if _original_settings.tooltips else 0
	_bag_hold.value_idx = 0 if _original_settings.hold_to_bag_enemies else 1
	_item_equip.value_idx = _original_settings.equip_type
	_look_sensitivity.value_idx = _LOOK_SENSITIVITY_SCALES.find(_original_settings.look_sensitivity)
	_current_idx = Vector2i.ZERO
	if _options.size() > 0:
		_toggle_highlight(_options[0], true)
	_scroll_container.set_deferred(&"scroll_vertical", 0)

func _on_music_volume_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.music_volume = _SOUND_SCALES[new_idx]

func _on_sound_volume_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.sound_volume = _SOUND_SCALES[new_idx]

func _on_font_size_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.font_scale = _FONT_SCALES[new_idx]

func _on_info_text_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.tooltips = new_idx == 1

func _on_bag_hold_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.hold_to_bag_enemies = new_idx == 0

func _on_item_equip_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.equip_type = new_idx as PlayerOptions.EquipType

func _on_look_sensitivity_changed(_new_value: String, new_idx: int) -> void:
	Player.data.options.look_sensitivity = _LOOK_SENSITIVITY_SCALES[new_idx]

func _on_save_button_pressed() -> void:
	Player.data.options.actions_json = GASInput.get_actions_as_json()
	closed.emit()

func _on_reset_button_pressed() -> void:
	Player.data.options.music_volume = 1.0
	Player.data.options.sound_volume = 1.0
	Player.data.options.font_scale = 1.0
	Player.data.options.tooltips = true
	Player.data.options.hold_to_bag_enemies = true
	InputMap.load_from_project_settings()
	_original_settings = null
	closed.emit()

func _on_cancel_button_pressed() -> void:
	Player.data.options.music_volume = _original_settings.music_volume
	Player.data.options.sound_volume = _original_settings.sound_volume
	Player.data.options.font_scale = _original_settings.font_scale
	Player.data.options.tooltips = _original_settings.tooltips
	Player.data.options.hold_to_bag_enemies = _original_settings.hold_to_bag_enemies
	if _original_settings.actions_json.is_empty():
		InputMap.load_from_project_settings()
	else:
		GASInput.restore_actions_from_json(_original_settings.actions_json)
	_original_settings = null
	closed.emit()

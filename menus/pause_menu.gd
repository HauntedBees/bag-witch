class_name PauseMenu extends CanvasLayer

signal pause_toggled(paused: bool)

const _PAUSE_ANIM_TIME := 0.125
const _PAUSE_ANIM_OUT_TIME := _PAUSE_ANIM_TIME / 2.0

@onready var _top_corner: HBoxContainer = %TopCorner
@onready var _bottom_corner: TextureRect = %BottomCorner
@onready var _options: MarginContainer = %Options
@onready var _options_menu: OptionsMenu = %OptionsMenu
@onready var _save_screen: SaveScreen = %SaveScreen

@onready var _top_x := -_top_corner.size.x
@onready var _bottom_x := _bottom_corner.size.x
@onready var _options_x := _options.size.x

@onready var _buttons: Array[Button] = [
	%ContinueButton, %OptionsButton, %SaveButton, %QuitToTitleButton
]

var _is_open := false
var _current_tween: Tween = null
var _btn_idx := 0

func _ready() -> void:
	visible = false
	for b in _buttons:
		b.mouse_entered.connect(_on_button_hovered, CONNECT_APPEND_SOURCE_OBJECT)

func _unhandled_input(event: InputEvent) -> void:
	if GASInput.is_event_action_just_pressed(event, &"action_pause"):
		if _is_open:
			_tween_out()
		else:
			_tween_in()
	if !_is_open:
		return
	get_viewport().set_input_as_handled()
	if BWEnum.is_menu_action_pressed(event):
		_buttons[_btn_idx].pressed.emit()
		return
	var dir := BWEnum.get_input_dir(event)
	if dir.y != 0:
		var next_btn := posmod(_btn_idx + dir.y, _buttons.size())
		_buttons[next_btn].mouse_entered.emit()
		return

func _on_button_hovered(b: Button) -> void:
	_btn_idx = _buttons.find(b)

func _tween_in() -> void:
	if _current_tween:
		_current_tween.kill()
	pause_toggled.emit(true)
	get_tree().paused = true
	_btn_idx = true
	_top_corner.offset_transform_position.x = _top_x
	_bottom_corner.offset_transform_position.x = _bottom_x
	_options.offset_transform_position.x = _options_x
	visible = true
	_is_open = true
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	_current_tween.set_ease(Tween.EASE_OUT)
	_current_tween.set_trans(Tween.TRANS_ELASTIC)
	_current_tween.tween_property(_top_corner, "offset_transform_position:x", 0.0, _PAUSE_ANIM_TIME)
	_current_tween.tween_property(_bottom_corner, "offset_transform_position:x", 0.0, _PAUSE_ANIM_TIME)
	_current_tween.tween_property(_options, "offset_transform_position:x", 0.0, _PAUSE_ANIM_TIME)
	_current_tween.set_parallel(false)
	_current_tween.tween_callback(func() -> void:
		_buttons[0].mouse_entered.emit()
	)

func _tween_out() -> void:
	if _options_menu.active || _save_screen.active:
		return
	if _current_tween:
		_current_tween.kill()
	pause_toggled.emit.call_deferred(false)
	get_tree().set_deferred(&"paused", false)
	PhysicsServer3D.set_active.call_deferred(true)
	_is_open = false
	_top_corner.offset_transform_position.x = 0.0
	_bottom_corner.offset_transform_position.x = 0.0
	_options.offset_transform_position.x = 0.0
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	_current_tween.set_ease(Tween.EASE_OUT)
	_current_tween.set_trans(Tween.TRANS_QUINT)
	_current_tween.tween_property(_top_corner, "offset_transform_position:x", _top_x, _PAUSE_ANIM_OUT_TIME)
	_current_tween.tween_property(_bottom_corner, "offset_transform_position:x", _bottom_x, _PAUSE_ANIM_OUT_TIME)
	_current_tween.tween_property(_options, "offset_transform_position:x", _options_x, _PAUSE_ANIM_OUT_TIME)
	_current_tween.set_parallel(false)
	_current_tween.tween_callback(func() -> void:
		visible = false
	)

func _on_continue_button_pressed() -> void:
	_tween_out()

func _on_options_button_pressed() -> void:
	_options_menu.active = true

func _on_options_menu_closed() -> void:
	_options_menu.active = false
	_buttons[1].mouse_entered.emit()

func _on_save_button_pressed() -> void:
	_save_screen.active = true

func _on_save_screen_closed() -> void:
	_save_screen.active = false
	_buttons[2].mouse_entered.emit()

func _on_quit_to_title_button_pressed() -> void:
	var title_path := ResourceUID.uid_to_path("uid://dgyjtcymhrpkp")
	get_tree().paused = false
	get_tree().change_scene_to_file(title_path)

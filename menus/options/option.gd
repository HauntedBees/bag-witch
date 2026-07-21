@tool
class_name Option extends BaseOption

const _OFFSET := Vector2(0.0, 16.0)

@export var values: Array[String] = []:
	set(value):
		values = value
		if !is_inside_tree():
			await ready
		_update_values()
@export var info_texts: Array[String] = []:
	set(value):
		info_texts = value
		if !is_inside_tree():
			await ready
		_update_values()
@export var disabled := false:
	set(value):
		disabled = value
		if !is_inside_tree():
			await ready
		_left.visible = !disabled
		_right.visible = !disabled

var value_idx := 0:
	set(value):
		value_idx = value
		changed.emit(values[value_idx], value_idx)
		_update_values()

@onready var _value_label: Label = %Value
@onready var _left: ClickableArrow = %Left
@onready var _right: ClickableArrow = %Right
@onready var _info_text: Label = %InfoText

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if !is_highlighted:
		return
	if GASInput.is_action_just_pressed("ui_left"):
		_on_left_selected()
	elif GASInput.is_action_just_pressed("ui_right"):
		_on_right_selected()

func _update_values() -> void:
	if value_idx >= values.size():
		value_idx = 0
	_value_label.text = values[value_idx]
	_left.disabled = value_idx == 0
	_right.disabled = value_idx == (values.size() - 1)
	if info_texts.size() > 0:
		_info_text.visible = true
		_info_text.text = info_texts[value_idx]
	else:
		_info_text.visible = false

func _on_left_selected() -> void:
	if value_idx == 0 || disabled:
		#SoundHandler.play_error_sound()
		return
	value_idx -= 1

func _on_right_selected() -> void:
	if value_idx == (values.size() - 1) || disabled:
		#SoundHandler.play_error_sound()
		return
	value_idx += 1

func get_cursor_pos() -> Vector2:
	return _cursor_position.global_position - _OFFSET

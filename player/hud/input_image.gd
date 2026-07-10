@tool
class_name InputImage extends TextureRect

enum DisplayType { CurrentInput, ForceKeyboard, ForceJoypad }

const SIZE := 16
@onready var input_texture: AtlasTexture = texture
@export var action_name := "":
	set(value):
		action_name = value
		if is_inside_tree():
			_set_icon()
@export var display_type := DisplayType.CurrentInput:
	set(value):
		display_type = value
		if is_inside_tree():
			_set_icon()

func _ready() -> void:
	_set_icon()
	if !Engine.is_editor_hint():
		GASInput.input_method_changed.connect(_on_input_method_changed)

func _on_input_method_changed(_new_method: GASInput.InputMethodType) -> void:
	_set_icon()

func _set_icon() -> void:
	var action := _get_appropriate_input_event()
	var idx := 0
	if action == null:
		idx = 208
	elif action is InputEventMouseButton:
		var am := action as InputEventMouseButton
		if am.button_index > 8:
			idx = 10
		else:
			idx = 2 + am.button_index
	elif action is InputEventKey:
		var ak := action as InputEventKey
		var keycode := ak.keycode
		if keycode == 0 && ak.physical_keycode > 0:
			keycode = DisplayServer.keyboard_get_keycode_from_physical(ak.physical_keycode)
		if keycode >= 4194304:
			idx = 68 + keycode - 4194304
		else:
			idx = keycode - 32
	elif action is InputEventJoypadButton:
		var ab := action as InputEventJoypadButton
		if ab.button_index > 15:
			idx = 31
		else:
			var joy_name := Input.get_joy_name(0).to_lower()
			idx = 128 + ab.button_index + _get_console_offset(joy_name, ab.button_index > 10)
	elif action is InputEventJoypadMotion:
		var am := action as InputEventJoypadMotion
		idx = 192
		var joy_name := Input.get_joy_name(0).to_lower()
		match am.axis:
			JOY_AXIS_LEFT_X: idx += 4 if sign(am.axis_value) < 0 else 6
			JOY_AXIS_LEFT_Y: idx += 5 if sign(am.axis_value) < 0 else 7
			JOY_AXIS_RIGHT_X: idx += 8 if sign(am.axis_value) < 0 else 10
			JOY_AXIS_RIGHT_Y: idx += 9 if sign(am.axis_value) < 0 else 11
			JOY_AXIS_TRIGGER_LEFT: idx += 12 + _get_console_offset(joy_name, false)
			JOY_AXIS_TRIGGER_RIGHT: idx += 13 + _get_console_offset(joy_name, false)
	input_texture.region.position = Vector2(SIZE * (idx % 16), SIZE * floorf(idx / 16.0))

func _get_appropriate_input_event() -> InputEvent:
	var actions := InputMap.action_get_events(action_name)
	if actions.size() == 0:
		return null
	var using_joypad := false
	match display_type:
		DisplayType.ForceJoypad: using_joypad = true
		DisplayType.ForceKeyboard: using_joypad = false
		_:
			if Engine.is_editor_hint():
				using_joypad = false
			else:
				using_joypad = GASInput.get_last_input_method() == GASInput.InputMethodType.Joypad
	for a in actions:
		if using_joypad && (a is InputEventJoypadButton || a is InputEventJoypadMotion):
			return a
		elif !using_joypad && a is InputEventKey:
			return a
	return actions[0]

func _get_console_offset(joy_name: String, joycon_different_icon: bool) -> int:
	if joy_name.begins_with("ps4") || joy_name.begins_with("ps5") || joy_name.find("sony") >= 0 || joy_name.find("dualshock") >= 0:
		return 16
	elif joy_name.find("nintendo") >= 0 || joy_name.find("pro controller") >= 0:
		return 32
	elif joy_name.find("joycon") >= 0:
		return 48 if joycon_different_icon else 32
	return 0

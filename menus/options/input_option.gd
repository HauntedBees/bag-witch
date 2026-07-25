@tool
class_name InputOption extends BaseOption

signal pressed()

@export var action: String:
	set(value):
		action = value
		if !is_inside_tree():
			await ready
		_keyboard_input.action_name = action
		_joypad_input.action_name = action

@onready var _keyboard_input: InputImage = %KeyboardInput
@onready var _joypad_input: InputImage = %JoypadInput
@onready var _input_q: TextureRect = %InputQ

var _is_editing := false:
	set(value):
		_is_editing = value
		if !is_inside_tree():
			await ready
		_input_q.visible = _is_editing
		_keyboard_input.visible = !_is_editing
		_joypad_input.visible = !_is_editing

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if is_highlighted && GASInput.is_action_just_pressed(&"menu_confirm"):
		_is_editing = true
		pressed.emit()

func set_new_input(event: InputEvent) -> void:
	_is_editing = false
	if GASInput.is_event_action_just_pressed(event, &"menu_cancel"):
		return
	_is_editing = false
	_keyboard_input.refresh()
	_joypad_input.refresh()

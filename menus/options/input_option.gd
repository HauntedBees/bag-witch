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

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if is_highlighted && GASInput.is_action_just_pressed(&"action_confirm"):
		pressed.emit()

@tool
class_name BaseOption extends BoxContainer

@warning_ignore("unused_signal")
signal changed(new_value: String, new_idx: int)

@export var label := "Placeholder":
	set(value):
		label = value
		if !is_inside_tree():
			await ready
		_name_label.text = label

var is_highlighted := false:
	set(value):
		is_highlighted = value
		_on_highlighted_changed()

@onready var _name_label: Label = %Name
@onready var _cursor_position: VSeparator = %CursorPosition

func get_cursor_pos() -> Vector2:
	return _cursor_position.global_position

func _on_highlighted_changed() -> void:
	pass

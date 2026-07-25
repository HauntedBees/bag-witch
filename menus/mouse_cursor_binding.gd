class_name MouseCursorBinding extends Node

const _CURSOR_SELECT := preload("uid://1fo38ue8ba2x")
const _CURSOR_DRAG := preload("uid://bsi8i6j2usgow")

func _ready() -> void:
	Input.set_custom_mouse_cursor(_CURSOR_SELECT, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(_CURSOR_DRAG, Input.CURSOR_DRAG)
	Input.set_custom_mouse_cursor(_CURSOR_DRAG, Input.CURSOR_MOVE)
	Input.set_custom_mouse_cursor(_CURSOR_DRAG, Input.CURSOR_CAN_DROP)

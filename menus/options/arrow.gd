@tool
class_name ClickableArrow extends TextureRect

signal selected()

const _ICON_SIZE := 16.0
const _ACTIVE_OFFSET := _ICON_SIZE * Vector2(3, 0)
const _DISABLED_OFFSET := _ICON_SIZE * Vector2(3, 1)
const _HOVERED_OFFSET := _ICON_SIZE * Vector2(3, 2)
const _FLIP_OFFSET := _ICON_SIZE * Vector2(1, 0)

@export var input_action := "ui_right"
@export var is_flipped := false

var is_highlighted := false
var disabled := false:
	set(value):
		disabled = value
		if !is_inside_tree():
			await ready
		_tex.region.position = (_DISABLED_OFFSET if disabled else _ACTIVE_OFFSET) + _get_flip_offset()

@onready var _tex: AtlasTexture = texture

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	_tex.region.position = (_DISABLED_OFFSET if disabled else _ACTIVE_OFFSET) + _get_flip_offset()

func _process(_delta: float) -> void:
	if !is_highlighted:
		return
	if Input.is_action_just_pressed(input_action):
		selected.emit()

func _on_mouse_entered() -> void:
	if disabled:
		return
	_tex.region.position = _HOVERED_OFFSET + _get_flip_offset()

func _on_mouse_exited() -> void:
	_tex.region.position = (_DISABLED_OFFSET if disabled else _ACTIVE_OFFSET) + _get_flip_offset()

func _on_gui_input(e: InputEvent) -> void:
	GASInput.emit_signal_if_click(selected, e)

func _get_flip_offset() -> Vector2:
	return _FLIP_OFFSET if is_flipped else Vector2.ZERO

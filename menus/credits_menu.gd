class_name CreditsMenu extends CanvasLayer

signal closed()

const _SCROLL_SPEED := 100.0
const _TOP_DELAY := 2.5

var active := false:
	set(value):
		active = value
		visible = value
		_scroll_amount = 0.0
		_scroll_cooldown = _TOP_DELAY

var _scroll_cooldown := _TOP_DELAY
var _scroll_amount := 0.0:
	set(value):
		_scroll_amount = value
		if !is_inside_tree():
			await ready
		_scroll_container.scroll_vertical = roundi(_scroll_amount)

@onready var _scroll_container: ScrollContainer = %ScrollContainer

func _process(delta: float) -> void:
	if !active:
		return
	if _scroll_cooldown > 0.0:
		_scroll_cooldown -= delta
		return
	_scroll_amount += _SCROLL_SPEED * delta

func _unhandled_input(event: InputEvent) -> void:
	if !active:
		return
	get_viewport().set_input_as_handled()
	if GASInput.is_event_action_just_pressed(event, &"menu_confirm"):
		closed.emit()

func _on_cancel_button_pressed() -> void:
	closed.emit()

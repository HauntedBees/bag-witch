@icon("icons/gas_scroll_container.svg")
class_name GASScrollContainer extends ScrollContainer

signal scrolled(amount: int)

@export var scroll_speed := 1000.0
@export var action_scroll_enabled := true
@export var scroll_level := 0.0:
	set(value):
		scroll_level = value
		scroll_vertical = roundi(scroll_level)
		scrolled.emit(scroll_vertical)
## When true, "ui_down" and "ui_up" actions will scroll, in addition to the
## usual "gas_scroll_down" and "gas_scroll_up" actions.
@export var also_scroll_with_ui_navigation := false

func _ready() -> void:
	get_v_scroll_bar().value_changed.connect(_on_scroll_changed)

func _on_scroll_changed(new_value: float) -> void:
	if abs(new_value - scroll_level) >= 1.5:
		scroll_level = new_value

func _process(delta: float) -> void:
	if !action_scroll_enabled:
		return
	if Input.is_action_pressed("gas_scroll_down") || (also_scroll_with_ui_navigation && Input.is_action_pressed("ui_down")):
		scroll_level += delta * scroll_speed
	elif Input.is_action_pressed("gas_scroll_up") || (also_scroll_with_ui_navigation && Input.is_action_pressed("ui_up")):
		scroll_level -= delta * scroll_speed

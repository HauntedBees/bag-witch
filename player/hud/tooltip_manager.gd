extends Control

const _TOOLTIP_SCENE := preload("uid://bdcwnvc7nfxv3")

var _tooltip: ItemTooltip
var _current_control: Control

func _ready() -> void:
	_tooltip = _TOOLTIP_SCENE.instantiate()
	_tooltip.visible = false
	add_child(_tooltip)

func register_item(c: Control, i: Item) -> void:
	c.mouse_entered.connect(_on_mouse_entered.bind(c, i))
	c.mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	if _current_control != null && _current_control.is_inside_tree() && is_instance_valid(_current_control) && _tooltip.visible:
		_tooltip.global_position = _current_control.global_position

func _on_mouse_entered(c: Control, i: Item) -> void:
	_current_control = c
	_tooltip.global_position = _current_control.global_position
	_tooltip.visible = true
	_tooltip.item = i

func _on_mouse_exited() -> void:
	_tooltip.visible = false

class_name Highlight extends NinePatchRect

@onready var _rotate_icon: InputImage = %RotateIcon
@onready var _button_select_icon: InputImage = %ButtonSelectIcon
@onready var _mouse_select_icon: TextureRect = %MouseSelectIcon

func set_to(n: Control) -> void:
	if is_inside_tree():
		get_parent().remove_child(self)
	if n == null || !is_instance_valid(n) || n.is_queued_for_deletion():
		show_rotate_icon(false)
		show_select_icon(false)
		return
	n.add_child(self)
	set_deferred(&"size", n.size)

func show_rotate_icon(show_icon: bool) -> void:
	if !is_inside_tree():
		await ready
	_rotate_icon.visible = show_icon

func show_select_icon(show_icon: bool, is_mouse := true) -> void:
	if !is_inside_tree():
		await ready
	_mouse_select_icon.visible = show_icon && is_mouse
	_button_select_icon.visible = show_icon && !is_mouse

func force_size(v: Vector2) -> void:
	size = v

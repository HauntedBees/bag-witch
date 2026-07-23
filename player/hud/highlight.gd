class_name Highlight extends NinePatchRect

const _FAKE_DRAG_OFFSET := Vector2(24.0, 24.0)

var grid_pos: Vector2i

@onready var _rotate_icon: InputImage = %RotateIcon
@onready var _button_select_icon: InputImage = %ButtonSelectIcon
@onready var _mouse_select_icon: TextureRect = %MouseSelectIcon

func set_to(td: TileDetails, using_mouse := false) -> void:
	if td == null:
		visible = false
		return
	var n: Control = td.item_display
	var is_item := true
	if _is_invalid(n, false):
		n = td.tile
		if _is_invalid(n):
			return
		is_item = false
		grid_pos = td.tile.grid_pos
	else:
		grid_pos = td.item_display.get_grid_pos()
	_set_to_control(n, is_item, using_mouse)

func set_to_item(n: InventoryItemDisplay, using_mouse := false) -> void:
	if _is_invalid(n):
		return
	grid_pos = n.get_grid_pos()
	_set_to_control(n, true, using_mouse)

func set_to_tile(n: InventoryTile) -> void:
	if _is_invalid(n):
		return
	grid_pos = n.grid_pos
	_set_to_control(n, false, false)

func set_to_dragging_object(d: ItemDragDetails, t: InventoryTile) -> void:
	_rotate_icon.visible = true
	size = d.preview.size
	if d.rotation_changed != d.item.rotated:
		size = Vector2(size.y, size.x)
	if t != null:
		d.preview_parent.global_position = t.global_position + _FAKE_DRAG_OFFSET
	_toggle_select_button(!d.from_mouse, false)

func _set_to_control(n: Control, is_item: bool, using_mouse: bool) -> void:
	visible = true
	_rotate_icon.visible = false
	global_position = n.global_position
	size = n.size
	_toggle_select_button(is_item, using_mouse)

func _toggle_select_button(show_button: bool, using_mouse: bool) -> void:
	_mouse_select_icon.visible = show_button && using_mouse
	_button_select_icon.visible = show_button && !using_mouse

func _is_invalid(n: Node, hide_if_invalid := true) -> bool:
	if n == null || !is_instance_valid(n) || n.is_queued_for_deletion():
		if hide_if_invalid:
			visible = false
		return true
	return false

class_name InventoryTile extends MarginContainer

signal item_hovered(i: ItemDragDetails, p: Vector2i)
signal item_dropped(i: ItemDragDetails, p: Vector2i)

var grid_pos: Vector2i

@onready var _color_rect: ColorRect = %ColorRect
@onready var _base_color := _color_rect.color

func set_highlight(allowed: bool) -> void:
	_color_rect.color = Color.GREEN_YELLOW if allowed else Color.INDIAN_RED

func remove_highlight() -> void:
	_color_rect.color = _base_color

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if data is ItemDragDetails:
		item_hovered.emit(data, grid_pos)
		return true
	else:
		return false

func _drop_data(_pos: Vector2, data: Variant):
	item_dropped.emit(data, grid_pos)

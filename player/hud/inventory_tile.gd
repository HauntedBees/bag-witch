class_name InventoryTile extends MarginContainer

signal item_hovered(i: ItemDragDetails, p: Vector2i)
signal item_dropped(i: ItemDragDetails, p: Vector2i)

var grid_pos: Vector2i

@onready var _frame_base: TextureRect = %FrameBase
@onready var _frame_ok: TextureRect = %FrameOK
@onready var _frame_bad: TextureRect = %FrameBad

func set_highlight(allowed: bool) -> void:
	_frame_base.visible = false
	_frame_ok.visible = allowed
	_frame_bad.visible = !allowed

func remove_highlight() -> void:
	_frame_base.visible = true
	_frame_ok.visible = false
	_frame_bad.visible = false

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if data is ItemDragDetails:
		item_hovered.emit(data, grid_pos)
		return true
	else:
		return false

func _drop_data(_pos: Vector2, data: Variant):
	item_dropped.emit(data, grid_pos)

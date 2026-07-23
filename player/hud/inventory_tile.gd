class_name InventoryTile extends MarginContainer

signal dragged_item_over(i: ItemDragDetails, p: Vector2i)
signal dragged_item_dropped(i: ItemDragDetails, p: Vector2i)

var grid_pos: Vector2i
var idx := 0

@onready var _frame_base: TextureRect = %FrameBase
@onready var _frame_ok: TextureRect = %FrameOK
@onready var _frame_bad: TextureRect = %FrameBad

func _ready() -> void:
	remove_highlight()

func set_highlight(allowed: bool) -> void:
	_frame_base.modulate.a = 0.0
	_frame_ok.modulate.a = 1.0 if allowed else 0.0
	_frame_bad.modulate.a = 0.0 if allowed else 1.0

func remove_highlight() -> void:
	_frame_base.modulate.a = 1.0
	_frame_ok.modulate.a = 0.0
	_frame_bad.modulate.a = 0.0

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if data is ItemDragDetails:
		dragged_item_over.emit(data, grid_pos)
		return true
	else:
		return false

func _drop_data(_pos: Vector2, data: Variant):
	dragged_item_dropped.emit(data, grid_pos)

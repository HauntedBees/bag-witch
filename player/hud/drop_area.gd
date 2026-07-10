class_name ItemDropArea extends NinePatchRect

signal item_dropped(i: ItemDragDetails)

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if data is ItemDragDetails:
		self_modulate.a = 0.9
		return true
	else:
		self_modulate.a = 0.5
		return false

func _drop_data(_pos: Vector2, data: Variant):
	self_modulate.a = 0.5
	item_dropped.emit(data)

func remove_highlight(make_invisible := false) -> void:
	self_modulate.a = 0.5
	if make_invisible:
		visible = false

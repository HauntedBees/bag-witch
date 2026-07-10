class_name ItemSelect extends VBoxContainer

@onready var _selection: NinePatchRect = %Selection
@onready var _item_name: GASLabel = %ItemName

func set_from_world_item(w: WorldItem) -> void:
	var dims := w.get_screen_bounds()
	_selection.custom_minimum_size = dims.size
	_item_name.text = w.item.name

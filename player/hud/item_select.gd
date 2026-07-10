class_name ItemSelect extends VBoxContainer

@onready var _selection: NinePatchRect = %Selection
@onready var _item_name: GASLabel = %ItemName
@onready var _input_image: InputImage = %InputImage

func set_from_world_item(w: WorldItem) -> void:
	_set_visible(w.get_screen_bounds(), w.item.name, true)

func set_from_enemy(e: EnemyDisplay) -> void:
	_set_visible(e.get_screen_bounds(), e.enemy_name, false)

func _set_visible(dims: Rect2, name: String, show_input_image: bool) -> void:
	visible = true
	_selection.custom_minimum_size = dims.size
	_item_name.text = name
	_input_image.visible = show_input_image

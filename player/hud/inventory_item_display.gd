class_name InventoryItemDisplay extends TextureRect

const _TILE_SIZE := 64.0

@export var item: Item:
	set(value):
		item = value
		_update_display()

@onready var _texture := texture as AtlasTexture

func _update_display() -> void:
	if item == null:
		visible = false
		return
	visible = true
	var item_size := _TILE_SIZE * item.icon.size
	custom_minimum_size = item_size
	_texture.region = Rect2(
		_TILE_SIZE * item.icon.position,
		item_size
	)

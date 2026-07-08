class_name InventoryDisplay extends Control

const _TILE_SCENE := preload("uid://chbbyih2rlm8q")
const _ITEM_SCENE := preload("uid://cdd6epqw6450l")

var _inventory := Inventory.new()
var _grid_tiles: Dictionary[Vector2i, Control] = {}

@onready var _grid: GridContainer = %GridContainer
@onready var _items: Control = %ItemBucket

func _ready() -> void:
	_grid.columns = _inventory.dimensions.x
	for y in _inventory.dimensions.y:
		for x in _inventory.dimensions.x:
			var tile: Control = _TILE_SCENE.instantiate()
			_grid_tiles[Vector2i(x, y)] = tile
			_grid.add_child(tile)
	await get_tree().process_frame
	_draw_items()
	_inventory.item_added.connect(_draw_item)

func _draw_items() -> void:
	for i in _items.get_children():
		i.queue_free()
	for i in _inventory.items:
		_draw_item(i)

func _draw_item(i: Inventory.InventoryDetail) -> void:
	var id: InventoryItemDisplay = _ITEM_SCENE.instantiate()
	_items.add_child(id)
	id.item = i.item
	id.global_position = _grid_tiles[i.position].global_position
	# TODO: rotation

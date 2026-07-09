class_name Inventory extends Resource

signal item_added(i: InventoryDetail)

@export var dimensions := Vector2i(7, 4)

@export var items: Array[InventoryDetail] = []

@export var _items_list: Array[Item] = []

func _init() -> void:
	var broom := load("uid://dpgrb2fqcl3qn")
	add_item(broom, Vector2i(2, 1), false)
	add_item(broom, Vector2i(0, 0), false)

func add_item(i: Item, pos: Vector2i, trigger_signal := true) -> void:
	var new_item := InventoryDetail.new(i, pos)
	items.append(new_item)
	_items_list.append(i)
	if trigger_signal:
		item_added.emit(new_item)

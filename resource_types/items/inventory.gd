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
	add_item_detail(InventoryDetail.new(i, pos), trigger_signal)

func add_item_detail(new_item: InventoryDetail, trigger_signal := true) -> void:
	items.append(new_item)
	_items_list.append(new_item.item)
	if trigger_signal:
		item_added.emit(new_item)

func get_item_if_fits(i: Item) -> InventoryDetail:
	var in_use := _get_occupied_positions()
	var d := InventoryDetail.new(i, Vector2i.ZERO)
	var valid_pos := _check_all_positions(d, in_use)
	if valid_pos.x < 0:
		d.rotated = true
		valid_pos = _check_all_positions(d, in_use)
	if valid_pos.x < 0:
		return null
	d.position = valid_pos
	return d

func _check_all_positions(d: InventoryDetail, in_use_positions: Array[Vector2i]) -> Vector2i:
	for y in dimensions.y:
		for x in dimensions.x:
			var all_pos := d.get_positions(Vector2i(x, y), false)
			var success := true
			for p in all_pos:
				if p.x < 0 || p.y < 0 || p.x >= dimensions.x || p.y >= dimensions.y:
					success = false
					break
				if in_use_positions.has(p):
					success = false
					break
			if success:
				return Vector2i(x, y)
	return Vector2i.LEFT

func _get_occupied_positions() -> Array[Vector2i]: # for small arrays, array check is faster than dictionary key check
	var used_tiles: Array[Vector2i] = []
	for i in items:
		for p in i.get_positions(i.position):
			used_tiles.append(p)
	return used_tiles

func has_spell(spell: BWEnum.Spell) -> bool:
	for i in _items_list:
		if i is Spellbook:
			for s in i.spells:
				if spell == s:
					return true
	return false

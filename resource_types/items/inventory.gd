class_name Inventory extends Resource

signal item_added(i: InventoryDetail)
signal item_removed(i: InventoryDetail)
signal items_purged()

@export var dimensions := Vector2i(6, 4)

@export var safe_tiles: Array[Vector2i] = [Vector2i(5, 3)]

@export var items: Array[InventoryDetail] = []

func _init() -> void:
	var broom := load("uid://dpgrb2fqcl3qn")
	add_item(broom, Vector2i(2, 1), false)
	add_item(broom, Vector2i(0, 0), false)
	var book := load("uid://gloeqm86u5q")
	add_item(book, Vector2i(0, 1), false)
	var handgun := load("uid://bjf5fkot1fjp5")
	add_item(handgun, Vector2i(1, 1), false)
	var rock := load("uid://didy3b67akl0n")
	add_item(rock, Vector2i(1, 2), false)

func clear_all_but_equipped() -> void:
	for idx in range(items.size() - 1, -1, -1):
		var id := items[idx]
		if Player.data.current_equipped == id:
			continue
		if safe_tiles.has(id.position): # don't bother checking unless at least the top is there
			if id.item.size == Vector2i(1, 1):
				continue
			var my_safe_tiles := 0
			var all_tiles := id.get_positions(id.position)
			for t in all_tiles:
				if safe_tiles.has(t):
					my_safe_tiles += 1
			if my_safe_tiles == all_tiles.size():
				continue
		print("wiping %s" % id.item.name)
		items.remove_at(idx)
	items_purged.emit()

func remove_item(i: InventoryDetail) -> void:
	items.erase(i)
	item_removed.emit(i)

func add_item(i: Item, pos: Vector2i, trigger_signal := true) -> void:
	add_item_detail(InventoryDetail.new(i, pos), trigger_signal)

func add_item_detail(new_item: InventoryDetail, trigger_signal := true) -> void:
	items.append(new_item)
	if trigger_signal:
		item_added.emit(new_item)

func get_item_if_fits(i: Item) -> InventoryDetail:
	var in_use := _get_occupied_positions()
	var d := InventoryDetail.new(i, Vector2i.ZERO)
	var valid_pos := _check_all_positions(d, in_use, false)
	var was_rotated := false
	if valid_pos.x < 0:
		valid_pos = _check_all_positions(d, in_use, true)
		was_rotated = true
	if valid_pos.x < 0:
		return null
	d.position = valid_pos
	if was_rotated:
		d.rotated = !d.rotated
	return d

func _check_all_positions(d: InventoryDetail, in_use_positions: Array[Vector2i], flip_rotation: bool) -> Vector2i:
	for y in dimensions.y:
		for x in dimensions.x:
			var all_pos := d.get_positions(Vector2i(x, y), flip_rotation)
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

func has_spell_in_inventory(spell: Weapon) -> bool:
	for id in items:
		if id.item is Spellbook:
			for s in id.item.spells:
				if spell == s:
					return true
	return false

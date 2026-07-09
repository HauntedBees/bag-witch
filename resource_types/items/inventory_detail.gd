class_name InventoryDetail extends Resource

@export var item: Item
@export var position: Vector2i
@export var rotated: bool

func _init(i: Item, p: Vector2i) -> void:
	item = i
	position = p
	rotated = false

func get_positions(base_position: Vector2i, rotation_altered := false) -> Array[Vector2i]:
	var pos: Array[Vector2i] = []
	var width := 0
	var height := 0
	var rotat := rotated
	if rotation_altered:
		rotat = !rotat
	if rotat:
		width = item.size.y
		height = item.size.x
	else:
		width = item.size.x
		height = item.size.y
	for x in width:
		for y in height:
			pos.append(base_position + Vector2i(x, y))
	return pos

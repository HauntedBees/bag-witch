class_name InventoryDetail extends Resource

signal ammo_updated(new_amount: int)

@export var item: Item
@export var position: Vector2i
@export var rotated: bool

@export var ammo := 0:
	set(value):
		ammo = value
		ammo_updated.emit(ammo)

func _init(i: Item, p: Vector2i) -> void:
	item = i
	position = p
	rotated = i.rotated_by_default
	if i is ProjectileWeapon:
		if !i.is_spell:
			ammo = randi_range(i.initial_ammo_range.x, i.initial_ammo_range.y)
	elif i is Ammo:
		ammo = randi_range(i.initial_ammo_range.x, i.initial_ammo_range.y)

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

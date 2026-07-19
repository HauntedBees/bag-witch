class_name Food extends Item

@export var heal_range := Vector2i.ZERO

func _inner_use(player: BogWitch) -> void:
	player.take_damage(-randi_range(heal_range.x, heal_range.y))
	print("oo yummy")

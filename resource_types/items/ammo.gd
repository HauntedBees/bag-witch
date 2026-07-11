class_name Ammo extends Item

signal ammo_updated(new_amount: int)

@export var amount := -1:
	set(value):
		amount = value
		ammo_updated.emit(amount)
@export var weapon: ProjectileWeapon
@export var random_range := Vector2i(0, 0)

func get_amount() -> int:
	if amount == -1 && random_range.x > 0:
		amount = randi_range(random_range.x, random_range.y)
	return amount

class_name ReloadableItem extends Weapon

## The amount of ammo a random weapon might have when you first pick it up.
@export var initial_ammo_range := Vector2i(0, 6)

## How much a fully loaded weapon can hold.
@export var full_clip_size := 6

func get_full_clip_size(id: InventoryDetail) -> int:
	var amount := full_clip_size
	for m in id.modifications:
		if m is AmmoModifierMod:
			amount = roundi(amount * m.multiply_amount) + m.increase_amount
	return amount

func get_description(id: InventoryDetail) -> String:
	return "%s\nMax Capacity: %d" % [description, get_full_clip_size(id)]

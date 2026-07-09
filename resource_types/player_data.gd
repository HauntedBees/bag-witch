class_name PlayerData extends Resource

var weapon_slots: Array[Weapon] = []

func _init() -> void:
	var icicle: ProjectileWeapon = load("uid://dn56uhy46vn32")
	weapon_slots.append(icicle)

func get_weapon(slot: int) -> Weapon:
	if weapon_slots.size() <= slot:
		return null
	return weapon_slots[slot]

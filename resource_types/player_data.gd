class_name PlayerData extends Resource

var weapon_slots: Array[Weapon] = [Icicle.new()]

func get_weapon(slot: int) -> Weapon:
	if weapon_slots.size() <= slot:
		return null
	return weapon_slots[slot]

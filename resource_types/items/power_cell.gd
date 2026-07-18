class_name PowerCell extends Ammo

func is_ammo_for(w: Weapon) -> bool:
	return w.uses_power_cells_for_ammo

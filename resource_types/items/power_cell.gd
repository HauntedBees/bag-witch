class_name PowerCell extends Ammo

func is_ammo_for(w: Weapon) -> bool:
	return w.uses_power_cells_for_ammo

func is_mergeable() -> bool:
	return false

func can_be_combined(_me: InventoryDetail, _them: InventoryDetail) -> bool:
	return false

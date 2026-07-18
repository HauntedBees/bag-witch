class_name Ammo extends Item

@export var weapon: ProjectileWeapon
@export var secondary_weapon: ProjectileWeapon
@export var initial_ammo_range := Vector2i(0, 0)
@export var max_amount := 32

func can_be_combined(_me: InventoryDetail, them: InventoryDetail) -> bool:
	if them.item is not Ammo:
		return false
	var their_ammo := them.item as Ammo
	return their_ammo.weapon == weapon

func is_ammo_for(w: Weapon) -> bool:
	return w == weapon || w == secondary_weapon

func combine(me: InventoryDetail, them: InventoryDetail) -> void:
	if !can_be_combined(me, them): # ONE MORE FOR GOOD MEASURE
		return
	var max_add := max_amount - me.ammo
	if them.ammo > max_add:
		them.ammo -= max_add
		me.ammo += max_add
	else:
		me.ammo += them.ammo
		them.ammo = 0

func is_destroyed_after_merge(me: InventoryDetail) -> bool:
	return me.ammo == 0

func is_ammo_applicable() -> bool:
	return true

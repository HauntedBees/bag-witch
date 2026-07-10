extends Node

signal health_changed(new_health: int)
signal weapon_changed(weapon: Weapon)
signal weapon_cooldown_changed(amount: int)
signal ammo_changed(new_ammo: int)

var data := PlayerData.new()
var weapon_cooldown := 0.0:
	set(value):
		weapon_cooldown = value
		weapon_cooldown_changed.emit(value)

func use_weapon(w: Weapon) -> void:
	if w.spell == BWEnum.Spell.None:
		pass # TODO: handle weapon ammo
	else:
		var remaining_ammo := data.get_loaded_ammo(w)
		if remaining_ammo < 0: # unlimited ammo, no action needed
			return
		var new_ammo := data.use_spell_ammo(w)
		ammo_changed.emit(new_ammo)

func take_damage(amount: int) -> void:
	data.current_health -= amount
	if data.current_health <= 0:
		print("OH FUCK") #TODO: check spares
	health_changed.emit(data.current_health)

func try_change_weapon(slot: int) -> void:
	weapon_cooldown = 0.0
	if data.weapon_slots.size() <= slot:
		data.current_weapon = null
		weapon_changed.emit(null)
	else:
		data.current_weapon = data.weapon_slots[slot]
		weapon_changed.emit(data.current_weapon)

class_name PlayerData extends Resource

var inventory := Inventory.new()

var current_weapon: Weapon = null
var weapon_slots: Array[Weapon] = []
var spell_ammo_remaining: Dictionary[BWEnum.Spell, int] = {}

var current_health := 100
var max_health := 100

func _init() -> void:
	var icicle: ProjectileWeapon = load("uid://dn56uhy46vn32")
	weapon_slots.append(icicle)

func get_weapon(slot: int) -> Weapon:
	if weapon_slots.size() <= slot:
		return null
	return weapon_slots[slot]

func use_spell_ammo(w: Weapon) -> int:
	if !spell_ammo_remaining.has(w.spell):
		spell_ammo_remaining[w.spell] = w.spell_ammo
	spell_ammo_remaining[w.spell] -= 1
	return spell_ammo_remaining[w.spell]

func get_loaded_ammo(w: Weapon) -> int:
	if w.spell == BWEnum.Spell.None:
		return 10 # TODO: physical weapon ammo
	else:
		if inventory.has_spell(w.spell):
			return -1
		elif spell_ammo_remaining.has(w.spell):
			return spell_ammo_remaining[w.spell]
		else:
			spell_ammo_remaining[w.spell] = w.spell_ammo
			return w.spell_ammo

func get_remaining_ammo(w: Weapon) -> int:
	if w.spell == BWEnum.Spell.None:
		return 10 # TODO: physical weapon ammo
	else:
		if inventory.has_spell(w.spell):
			return -1
		else:
			return 0

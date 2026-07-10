class_name PlayerData extends Resource

var inventory := Inventory.new()

var current_weapon: Weapon = null
var weapon_slots: Array[Weapon] = []

var current_health := 100
var max_health := 100

var _spell_ammo_remaining: Dictionary[Weapon, int] = {}

func _init() -> void:
	var icicle: ProjectileWeapon = load("uid://dn56uhy46vn32")
	weapon_slots.append(icicle)

func get_available_spells() -> Array[Weapon]:
	var w: Array[Weapon] = []
	for id in inventory.items:
		var i := id.item
		if i is Spellbook:
			for s in i.spells:
				if !w.has(s):
					w.append(s)
		#if i is Weapon && i.is_spell: # player isn't gonna have spells in their actual pockets. probably.
		#	w.append(i)
	for r: Weapon in _spell_ammo_remaining.keys():
		if !w.has(r):
			w.append(r)
	return w

func get_weapon(slot: int) -> Weapon:
	if weapon_slots.size() <= slot:
		return null
	return weapon_slots[slot]

func use_spell_ammo(w: Weapon) -> int:
	if !_spell_ammo_remaining.has(w):
		_spell_ammo_remaining[w] = w.spell_ammo
	_spell_ammo_remaining[w] -= 1
	return _spell_ammo_remaining[w]

func get_loaded_ammo(w: Weapon) -> int:
	if w.is_spell:
		if inventory.has_spell(w):
			return -1
		elif _spell_ammo_remaining.has(w):
			return _spell_ammo_remaining[w]
		else:
			_spell_ammo_remaining[w] = w.spell_ammo
			return w.spell_ammo
	else:
		return 10 # TODO: physical weapon ammo

func get_remaining_ammo(w: Weapon) -> int:
	if w.is_spell:
		if inventory.has_spell(w.spell):
			return -1
		else:
			return 0
	else:
		return 10 # TODO: physical weapon ammo

class_name PlayerData extends Resource

var inventory := Inventory.new()

var current_weapon: Weapon = null

var equip_slots: Array[InventoryDetail] = []

var current_health := 100
var max_health := 100

var _spell_ammo_remaining: Dictionary[Weapon, int] = {}

func _init() -> void:
	for i in 10:
		equip_slots.append(null)

func get_spell_slot(spell: Item) -> int:
	for i in equip_slots.size():
		var id := equip_slots[i]
		if id == null:
			continue
		if id.item == spell:
			return i
	return -1

func get_slot(item: InventoryDetail) -> int:
	return equip_slots.find(item)

func equip_spell_to_slot(spell: Weapon, slot: int) -> void:
	var spell_at_different_slot := -1
	for i in equip_slots.size():
		var id := equip_slots[i]
		if id == null:
			continue
		if id.item == spell:
			spell_at_different_slot = i
			break
	if spell_at_different_slot >= 0:
		equip_slots[spell_at_different_slot] = null
	var fake_item := InventoryDetail.new(spell, Vector2i.LEFT)
	equip_slots[slot] = fake_item

func equip_to_slot(item: InventoryDetail, slot: int) -> void:
	if item.item is not Weapon:
		print("only weapons can be equipped!") #TODO: if I have time, it would be funnier for this to not be true
		return
	#var current_item := equip_slots[slot]
	#if current_item != null:
	#	current_item.unequip()
	var item_at_different_slot := equip_slots.find(item)
	if item_at_different_slot >= 0:
		equip_slots[item_at_different_slot] = null
	equip_slots[slot] = item
	#item.equip(slot)

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
	return null if slot > 0 else null

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
		if inventory.has_spell(w):
			return -1
		else:
			return 0
	else:
		return 10 # TODO: physical weapon ammo

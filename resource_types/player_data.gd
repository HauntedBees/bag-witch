class_name PlayerData extends Resource

var inventory := Inventory.new()

var current_weapon_detail: InventoryDetail = null

var equip_slots: Array[InventoryDetail] = []

var current_health := 100
var max_health := 100

var _spell_ammo_remaining: Dictionary[Weapon, int] = {}

func _init() -> void:
	inventory.item_added.connect(_on_item_added)
	inventory.item_removed.connect(_on_item_removed)
	for i in 10:
		equip_slots.append(null)
	for i in inventory.items: # for the default items
		_on_item_added(i)

func current_weapon() -> Weapon:
	if current_weapon_detail == null:
		return null
	return current_weapon_detail.item

func _on_item_removed(id: InventoryDetail) -> void:
	var idx := equip_slots.find(id)
	if idx < 0:
		if current_weapon() == id.item:
			Player.try_change_weapon(equip_slots.find(current_weapon_detail))
		return
	var alt: InventoryDetail = null
	for potential_alt in inventory.items:
		if potential_alt.item == id.item:
			alt = potential_alt
			break
	if alt != null:
		equip_to_slot(alt, idx)
	elif current_weapon() == id.item:
		print("clearing slot %s" % idx)
		equip_slots[idx] = null
		Player.try_change_weapon(idx)

func _on_item_added(id: InventoryDetail) -> void:
	if id.item is Spellbook:
		_handle_spell_auto_equipping()
		return
	if id.item is Ammo: # force ammo refresh for UI
		if current_weapon_detail != null:
			Player.ammo_changed.emit(get_loaded_ammo(current_weapon_detail))
		return
	if id.item is not Weapon:
		return
	var first_empty := -1
	for i in equip_slots.size():
		var e := equip_slots[i]
		if e == null:
			if first_empty < 0:
				first_empty = i
		elif e.item == id.item: # don't need to equip the same item twice
			return
	if first_empty >= 0:
		equip_to_slot(id, first_empty)

func _handle_spell_auto_equipping() -> void:
	for s in get_available_spells():
		if get_spell_slot(s) >= 0:
			continue
		var first_empty := -1
		for i in equip_slots.size():
			var e := equip_slots[i]
			if e == null && first_empty < 0:
				first_empty = i
				break
		if first_empty >= 0:
			equip_spell_to_slot(s, first_empty)

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

func equip_to_slot(id: InventoryDetail, slot: int) -> void:
	if id.item is not Weapon:
		print("only weapons can be equipped!") #TODO: if I have time, it would be funnier for this to not be true
		return
	#var current_item := equip_slots[slot]
	#if current_item != null:
	#	current_item.unequip()
	var item_at_different_slot := equip_slots.find(id)
	if item_at_different_slot >= 0:
		equip_slots[item_at_different_slot] = null
	equip_slots[slot] = id
	#item.equip(slot)

func refresh_spell_ammo() -> void:
	for id in inventory.items:
		var i := id.item
		if i is Spellbook:
			for s in i.spells:
				if _spell_ammo_remaining.has(s):
					_spell_ammo_remaining.erase(s)

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

func use_spell_ammo(w: Weapon) -> int:
	if !_spell_ammo_remaining.has(w):
		_spell_ammo_remaining[w] = w.spell_ammo
	_spell_ammo_remaining[w] -= 1
	return _spell_ammo_remaining[w]

func get_loaded_ammo(id: InventoryDetail) -> int:
	var w: Weapon = id.item
	if w.is_spell:
		if inventory.has_spell(w):
			return -1
		elif _spell_ammo_remaining.has(w):
			return _spell_ammo_remaining[w]
		else:
			_spell_ammo_remaining[w] = w.spell_ammo
			return w.spell_ammo
	elif w is ProjectileWeapon:
		return id.ammo
	else:
		return -1

func get_remaining_ammo(w: Weapon) -> int:
	if w.is_spell:
		if inventory.has_spell(w):
			return -1
		else:
			return 0
	else:
		var total := 0
		for id in inventory.items:
			if id.item is Ammo && (id.item as Ammo).weapon == w:
				total += id.ammo
		return total

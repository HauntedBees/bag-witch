class_name PlayerData extends Resource

signal stat_changed()

var mind := 1:
	set(value):
		mind = value
		stat_changed.emit()
var strength := 1:
	set(value):
		strength = value
		stat_changed.emit()
var magic := 3:
	set(value):
		magic = value
		stat_changed.emit()
var bag := 1:
	set(value):
		bag = value
		stat_changed.emit()
var speed := 1:
	set(value):
		speed = value
		stat_changed.emit()

var inventory := Inventory.new()

var current_equipped: InventoryDetail = null
var equip_slots: Array[InventoryDetail] = []

var current_health := 100
var max_health := 100

var completed_quests: Array[StringName] = [&"FromBog"]

var _spell_ammo_remaining: Dictionary[Weapon, int] = {}

func _init() -> void:
	inventory.item_added.connect(_on_item_added)
	inventory.item_removed.connect(_on_item_removed)
	inventory.items_purged.connect(_on_items_purged)
	for i in 10:
		equip_slots.append(null)
	for i in inventory.items: # for the default items
		_on_item_added(i)

func portal_wipe() -> void:
	var current_spell := current_equipped_item()
	for k: Weapon in _spell_ammo_remaining.keys():
		if k != current_spell:
			_spell_ammo_remaining.erase(k)
	inventory.clear_all_but_equipped() # do this second because it emits "item_purged" signal

func current_equipped_item() -> Item:
	if current_equipped == null:
		return null
	return current_equipped.item

func _on_item_removed(id: InventoryDetail) -> void:
	var idx := equip_slots.find(id)
	if current_equipped_item() == id.item:
		Player.try_change_weapon(equip_slots.find(current_equipped))
		return
	var alt: InventoryDetail = null
	for potential_alt in inventory.items:
		if potential_alt.item == id.item:
			alt = potential_alt
			break
	if alt != null:
		equip_to_slot(alt, idx)
	elif current_equipped_item() == id.item:
		Player.try_change_weapon(equip_slots.find(current_equipped))
		return

func _on_items_purged() -> void:
	if current_equipped == null:
		return
	var idx := equip_slots.find(current_equipped)
	var alt: InventoryDetail = null
	for potential_alt in inventory.items:
		if potential_alt.item == current_equipped.item:
			alt = potential_alt
			break
	if alt != null:
		equip_to_slot(alt, idx)
	Player.try_change_weapon(equip_slots.find(current_equipped))

func _on_item_added(id: InventoryDetail) -> void:
	if id.item is Spellbook:
		_set_spell_ammo(id.item)
		_handle_spell_auto_equipping()
		return
	if id.item is Ammo: # force ammo refresh for UI
		if current_equipped != null:
			Player.ammo_changed.emit(get_loaded_ammo(current_equipped))
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

func get_first_empty_slot() -> int:
	return equip_slots.find(null)

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
	if id.item.equipped_animation == &"":
		print("only items with equip animations can be equipped!")
		return
	#var current_item := equip_slots[slot]
	#if current_item != null:
	#	current_item.unequip()
	var item_at_different_slot := equip_slots.find(id)
	if item_at_different_slot >= 0:
		equip_slots[item_at_different_slot] = null
	equip_slots[slot] = id
	#item.equip(slot)

func _set_spell_ammo(i: Spellbook) -> void:
	for s in i.spells:
		_spell_ammo_remaining[s as Weapon] = s.spell_ammo

func get_available_spells() -> Array[Weapon]:
	var spells: Dictionary[String, Spell] = {}
	for id in inventory.items:
		var i := id.item
		if i is not Spellbook:
			continue
		for s: Spell in i.spells:
			if magic < s.magic_level_requirement:
				continue
			if !spells.has(s.category):
				spells[s.category] = s
			elif s.magic_level_requirement > spells[s.category].magic_level_requirement:
				spells[s.category] = s
	for r: Weapon in _spell_ammo_remaining.keys():
		if r is Spell:
			if !spells.has(r.category):
				spells[r.category] = r
			elif r.magic_level_requirement > spells[r.category].magic_level_requirement:
				spells[r.category] = r
	var w: Array[Weapon] = []
	w.append_array(spells.values())
	return w

func use_spell_ammo(w: Weapon) -> int:
	if !_spell_ammo_remaining.has(w):
		return 0
	_spell_ammo_remaining[w] -= 1
	if _spell_ammo_remaining[w] > 0:
		return _spell_ammo_remaining[w]
	else:
		_spell_ammo_remaining.erase(w)
		return 0

func has_spell(s: Spell) -> bool:
	return inventory.has_spell_in_inventory(s) || _spell_ammo_remaining.has(s)

func get_loaded_ammo(id: InventoryDetail) -> int:
	var i: Item = id.item
	if i is Weapon && i.is_spell:
		var w: Weapon = i
		if inventory.has_spell_in_inventory(w):
			return -1
		elif _spell_ammo_remaining.has(w):
			return _spell_ammo_remaining[w]
		else:
			return 0
	elif i is ProjectileWeapon:
		return id.ammo
	else:
		return -1

func get_remaining_ammo(w: Item) -> int:
	if w is Weapon:
		if w.is_spell:
			if inventory.has_spell_in_inventory(w):
				return -1
			else:
				return 0
		else:
			var total := 0
			for id in inventory.items:
				if id.item is Ammo && (id.item as Ammo).weapon == w:
					total += id.ammo
			return total
	else:
		return -1

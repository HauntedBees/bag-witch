extends Node

signal equip_changed(weapon: InventoryDetail)
signal weapon_cooldown_changed(amount: int)
signal ammo_changed(new_ammo: int)

var input_locked := false
var inventory_available := true#false

var data := PlayerData.new()
var weapon_cooldown := 0.0:
	set(value):
		weapon_cooldown = value
		weapon_cooldown_changed.emit(value)

func _ready() -> void:
	data.inventory.recalibrate_bag_size()

func use_weapon(w: Item) -> void:
	if w is Weapon && w.is_spell:
		var remaining_ammo := data.get_loaded_ammo(data.current_equipped)
		if remaining_ammo < 0: # unlimited ammo, no action needed
			return
		var new_ammo := data.use_spell_ammo(w)
		ammo_changed.emit(new_ammo)
	elif w is ProjectileWeapon:
		data.current_equipped.ammo -= 1
		ammo_changed.emit(data.current_equipped.ammo)

func take_damage(amount: int) -> void:
	data.current_health = maxi(
		0,
		mini(data.current_health - amount, data.max_health)
	)
	if data.current_health <= 0:
		for id in Player.data.inventory.items:
			if id.item is LifeRestoringPotion:
				var lrp: LifeRestoringPotion = id.item
				var amt := roundi(Player.data.max_health * lrp.dying_percentage_healed)
				data.current_health = amt
				Player.data.inventory.remove_item(id)
				# TODO: a jingle or something?
				return
		SignalBus.game_over.emit()

func has_completed(quest: StringName) -> bool:
	return data.completed_quests.has(quest)

func complete_quest(quest: StringName) -> void:
	data.completed_quests.append(quest)

func try_change_weapon(slot: int) -> void:
	weapon_cooldown = 0.0
	if data.equip_slots.size() <= slot:
		data.current_equipped = null
	else:
		var obj := data.equip_slots[slot]
		if obj == null || !_is_weapon_valid(obj.item):
			data.current_equipped = null
		else:
			data.current_equipped = obj
	equip_changed.emit(data.current_equipped)

func _is_weapon_valid(w: Item) -> bool:
	if w is Weapon && w.is_spell:
		return data.has_spell(w)
	for id in data.inventory.items:
		if id.item == w:
			return true
	return false

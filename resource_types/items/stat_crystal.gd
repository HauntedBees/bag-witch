class_name StatCrystal extends Item

enum Stat { Mind, Strength, Magic, Bag, Speed }

@export var stat: Stat
@export var max_amount_to_level_2 := 3
@export var max_amount_to_level_3 := 5

func is_ready(id: InventoryDetail) -> bool:
	return id.ammo >= _get_max_amount()

func activate(id: InventoryDetail) -> void:
	if !is_ready(id):
		return
	match stat:
		Stat.Mind: Player.data.mind += 1
		Stat.Strength: Player.data.strength += 1
		Stat.Magic: Player.data.magic += 1
		Stat.Bag: Player.data.bag += 1
		Stat.Speed: Player.data.speed += 1

func can_be_combined(_me: InventoryDetail, them: InventoryDetail) -> bool:
	if them.item is not StatCrystal:
		return false
	var their_crystal := them.item as StatCrystal
	return their_crystal.stat == stat

func combine(me: InventoryDetail, them: InventoryDetail) -> void:
	if !can_be_combined(me, them): # ONE MORE FOR GOOD MEASURE
		return
	var max_add := _get_max_amount() - me.ammo
	if them.ammo > max_add:
		them.ammo -= max_add
		me.ammo += max_add
	else:
		me.ammo += them.ammo
		them.ammo = 0

func is_destroyed_after_merge(me: InventoryDetail) -> bool:
	return me.ammo == 0

func get_item_name(id: InventoryDetail) -> String:
	var max_amount := _get_max_amount()
	if max_amount == 999:
		return "%s Shard (%d)" % [name, id.ammo]
	if id.ammo < max_amount:
		return "%s Shard (%d/%d)" % [name, id.ammo, max_amount]
	return name

func get_description(_id: InventoryDetail) -> String:
	var val := get_stat_val()
	if val == 3:
		return "%s\nYou've already reached the maximimum level for this ability." % description
	return description

func get_stat_val() -> int:
	match stat:
		Stat.Mind: return Player.data.mind
		Stat.Strength: return Player.data.strength
		Stat.Magic: return Player.data.magic
		Stat.Bag: return Player.data.bag
		Stat.Speed: return Player.data.speed
	return Player.data.mind

func _get_max_amount() -> int:
	var val := get_stat_val()
	if val == 3:
		return 999
	return max_amount_to_level_3 if get_stat_val() == 2 else max_amount_to_level_2

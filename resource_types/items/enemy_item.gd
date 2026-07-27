class_name EnemyItem extends Item

## When holding this enemy, your movement speed will be multiplied by this.
@export_range(0.0, 1.0) var hold_speed_multiplier := 0.9

## When holding this enemy as a corpse, your movement speed will be multiplied by this.
@export_range(0.0, 1.0) var dead_hold_speed_multiplier := 0.4

@export var damage_multiplier := 3

func get_item_name(id: InventoryDetail) -> String:
	if id.ammo <= 0:
		return "%s Corpse" % name
	return "%s (%dHP)" % [name, id.ammo]

func get_enemy_detail(id: InventoryDetail = null, _from_inventory := false) -> EnemyDisplay:
	var wi_scene: PackedScene = load(scene_path)
	var ed: EnemyDisplay = wi_scene.instantiate()
	ed.max_health = id.ammo
	ed.health = id.ammo
	return ed

class_name LifeRestoringPotion extends Potion

@export var drinking_percentage_healed := 0.5
@export var dying_percentage_healed := 0.5

func _inner_use(player: BogWitch) -> void:
	var amt := roundi(Player.data.max_health * drinking_percentage_healed)
	player.take_damage(-amt, Vector3(0.0, 3.0, 0.0), 2.0, 2.0)

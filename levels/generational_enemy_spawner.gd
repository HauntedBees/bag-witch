class_name GenerationalEnemySpawner extends EnemySpawner

@export var debug := false

const _EARLY_GEN_ENEMIES: Array[PackedScene] = [
	preload("uid://djtpn6s6cdlln") # knight
]
const _MID_GEN_ENEMIES: Array[PackedScene] = [
]
const _LATE_GEN_ENEMIES: Array[PackedScene] = [
	preload("uid://dp2i4li76xmtp") # space knight
]

func _pick_enemy() -> PackedScene:
	var potential_enemies: Array[PackedScene] = []
	potential_enemies.append_array(_EARLY_GEN_ENEMIES)
	if debug || Player.data.generations_elapsed >= 3:
		potential_enemies.append_array(_MID_GEN_ENEMIES)
		if debug || Player.data.generations_elapsed >= 10:
			potential_enemies.append_array(_LATE_GEN_ENEMIES)
	return potential_enemies.pick_random()

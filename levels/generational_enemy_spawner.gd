class_name GenerationalEnemySpawner extends EnemySpawner

const _EARLY_GEN_ENEMIES: Array[PackedScene] = [
	preload("uid://djtpn6s6cdlln"), # knight
	preload("uid://dv5y1llmnu8nh"), # mage
	preload("uid://cvrxto4jxqgxk") # cleric
]
const _MID_GEN_ENEMIES: Array[PackedScene] = [
	preload("uid://dijrcn45o0wf7"), # gunner
	preload("uid://dbjlmc8bdm7se") # shotgunner
]
const _LATE_GEN_ENEMIES: Array[PackedScene] = [
	preload("uid://dp2i4li76xmtp"), # space knight
	preload("uid://cje7l4xc2coy4") # laser space knight
]

func _pick_enemy() -> PackedScene:
	var potential_enemies: Array[PackedScene] = []
	if enemy_types.size() > 0:
		potential_enemies.append_array(enemy_types)
	potential_enemies.append_array(_EARLY_GEN_ENEMIES)
	if Player.data.generations_elapsed >= BWEnum.GEN_MID:
		potential_enemies.append_array(_MID_GEN_ENEMIES)
		if Player.data.generations_elapsed >= BWEnum.GEN_LATE:
			potential_enemies.append_array(_LATE_GEN_ENEMIES)
	return potential_enemies.pick_random()

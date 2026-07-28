extends GenerationalEnemySpawner

var _easy_mode := false

func _ready() -> void:
	if !Player.data.completed_quests.has(&"GameFullyBegun"):
		_easy_mode = true
	super()

func _pick_enemy() -> PackedScene:
	if !_easy_mode:
		return super()
	else: # no clerics, prioritize knights
		return _EARLY_GEN_ENEMIES[0] if randf() <= 0.7 else _EARLY_GEN_ENEMIES[1]

class_name EnemyDead extends EnemyBehavior

var _death_anim_played := false

func _setup_behavior() -> void:
	priority = _DEAD_PRIORITY
	_parent.on_died.connect(_on_died)

func _on_died() -> void:
	take_control()
	if _death_anim_played:
		return
	_death_anim_played = true
	_parent.enemy_name = "%s (Dead)" % _parent.enemy_name
	_parent.animation_player.play(Anim.DIE)

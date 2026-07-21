class_name EnemyDead extends EnemyBehavior

var _death_anim_played := false
var _death_anim: StringName
var _time_to_fade := 120.0

func _init(die_anims: Array[StringName]) -> void:
	if die_anims.size() == 0:
		_death_anim = Anim.NewKayKit.DIE if _parent.is_new_anims else Anim.OldKayKit.DIE
	else:
		_death_anim = die_anims.pick_random()

func _setup_behavior() -> void:
	priority = _DEAD_PRIORITY
	_parent.on_died.connect(_on_died)

func _behave(delta: float) -> void:
	if _death_anim_played:
		_time_to_fade -= delta
		if _time_to_fade <= 0.0:
			queue_free()

func _on_died() -> void:
	take_control()
	if _death_anim_played:
		return
	_death_anim_played = true
	_parent.alive_collider.disabled = true
	_parent.death_collider.disabled = false
	_parent.enemy_name = "%s (Dead)" % _parent.enemy_name
	_parent.animation_player.play(_death_anim)
